import QtQuick 2.0
import QtQuick.LocalStorage 2.12
import Felgo 4.0

import Slippipedia 1.0

Item {
  id: dataBase

  property bool debugLog: false
  property bool debugLogSql: false

  // db connection from LocalStorage
  property var db: null

  property FilterSettings filterSettings: null

  readonly property PlayerFilterSettings playerFilter: filterSettings.playerFilter
  readonly property PlayerFilterSettings opponentFilter: filterSettings.opponentFilter
  readonly property GameFilterSettings gameFilter: filterSettings.gameFilter
  readonly property PunishFilterSettings punishFilter: filterSettings.punishFilter

  signal initialized

  // history:
  // 2.0 - Slippipedia 1.0
  // 2.1 - Slippipedia 1.1 - add Replays.userFlag
  // 3.0 - Slippipedia 2.0 - add Replays.platform, Replays.slippiVersion, drop unused indices
  // 3.1 - Slippipedia 2.1 - add Replays.matchId/gameNumber/tiebreakerNumber/gameMode
  readonly property string dbLatestVersion: "3.1"
  readonly property string dbCurrentVersion: db.version
  readonly property bool dbNeedsUpdate: dbCurrentVersion !== dbLatestVersion

  function initDb() {
    db = LocalStorage.openDatabaseSync("SlippiStatsDB", "", "Slippi Stats DB", 50 * 1024 * 1024)

    if(dbCurrentVersion !== dbLatestVersion) {
      db.changeVersion(dbCurrentVersion, dbLatestVersion, function(tx) {
        console.log("Update DB version from", dbCurrentVersion, "to", dbLatestVersion)

        if(dbCurrentVersion < "2.1") {
          console.log("Update DB to 2.1")
          // 2.1 - add user flag column to replay
          tx.executeSql("alter table Replays add column userFlag integer default 0")
        }
        if(dbCurrentVersion < "3.0") {
          console.log("Update DB to 3.0")
          // 3.0 - indexes updated + added platform and slippiVersion
          try {
            tx.executeSql("alter table Replays add column slippiVersion string default ''")
            tx.executeSql("alter table Replays add column platform string default 'dolphin'")
          }
          catch(ex) {
            // will fail if you had used an intermediate version
            console.log("Could not add columns:", ex)
          }

          tx.executeSql("drop index player_index")
          tx.executeSql("drop index punish_index")
        }
        if(dbCurrentVersion < "3.1") {
          console.log("Update DB to 3.1")
          // 3.1 - add slippi 3.14 data
          tx.executeSql("alter table Replays add column matchId text default ''")
          tx.executeSql("alter table Replays add column gameNumber integer default 0")
          tx.executeSql("alter table Replays add column tiebreakerNumber integer default 0")
          tx.executeSql("alter table Replays add column gameMode integer default 0")
        }
      })

      // reload object to update version property:
      initDb()
      return
    }

    console.log("DB open at version", dbCurrentVersion)
  }

  Component.onCompleted: {
    initDb()

    initialized()
  }

  function createTables(replay) {
    db.transaction(function (tx) {
      tx.executeSql("create table if not exists Replays (
id integer not null primary key,
hasData bool,
date date,
stageId integer,
winnerPort integer,
lrasPort integer,
endType integer,
duration integer,
filePath text,
userFlag integer,
platform text,
slippiVersion text,
matchId text,
gameNumber integer,
tiebreakerNumber integer,
gameMode integer
      )")

      // create a column named s_<stat> for each stat in the replay
      var statsCols = Object.keys(replay.players[0].stats)
      .map(key => qsTr("s_%1 real").arg(key))
      .join(",")

      tx.executeSql(qsTr("create table if not exists Players (
replayId integer,

port integer,
isWinner bool,

slippiName text,
slippiCode text,
cssTag text,

charId integer,
charIdOriginal integer,
skinId integer,
%1,

primary key(replayId, port),
foreign key(replayId) references replays(id)
      )").arg(statsCols))

      tx.executeSql("create table if not exists Punishes (
id integer not null primary key,
replayId integer,
port integer,

startFrame integer,
endFrame integer,
stocks integer,
duration integer,

startPercent real,
endPercent real,
damage real,

openingDynamic integer,
openingMoveId integer,
lastMoveId integer,
numMoves integer,

killDirection integer,
didKill bool,

foreign key(replayId) references replays(id)
      )")

      tx.executeSql("create index if not exists replay_index on replays(stageId)")
      tx.executeSql("create index if not exists player_index on players(replayId, port, charId, slippiCode, slippiName,
                     slippiCode collate nocase, slippiName collate nocase)")
      tx.executeSql("create index if not exists punish_index on punishes(replayId, port, didKill, openingDynamic, openingMoveId, numMoves, damage)")
    })
  }

  function clearAllData() {
    db.transaction(function(tx) {
      tx.executeSql("drop table if exists Replays")
      tx.executeSql("drop table if exists Players")
      tx.executeSql("drop table if exists Punishes")
    })

    // cleans storage space etc after dropping data. must be done outside of transaction
    Utils.executeSql("vacuum")

    db.changeVersion(dbCurrentVersion, dbLatestVersion, function(tx) {
    })
    initDb()
    console.log("DB version updated.", db.version, dbCurrentVersion)
  }

  function analyzeReplay(fileName, replay) {
    var time = new Date().getTime()

    db.transaction(function(tx) {
      if(!replay) {
        tx.executeSql("insert or replace into Replays (filePath, hasData)
                       values (?, false)", [fileName])
        return
      }

      tx.executeSql("insert or replace into Replays (hasData, id, date, stageId,
                                                     winnerPort, lrasPort, endType,
                                                     duration, filePath, platform, slippiVersion,
                                                     matchId, gameNumber, tiebreakerNumber, gameMode)
                     values (true, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    [
                      replay.uniqueId, replay.date, replay.stageId,
                      replay.winningPlayerPort, replay.lrasPlayerIndex, replay.gameEndType,
                      replay.gameDuration, replay.filePath, replay.platform, replay.slippiVersion,
                      replay.matchId, replay.gameNumber, replay.tiebreakerNumber, replay.gameMode
                    ])

      replay.players.forEach(function(player) {
        var stats = player.stats

        var charIdOriginal = player.charId

        // store sheik as zelda so matching is easier. keep original id for reference.
        var charId = charIdOriginal === 19 ? 18 : charIdOriginal

        var params = [
              replay.uniqueId, player.port, player.isWinner,
              charId, charIdOriginal, player.charSkinId,
              player.slippiName, player.slippiCode, player.inGameTag
            ].concat(Object.values(player.stats))

        tx.executeSql(qsTr("insert or replace into Players (
replayId, port, isWinner,
charId, charIdOriginal, skinId,
slippiName, slippiCode, cssTag, %1
)
values %2")
                      .arg(Object.keys(player.stats).map(key => "s_" + key).join(","))
                      .arg(makeSqlWildcards(params)),
                      params)


        player.punishes.forEach(function(punish) {
          var params = [
                punish.uniqueId, replay.uniqueId, player.port,
                punish.startFrame, punish.endFrame, punish.durationFrames,
                punish.startPercent, punish.endPercent, punish.stocks, punish.damage,
                punish.openingDynamic, punish.openingMoveId, punish.lastMoveId, punish.numMoves,
                punish.killDirection, punish.didKill
              ]

          tx.executeSql(qsTr("insert or replace into Punishes (
id, replayId, port,
startFrame, endFrame, duration,
startPercent, endPercent, stocks, damage,
openingDynamic, openingMoveId, lastMoveId, numMoves,
killDirection, didKill
  )
  values %1")
                        .arg(makeSqlWildcards(params)),
                        params)
        })
      })
    })

    var tDiff = new Date().getTime() - time

    log("DB write took", tDiff, "ms")
  }

  function readFromDb(callback, defaultValue) {
    if(!db) return defaultValue

    var time = new Date().getTime()

    var res = defaultValue

    db.readTransaction(function(tx) {
      try {
        var modifiedTx = debugLogSql
            ? {
                executeSql: function(...a) {
                  dataBase.log("Execute SQL:", a[0], a[1])
                  return tx.executeSql(...a)
                }
              }
        : tx

         res = callback(modifiedTx)
      }
      catch(ex) {
        // table doesn't yet exist, ignore

        console.warn("DB error", ex, ex.fileName, ex.lineNumber)
      }
    })

    var tDiff = new Date().getTime() - time

    if(tDiff > 0) {
      log("Read from DB took", tDiff, "ms")
    }

    return res
  }

  function getFilterCondition() {
    return "(" +
        // game
        gameFilter.getGameFilterCondition() +
        // me
        " and " + playerFilter.getFilterCondition("p") +
        // opponent
        " and " + opponentFilter.getFilterCondition("p2") +
        " and r.hasData = 1" + // only match replays that didn't fail parsing
        ")"
  }

  function getFilterParams() {
    // game, then me, then opponent
    return gameFilter.getGameFilterParams()
    .concat(playerFilter.getFilterParams())
    .concat(opponentFilter.getFilterParams())
  }

  function getNumReplays() {
    return readFromDb(function(tx) {
      var results = tx.executeSql("select count(*) c from Replays where hasData = 1")

      return results.rows.item(0).c
    }, 0)
  }

  function getNewReplays(fileList) {    
    // find all files in fileList that do not have a replay in the database

    // do in 1 iteration instead of n*m:
    // -> sort fileList, and get sorted file list from DB
    // then iterate both lists and return all files only contained in the first

    // probably fails if files get renamed or moved

    fileList.sort()

    var paths = readFromDb(function(tx) {
      var results = tx.executeSql("select filePath from Replays order by filePath")

      var paths = []
      for(var i = 0; i < results.rows.length; i++) {
        paths.push(results.rows.item(i).filePath)
      }

      return paths
    }, [])

    var fli = 0
    var rli = 0

    var newFiles = []
    while(fli < fileList.length) {
      var file = fileList[fli]
      var dbFile = rli < paths.length ? paths[rli] : ""

      if(!dbFile || file < dbFile) {
        // file is only in fileList
        newFiles.push(file)
        fli++
      }
      else if(file === dbFile) {
        // file is in both lists
        fli++
        rli++
      }
      else {
        // file is only in DB list
        rli++
      }
    }

    return newFiles
  }

  function getReplaySummary(isOpponent) {
    log("get replay summary")

    return readFromDb(function(tx) {
      // if no player filter specified, match smaller port for P1
      var portCondition = playerFilter.hasPlayerFilter || opponentFilter.hasPlayerFilter
          ? "p.port != p2.port" : "p.port < p2.port"

      var gameEndedCondition = gameFilter.getGameEndedCondition()
      var winnerCondition = gameFilter.getWinnerCondition()

      var sql = qsTr("select
count(r.id) count, avg(r.duration) avgDuration,
count(case when %3 then 1 else null end) gameTiedCount,
count(case when r.lrasPort < 0 then 1 else null end) gameEndedCount,
count(case when %4 then 1 else null end) winCount
from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and %2
where %1").arg(getFilterCondition()).arg(portCondition).arg(gameEndedCondition).arg(winnerCondition)

      var results = tx.executeSql(sql, getFilterParams())

      var statsObj = results.rows.item(0)

      return statsObj
    }, 0)
  }

  function statFunc(stat) {
    // most stats can be summed up but some need a different function
    // return an SQL aggregate function name for this particular stat:
    switch(stat) {
    case "maxGalint": return "max"
    default: return "sum"
    }

  }

  function getReplayStats(isOpponent) {
    log("get replay stats")

    var statCols = []
    db.transaction(function(tx) {
      var tableInfo = tx.executeSql("pragma table_info(players)")

      for (var i = 0; i < tableInfo.rows.length; i++) {
        var colName = tableInfo.rows.item(i).name

        if(colName.startsWith("s_")) {
          statCols.push(colName.substring(2))
        }
      }
    })

    return readFromDb(function(tx) {
      // if no player filter specified, match smaller port for P1
      var portCondition = playerFilter.hasPlayerFilter
          ? "p.port != p2.port" : "p.port < p2.port"

      var playerCol = isOpponent ? "p2" : "p"
      var opponentCol = isOpponent ? "p" : "p2"

      var statColCondition = statCols
      .map(c =>
           qsTr("%3(%1.s_%2) %2")
           .arg(playerCol).arg(c).arg(statFunc(c))
           ).join(",")

      var gameEndedCondition = gameFilter.getGameEndedCondition()
      var winnerCondition = gameFilter.getWinnerCondition()

      var sql = qsTr("select
count(r.id) count, avg(r.duration) avgDuration,
count(case when %3 then 1 else null end) gameTiedCount,
count(case when %4 then 1 else null end) winCount,
count(case when r.lrasPort = %5.port then 1 else null end) lrasCount,
%2
from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and " + portCondition + "
where %1").arg(getFilterCondition()).arg(statColCondition).arg(gameEndedCondition).arg(winnerCondition).arg(playerCol)

      var results = tx.executeSql(sql, getFilterParams())

      var statsObj = results.rows.item(0)

      return statsObj
    }, 0)
  }

  function getOtherStageAmount() {
    log("get other stage amount")

    return readFromDb(function(tx) {
      var results = tx.executeSql(qsTr("select count(distinct r.id) c from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and p.port != p2.port
where stageId not in (%1) and " + getFilterCondition())
                                  .arg(MeleeData.stageIds.map(_ => "?").join(",")), // add one question mark placeholder per argument
                                  MeleeData.stageIds.concat(getFilterParams()))

      return results.rows.item(0).c
    }, 0)
  }

  function getTopPlayerTags(isOpponent, max) {
    log("get top tags")

    return getNameStats("slippiName", isOpponent, max)
  }

  function getTopSlippiCodes(isOpponent, max) {
    log("get top codes")

    return getNameStats("slippiCode", isOpponent, max)
  }

  function getNameStats(nameCol, isOpponent, max) {
    return readFromDb(function(tx) {
      var playerCol = isOpponent ? "p2" : "p"

      // gamesWon is the number of games P1 won, regardless of isOpponent parameter
      var gameEndedCondition = gameFilter.getGameEndedCondition()
      var winnerCondition = gameFilter.getWinnerCondition()

      var sql = qsTr("select %1.%5 text,
count(distinct r.id) count,
sum(case when %3 then 1 else 0 end) gamesFinished,
sum(case when %4 then 1 else 0 end) gamesWon
from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and p.port != p2.port
where text is not null and
text is not \"\" and %2
group by text
order by count desc
limit ?").arg(playerCol).arg(getFilterCondition()).arg(gameEndedCondition).arg(winnerCondition).arg(nameCol)

      var params = getFilterParams().concat([max])

      var results = tx.executeSql(sql, params)

      var maxCount = 0
      var result = []
      for (var i = 0; i < results.rows.length; i++) {
        var row = results.rows.item(i)
        maxCount = Math.max(maxCount, row.count)
        result.push(row)
      }

      return { list: result, maxCount: maxCount }
    }, [])
  }

  function getCharacterStats(isOpponent) {
    log("get char stats")

    return readFromDb(function(tx) {
      var playerCol = isOpponent ? "p2" : "p"
      var opponentCol = isOpponent ? "p" : "p2"

      // gamesWon is the number of games P1 won, regardless of isOpponent parameter
      var gameEndedCondition = gameFilter.getGameEndedCondition()
      var winnerCondition = gameFilter.getWinnerCondition()

      var sql = qsTr("select
%1.charId charId,
count(distinct r.id) numGames,
sum(case when %3 then 1 else 0 end) gamesFinished,
sum(case when %4 then 1 else 0 end) gamesWon
from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and p.port != p2.port
where %2
group by %1.charId
order by %1.charId").arg(playerCol).arg(getFilterCondition()).arg(gameEndedCondition).arg(winnerCondition)

      var params = getFilterParams()

      var results = tx.executeSql(sql, params)

      var result = {}

      for (var i = 0; i < results.rows.length; i++) {
        var row = results.rows.item(i)

        var obj = row
        obj.id = row.charId
        obj.count = row.numGames
        obj.name = MeleeData.charNames[row.charId]

        result[row.charId] = obj
      }

      return result
    }, {})
  }

  function getStageStats() {
    log("get stage stats")

    return readFromDb(function(tx) {

      // gamesWon is the number of games P1 won, regardless of isOpponent parameter
      var gameEndedCondition = gameFilter.getGameEndedCondition()
      var winnerCondition = gameFilter.getWinnerCondition()

      var sql = qsTr("select
stageId,
count(distinct r.id) numGames,
sum(case when %2 then 1 else 0 end) gamesFinished,
sum(case when %3 then 1 else 0 end) gamesWon
from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and p.port != p2.port
where %1
group by stageId
order by stageId").arg(getFilterCondition()).arg(gameEndedCondition).arg(winnerCondition)

      var params = getFilterParams()

      var results = tx.executeSql(sql, params)

      var result = {}

      for (var i = 0; i < results.rows.length; i++) {
        var row = results.rows.item(i)

        var data = MeleeData.stageMap[row.stageId]

        if(!data) {
          // do not include unknown stages
          continue
        }

        var obj = row
        obj.id = row.stageId
        obj.name = data.name || "Unknown"
        obj.count = row.numGames
        obj.shortName = data.shortName || "Unknown"

        result[row.stageId] = obj
      }

      return result
    }, [])
  }

  function getTimeStats() {
    log("get time stats")

    return readFromDb(function(tx) {

      // gamesWon is the number of games P1 won, regardless of isOpponent parameter
      var gameEndedCondition = gameFilter.getGameEndedCondition()
      var winnerCondition = gameFilter.getWinnerCondition()

      var sql = qsTr("select
strftime('%Y-%m', date) yearMonth,
strftime('%m', date) month,
strftime('%Y', date) year,
count(distinct r.id) numGames,
sum(case when %2 then 1 else 0 end) gamesFinished,
sum(case when %3 then 1 else 0 end) gamesWon
from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and p.port != p2.port
where %1
group by yearMonth
order by yearMonth desc").arg(getFilterCondition()).arg(gameEndedCondition).arg(winnerCondition)

      var params = getFilterParams()

      var results = tx.executeSql(sql, params)

      var result = {}

      for (var i = 0; i < results.rows.length; i++) {
        var row = results.rows.item(i)

        var obj = row
        obj.id = row.yearMonth

        var months = dataModel.monthNames

        obj.section = row.year
        obj.name = months[parseInt(row.month) - 1]

        result[obj.id] = obj
      }

      return result
    }, [])
  }

  function getReplayList(max, start) {
    log("get replay list")

    return readFromDb(function(tx) {
      var winnerConditionP1 = gameFilter.getWinnerCondition("p", "p2")
      var winnerConditionP2 = gameFilter.getWinnerCondition("p2", "p")

      var sql = qsTr(
            "select
r.id replayId, r.date date, r.filePath filePath, r.duration duration, r.stageId stageId,
r.lrasPort lrasPort, r.userFlag userFlag, r.platform platform, r.slippiVersion slippiVersion,
r.matchId matchId, r.gameNumber gameNumber, r.tiebreakerNumber tiebreakerNumber, r.gameMode gameMode,
 p.s_startStocks startStocks,
 p.slippiName name1,  p.cssTag tag1,  p.slippiCode code1,  p.charIdOriginal char1,  p.skinId skin1,  p.port port1,  p.s_endStocks endStocks1,  p.s_endPercent endPercent1,
p2.slippiName name2, p2.cssTag tag2, p2.slippiCode code2, p2.charIdOriginal char2, p2.skinId skin2, p2.port port2, p2.s_endStocks endStocks2, p2.s_endPercent endPercent2,
(case when (%1) then p.port when (%2) then p2.port else -1 end) winnerPort
from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id
where p.port != p2.port and %3
group by r.id
order by r.date desc
limit ? offset ?"
            ).arg(winnerConditionP1).arg(winnerConditionP2).arg(getFilterCondition())

      var params = getFilterParams().concat([max, start])

      var results = tx.executeSql(sql, params)

      var result = []

      for (var i = 0; i < results.rows.length; i++) {
        var item = results.rows.item(i)

        item.date = new Date(item.date)
        item.name1 = item.name1 || item.tag1 || ("Player " + (item.port1 + 1))
        item.name2 = item.name2 || item.tag2 || ("Player " + (item.port2 + 1))

        result.push(item)
      }

      return result
    }, [])
  }

  function getUserFlag(replayId) {
    log("get user flag for", replayId)

    return readFromDb(function(tx) {
      var result = tx.executeSql("select userFlag from replays where id = ?", [replayId])

      return result.rows.length > 0 ? result.rows.item(0).userFlag : null
    }, null)
  }

  function setUserFlag(replayId, flagMask) {
    log("set user flag for", replayId, flagMask)

    db.transaction(function(tx) {
      var result = tx.executeSql("update replays set userFlag = ? where id = ?", [flagMask, replayId])

      log("result", result, result.rows.length)
    })
  }

  function getPunishList(max, start) {
    log("get punish list")

    // select * from replays r
    // join players p on p.replayId = r.id
    // join players p2 on p2.replayId = r.id and p.port != p2.port
    // join punishes pu on pu.replayId = r.id and pu.port = p.port
    // where p.slippiCode LIKE '%daft#455%' and pu.didKill = 1 and pu.damage > 80
    // and r.id in (select id from Replays r where r.hasData = 1 order by r.date desc limit 1000)
    // order by r.date

    return readFromDb(function(tx) {
      var sql = "select
pu.id id,
pu.numMoves numMoves, pu.openingDynamic openingDynamic,
pu.openingMoveId openingMoveId, pu.lastMoveId lastMoveId,
pu.didKill didKill, pu.killDirection killDirection,
pu.startFrame startFrame, pu.endFrame endFrame, pu.duration punishDuration,
pu.startPercent startPercent, pu.endPercent endPercent, pu.stocks stocks, pu.damage damage,
r.id replayId, r.date date, r.filePath filePath, r.duration duration, r.stageId stageId, r.winnerPort winnerPort,
r.lrasPort lrasPort, r.userFlag userFlag, r.platform platform, r.slippiVersion slippiVersion,
r.matchId matchId, r.gameNumber gameNumber, r.tiebreakerNumber tiebreakerNumber, r.gameMode gameMode,
 p.s_startStocks startStocks,
 p.slippiName name1,  p.slippiCode code1,  p.charIdOriginal char1,  p.skinId skin1,  p.port port1,  p.s_endStocks endStocks1,  p.s_endPercent endPercent1,
p2.slippiName name2, p2.slippiCode code2, p2.charIdOriginal char2, p2.skinId skin2, p2.port port2, p2.s_endStocks endStocks2, p2.s_endPercent endPercent2
from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and p.port != p2.port
left join punishes pu on pu.replayId = r.id and pu.port = p.port and " + punishFilter.getPunishFilterCondition() +
"where " + getFilterCondition() +
// note: to speed up the select, sub-select the first N replays, and then join those IDs to the other tables
//       thus also add the game filter condition and params another time
"and r.id in (
  select id from Replays r where " + gameFilter.getGameFilterCondition() + " order by r.date desc limit ? offset ?
)
order by r.date desc, pu.stocks desc"

      var params = punishFilter.getPunishFilterParams()
      .concat(getFilterParams())
      .concat(gameFilter.getGameFilterParams())
      .concat([max, start])

      var results = tx.executeSql(sql, params)

      var result = []

      for (var i = 0; i < results.rows.length; i++) {
        var item = results.rows.item(i)

        item.date = new Date(item.date)
        item.name1 = item.name1 || item.tag1 || ("Player " + (item.port1 + 1))
        item.name2 = item.name2 || item.tag2 || ("Player " + (item.port2 + 1))

        result.push(item)
      }

      return result
    }, [])
  }

  function getOpeningMoveSummary(isOpponent) {
    log("get opening move summary")

    return readFromDb(function(tx) {
      var playerCol = isOpponent ? "p2" : "p"

      var sql = qsTr("select
pu.openingMoveId openingMoveId, count(*) count,
sum(damage) damage, sum(numMoves) numMoves, sum(didKill) kills
from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and p.port != p2.port
join punishes pu on pu.replayId = r.id and pu.port = %1.port and " + punishFilter.getPunishFilterCondition() +
"where %2
group by pu.openingMoveId
order by count desc").arg(playerCol).arg(getFilterCondition())

      var params = punishFilter.getPunishFilterParams().concat(getFilterParams())

      var results = tx.executeSql(sql, params)

      var result = []

      var totalCount = 0, totalDamage = 0, totalNumMoves = 0, totalKills = 0

      // group all grab related attacks:
      var grabItem = {
        count: 0, moveName: "Grab", moveNameShort: "Grab",
        damage: 0, numMoves: 0, kills: 0
      }

      for (var i = 0; i < results.rows.length; i++) {
        var item = results.rows.item(i)

        totalCount += item.count
        totalDamage += item.damage
        totalNumMoves += item.numMoves
        totalKills += item.kills

        // attack IDs pummel, throws, cargo throws:
        item.isGrab = item.openingMoveId >= 52 && item.openingMoveId <= 60

        if(item.isGrab) {
          grabItem.count += item.count
          grabItem.damage += item.damage
          grabItem.numMoves += item.numMoves
          grabItem.kills += item.kills
        }

        item.avgDamage = item.damage / item.count
        item.avgNumMoves = item.numMoves / item.count
        item.killRate = item.kills / item.count
        item.moveName = MeleeData.moveNames[item.openingMoveId]
        item.moveNameShort = MeleeData.moveNamesShort[item.openingMoveId]

        result.push(item)
      }

      grabItem.avgDamage = grabItem.damage / grabItem.count
      grabItem.avgNumMoves = grabItem.numMoves / grabItem.count
      grabItem.killRate = grabItem.kills / grabItem.count

      // ordered insert for grab item
      for (var j = 0; j < result.length; j++) {
        if(result[j].count <= grabItem.count) {
          result.splice(j, 0, grabItem)
          break
        }
      }

      return {
        totalCount: totalCount,
        avgDamage: totalDamage / totalCount,
        avgNumMoves: totalNumMoves / totalCount,
        killRate: totalKills / totalCount,
        openingMoves: result
      }
    }, [])
  }

  function getStockSummary(gameId, ports) {
    log("get stock summary", gameId, ports)

    return readFromDb(function(tx) {
      var select = "select
count(*) numPunishes, sum(damage) totalDamage, stocks stock, port,
max(didKill) killed,
min(startFrame) startFrame,     max(endFrame) endFrame,
min(startPercent) startPercent, max(endPercent) endPercent
from punishes
where replayId = ? and port = ?
group by stocks"

      // union the select twice and then order by stocks to have a "chronological" summary of the game's stocks
      var sql = qsTr("%1 union %2 order by endFrame").arg(select).arg(select)

      var params = [gameId, ports[0], gameId, ports[1]]

      var results = tx.executeSql(sql, params)

      // get data for last stock as there is no "killed" punish if you did not lost the last stock
      sql = qsTr(
            "select
r.id replayId, r.date date, r.filePath filePath, r.duration duration, r.stageId stageId,
r.lrasPort lrasPort, r.userFlag userFlag, r.platform platform, r.slippiVersion slippiVersion,
r.matchId matchId, r.gameNumber gameNumber, r.tiebreakerNumber tiebreakerNumber, r.gameMode gameMode,
 p.s_startStocks startStocks,
 p.slippiName name1,  p.cssTag tag1,  p.slippiCode code1,  p.charIdOriginal char1,  p.skinId skin1,  p.port port1,  p.s_endStocks endStocks1,  p.s_endPercent endPercent1,
p2.slippiName name2, p2.cssTag tag2, p2.slippiCode code2, p2.charIdOriginal char2, p2.skinId skin2, p2.port port2, p2.s_endStocks endStocks2, p2.s_endPercent endPercent2
from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id
where r.id = ? and p.port = ? and p2.port = ?")

      params = [gameId, ports[0], ports[1]]

      var gameResults = tx.executeSql(sql, params)
      var gameData = gameResults.rows.length > 0 ? gameResults.rows.item(0) : {}

      var result = []

      var lastStocks = {}

      for (var i = 0; i < results.rows.length; i++) {
        var item = results.rows.item(i)
        if(item.killed) {
          result.push(item)
        }
        if(item.port === gameData.port2 && item.stock === gameData.endStocks1) lastStocks[item.port] = item
        if(item.port === gameData.port1 && item.stock === gameData.endStocks2) lastStocks[item.port] = item
      }

      if(gameData.endStocks1 > 0) {
        var lastStock = lastStocks[gameData.port2] || {
          numPunishes: 0,
          startFrame: gameData.duration,
          startPercent: 0,
          killed: false
        }
        lastStock.totalDamage = gameData.endPercent1
        lastStock.stock = gameData.endStocks1
        lastStock.port = gameData.port2   // port of who did the punishes, so other player
        lastStock.endFrame = gameData.duration
        lastStock.endPercent = gameData.endPercent1
        result.push(lastStock)
      }

      if(gameData.endStocks2 > 0) {
        lastStock = lastStocks[gameData.port1] || {
          numPunishes: 0,
          startFrame: gameData.duration,
          startPercent: 0,
          killed: false
        }
        lastStock.totalDamage = gameData.endPercent2
        lastStock.stock = gameData.endStocks2
        lastStock.port = gameData.port1   // port of who did the punishes, so other player
        lastStock.endFrame = gameData.duration
        lastStock.endPercent = gameData.endPercent2
        result.push(lastStock)
      }

      return result
    }, [])
  }

  function getReplayYears() {
    log("get replay years")

    return readFromDb(function(tx) {
      var results = tx.executeSql("select distinct cast(strftime('%Y', date) as int) year from replays where date is not null")
      var result = []

      for (var i = 0; i < results.rows.length; i++) {
        var item = results.rows.item(i)
        result[i] = item.year
      }

      return result
    }, [])
  }

  function getReplayPlatforms() {
    log("get replay platforms")

    return readFromDb(function(tx) {
      var results = tx.executeSql("select distinct platform from replays where platform is not null and platform != ''")
      var result = []

      for (var i = 0; i < results.rows.length; i++) {
        var item = results.rows.item(i)
        result[i] = item.platform
      }

      return result
    }, [])
  }


  // utils

  // make SQL wildcards "(?, ? , ... ?)" with one ? for each item in the input list
  function makeSqlWildcards(list) {
    return "(" + list.map(_ => "?").join(",") + ")"
  }

  function log(...a) {
    if(dataBase.debugLog) {
      console.log(...a)
    }
  }
}
