import QtQuick 2.0
import Felgo 3.0

import Slippipedia 1.0

Item {
  id: dataBase

  property var debugLog: false
  property var debugLogSql: false

  // db
  property var db: dataModel.dataBaseConnection

  property FilterSettings filterSettings: null

  readonly property PlayerFilterSettings playerFilter: filterSettings.playerFilter
  readonly property PlayerFilterSettings opponentFilter: filterSettings.opponentFilter
  readonly property GameFilterSettings gameFilter: filterSettings.gameFilter
  readonly property PunishFilterSettings punishFilter: filterSettings.punishFilter

  function createTables(replay) {
    db.transaction(function (tx) {
      tx.executeSql("create table if not exists Replays (
id integer not null primary key,
hasData bool,
date date,
stageId integer,
winnerPort integer,
duration integer,
filePath text
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

      tx.executeSql("create index if not exists stage_index on replays(stageId)")

      tx.executeSql("create index if not exists char_index on players(charId)")
      tx.executeSql("create index if not exists player_replay_index on players(replayId)")
      tx.executeSql("create index if not exists player_replay_port_index on players(replayId, port)")

      tx.executeSql("create index if not exists punish_replay_index on punishes(replayId)")
      tx.executeSql("create index if not exists punish_port_index on punishes(port)")
      tx.executeSql("create index if not exists punish_replay_port_index on punishes(replayId, port)")

      // can only configure this globally, set like to be case sensitive:
      tx.executeSql("pragma case_sensitive_like = true")
    })
  }

  function clearAllData() {
    db.transaction(function(tx) {
      tx.executeSql("drop table if exists Replays")
      tx.executeSql("drop table if exists Players")
      tx.executeSql("drop table if exists Punishes")
    })
  }

  function analyzeReplay(fileName, replay) {
    var time = new Date().getTime()

    db.transaction(function(tx) {
      if(!replay) {
        tx.executeSql("insert or replace into Replays (filePath, hasData)
                       values (?, false)", [fileName])
        return
      }

      var winnerIndex = replay.winningPlayerIndex
      var winnerTag = winnerIndex >= 0 ? replay.players[winnerIndex].slippiName : null

      tx.executeSql("insert or replace into Replays (hasData, id, date, stageId, winnerPort, duration, filePath)
                     values (true, ?, ?, ?, ?, ?, ?)",
                    [
                      replay.uniqueId,
                      replay.date,
                      replay.stageId,
                      winnerIndex,
                      replay.gameDuration,
                      replay.filePath
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
                executeSql: function() {
                  log("Execute SQL:", arguments[0], arguments[1])
                  return tx.executeSql(...arguments)
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

    if(tDiff > 20) {
      log("Read from DB took", tDiff, "ms")
    }

    return res
  }

  function getFilterCondition(usePunishFilter = false) {
    return "(" +
        // game
        gameFilter.getGameFilterCondition() +
        // me
        " and " + playerFilter.getPlayerFilterCondition("p") +
        " and " + playerFilter.getCharFilterCondition("p.charId") +
        // opponent
        " and " + opponentFilter.getPlayerFilterCondition("p2") +
        " and " + opponentFilter.getCharFilterCondition("p2.charId") +
        // punish
        " and " + (usePunishFilter ? punishFilter.getPunishFilterCondition() : "true") +
        " and r.hasData = 1" + // only match replays that didn't fail parsing
        ")"
  }

  function getFilterParams(usePunishFilter = false) {
    // game, then me, then opponent
    return gameFilter.getGameFilterParams()
    .concat(playerFilter.getPlayerFilterParams())
    .concat(playerFilter.getCharFilterParams())
    .concat(opponentFilter.getPlayerFilterParams())
    .concat(opponentFilter.getCharFilterParams())
    .concat(usePunishFilter ? punishFilter.getPunishFilterParams() : [])
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

      var playerCol = isOpponent ? "p2" : "p"
      var opponentCol = isOpponent ? "p" : "p2"

      var sql = qsTr("select
count(r.id) count, avg(r.duration) avgDuration,
count(case when winnerPort >= 0 then 1 else null end) gameEndedCount,
count(case winnerPort when p.port then 1 else null end) winCount
from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and " + portCondition + "
where %1").arg(getFilterCondition())

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

      var sql = qsTr("select
count(r.id) count, avg(r.duration) avgDuration,
count(case when winnerPort >= 0 then 1 else null end) gameEndedCount,
count(case winnerPort when p.port then 1 else null end) winCount,
%2
from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and " + portCondition + "
where %1").arg(getFilterCondition()).arg(statColCondition)

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

    return readFromDb(function(tx) {
      var playerCol = isOpponent ? "p2" : "p"

      var sql = qsTr("select %1.slippiName slippiName, count(distinct r.id) c from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and p.port != p2.port
where %1.slippiName is not null and
%1.slippiName is not \"\" and %2
group by %1.slippiName
order by c desc
limit ?").arg(playerCol).arg(getFilterCondition())

      var params = getFilterParams().concat([max])

      var results = tx.executeSql(sql, params)

      var result = []
      for (var i = 0; i < results.rows.length; i++) {
        result.push({
                      text: results.rows.item(i).slippiName,
                      count: results.rows.item(i).c
                    })
      }

      return result
    }, [])
  }

  function getTopSlippiCodes(isOpponent, max) {
    log("get top codes opponent")

    return readFromDb(function(tx) {
      var playerCol = isOpponent ? "p2" : "p"

      var sql = qsTr("select %1.slippiCode slippiCode, count(distinct r.id) c from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and p.port != p2.port
where %1.slippiCode is not null and
%1.slippiCode is not \"\" and %2
group by %1.slippiCode
order by c desc
limit ?").arg(playerCol).arg(getFilterCondition())

      var params = getFilterParams().concat([max])

      var results = tx.executeSql(sql, params)

      var result = []
      for (var i = 0; i < results.rows.length; i++) {
        result.push({
                      text: results.rows.item(i).slippiCode,
                      count: results.rows.item(i).c
                    })
      }

      return result
    }, [])
  }

  function getCharacterStats(isOpponent) {
    log("get char stats")

    return readFromDb(function(tx) {
      var playerCol = isOpponent ? "p2" : "p"

      // gamesWon is the number of games P1 won, regardless of isOpponent parameter
      var sql = qsTr("select
%1.charId charId,
count(distinct r.id) numGames,
sum(case when r.winnerPort >= 0 then 1 else 0 end) gamesFinished,
sum(case when r.winnerPort = p.port then 1 else 0 end) gamesWon
from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and p.port != p2.port
where %2
group by %1.charId
order by %1.charId").arg(playerCol).arg(getFilterCondition())

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
      var sql = "select
stageId,
count(distinct r.id) numGames,
sum(case when r.winnerPort >= 0 then 1 else 0 end) gamesFinished,
sum(case when r.winnerPort = p.port then 1 else 0 end) gamesWon
from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and p.port != p2.port
where " + getFilterCondition() + "
group by stageId
order by stageId"

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
      var sql = "select
strftime('%Y-%m', date) yearMonth,
strftime('%m', date) month,
strftime('%Y', date) year,
count(distinct r.id) numGames,
sum(case when r.winnerPort >= 0 then 1 else 0 end) gamesFinished,
sum(case when r.winnerPort = p.port then 1 else 0 end) gamesWon
from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and p.port != p2.port
where " + getFilterCondition() + "
group by yearMonth
order by yearMonth desc"

      var params = getFilterParams()

      var results = tx.executeSql(sql, params)

      var result = {}

      for (var i = 0; i < results.rows.length; i++) {
        var row = results.rows.item(i)

        var obj = row
        obj.id = row.yearMonth

        var months = [
              "January", "February", "March", "April", "May", "June",
              "July", "August", "September", "October", "November", "December"
            ]

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
      var sql = "select
r.id id, r.date date, r.filePath filePath, r.duration duration, r.stageId stageId, r.winnerPort winnerPort,
 p.slippiName name1,  p.slippiCode code1,  p.charIdOriginal char1,  p.skinId skin1,  p.port port1,  p.s_endStocks endStocks1,  p.s_endPercent endPercent1,
p2.slippiName name2, p2.slippiCode code2, p2.charIdOriginal char2, p2.skinId skin2, p2.port port2, p2.s_endStocks endStocks2, p2.s_endPercent endPercent2
from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id
where p.port != p2.port and " + getFilterCondition() + "
group by r.id
order by r.date desc
limit ? offset ?"

      var params = getFilterParams().concat([max, start])

      var results = tx.executeSql(sql, params)

      var result = []

      for (var i = 0; i < results.rows.length; i++) {
        var item = results.rows.item(i)

        item.date = new Date(item.date)

        result.push(item)
      }

      return result
    }, [])
  }

  function getPunishList(max, start) {
    log("get punish list")

    return readFromDb(function(tx) {
      var sql = "select
pu.id id,
pu.numMoves numMoves, pu.openingDynamic openingDynamic,
pu.openingMoveId openingMoveId, pu.lastMoveId lastMoveId,
pu.didKill didKill, pu.killDirection killDirection,
pu.startFrame startFrame, pu.endFrame endFrame, pu.duration punishDuration,
pu.startPercent startPercent, pu.endPercent endPercent, pu.stocks stocks, pu.damage damage,
r.id replayId, r.date date, r.filePath filePath, r.duration duration, r.stageId stageId, r.winnerPort winnerPort,
 p.slippiName name1,  p.slippiCode code1,  p.charIdOriginal char1,  p.skinId skin1,  p.port port1,  p.s_endStocks endStocks1,  p.s_endPercent endPercent1,
p2.slippiName name2, p2.slippiCode code2, p2.charIdOriginal char2, p2.skinId skin2, p2.port port2, p2.s_endStocks endStocks2, p2.s_endPercent endPercent2
from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and p.port != p2.port
join punishes pu on pu.replayId = r.id and pu.port = p.port
where " + getFilterCondition(true) + "
order by r.date desc
limit ? offset ?"

      var params = getFilterParams(true).concat([max, start])

      var results = tx.executeSql(sql, params)

      var result = []

      for (var i = 0; i < results.rows.length; i++) {
        var item = results.rows.item(i)

        item.date = new Date(item.date)

        result.push(item)
      }

      return result
    }, [])
  }

  // utils

  // make SQL wildcards "(?, ? , ... ?)" with one ? for each item in the input list
  function makeSqlWildcards(list) {
    return "(" + list.map(_ => "?").join(",") + ")"
  }

  function log() {
    if(debugLog) {
      console.log(...arguments)
    }
  }
}
