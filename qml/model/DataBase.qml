import QtQuick 2.0
import QtQuick.LocalStorage 2.12
import Felgo 3.0

Item {
  id: dataBase

  property var debugLog: false

  // db
  property var db: null

  property PlayerFilterSettings playerFilter: null
  property PlayerFilterSettings opponentFilter: null
  property GameFilterSettings gameFilter: null

  Component.onCompleted: {
    db = LocalStorage.openDatabaseSync("SlippiStatsDB", "1.0", "Slippi Stats DB", 1000000)

    db.transaction(createTablesTx)

    console.log("DB open", db, db.version)
  }

  function createTablesTx(tx) {
    tx.executeSql("create table if not exists Replays (
id integer not null primary key,
date date,
stageId integer,
winnerPort integer,
duration integer,
filePath text
    )")

    tx.executeSql("create table if not exists Players (
replayId integer,

port integer,
isWinner bool,

slippiName text,
slippiCode text,
cssTag text,

charId integer,
charIdOriginal integer,
skinId integer,

startStocks integer,
endStocks integer,
endPercent integer,
damageDealt real,

numTaunts integer,

lCancels integer,
lCancelsMissed integer,
numLedgedashes integer,
avgGalint real,

edgeCancelAerials integer,
edgeCancelSpecials integer,
teeterCancelAerials integer,
teeterCancelSpecials integer,

primary key(replayId, port),
foreign key(replayId) references replays(id)
    )")

    tx.executeSql("create index if not exists char_index on players(charId)")
    tx.executeSql("create index if not exists stage_index on replays(stageId)")
    tx.executeSql("create index if not exists player_replay_index on players(replayId)")
    tx.executeSql("create index if not exists player_replay_port_index on players(replayId, port)")

    // can only configure this globally, set like to be case sensitive:
    tx.executeSql("pragma case_sensitive_like = true")
  }

  function clearAllData() {
    db.transaction(function(tx) {
      tx.executeSql("drop table Replays")
      tx.executeSql("drop table Players")

      createTablesTx(tx)
    })
  }

  function analyzeReplay(fileName, replay) {
    db.transaction(function(tx) {
      var winnerIndex = replay.winningPlayerIndex
      var winnerTag = winnerIndex >= 0 ? replay.players[winnerIndex].slippiName : null

      tx.executeSql("insert or replace into Replays (id, date, stageId, winnerPort, duration, filePath)
                     values (?, ?, ?, ?, ?, ?)",
                    [
                      replay.uniqueId,
                      replay.date,
                      replay.stageId,
                      winnerIndex,
                      replay.gameDuration,
                      replay.filePath
                    ])

      replay.players.forEach(function(player) {

        var charIdOriginal = player.charId

        // store sheik as zelda so matching is easier. keep original id for reference.
        var charId = charIdOriginal === 19 ? 18 : charIdOriginal

        var params = [
              replay.uniqueId, player.port, player.isWinner,
              charId, charIdOriginal, player.charSkinId,
              player.slippiName, player.slippiCode, player.inGameTag,
              player.startStocks, player.endStocks, player.endPercent, player.damageDealt,
              player.numTaunts,
              player.lCancels, player.lCancelsMissed, player.numLedgedashes, player.avgGalint,
              player.edgeCancelAerials, player.edgeCancelSpecials,
              player.teeterCancelAerials, player.teeterCancelSpecials,
            ]

        tx.executeSql("insert or replace into Players (
replayId, port, isWinner,
charId, charIdOriginal, skinId,
slippiName, slippiCode, cssTag,
startStocks, endStocks, endPercent, damageDealt,
numTaunts,
lCancels, lCancelsMissed, numLedgedashes, avgGalint,
edgeCancelAerials, edgeCancelSpecials,
teeterCancelAerials, teeterCancelSpecials
)
values " + makeSqlWildcards(params), params)
      })
    })

    numFilesSucceeded++
  }

  function readFromDb(callback, defaultValue) {
    var time = new Date().getTime()

    var res = defaultValue

    db.readTransaction(function(tx) {
      try {
        var modifiedTx = debugLog
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

        console.warn("DB error", ex)
      }
    })

    var tDiff = new Date().getTime() - time

    if(tDiff > 20) {
      log("Read from DB took", tDiff, "ms")
    }

    return res
  }

  function getPlayerFilterCondition(codeFilter, nameFilter, tableName) {
    var cf = makeFilterCondition(tableName + ".slippiCode", codeFilter)
    var nf = makeFilterCondition(tableName + ".slippiName", nameFilter)

    if(codeFilter.filterText && nameFilter.filterText) {
      return qsTr("(%1 %2 %3)")
        .arg(cf)
        .arg(playerFilter.filterCodeAndName ? "and" : "or")
        .arg(nf)
    }
    else if(codeFilter.filterText) {
      return qsTr("(%1)").arg(cf)
    }
    else if(nameFilter.filterText) {
      return qsTr("(%1)").arg(nf)
    }
    else {
      return "true"
    }
  }

  function getGameFilterCondition(stageIds, winnerPlayerIndex) {
    var winnerCondition = ""
    if(winnerPlayerIndex === -2) {
      // check for tie
      winnerCondition = "r.winnerPort < 0"
    }
    else if(winnerPlayerIndex === -1) {
      // check for either player wins (no tie)
      winnerCondition = "r.winnerPort >= 0"
    }
    else if(winnerPlayerIndex === 0) {
      // p = matched player
      winnerCondition = "r.winnerPort = p.port"
    }
    else if(winnerPlayerIndex === 1) {
      // p2 = matched opponent
      winnerCondition = "r.winnerPort = p2.port"
    }

    var stageCondition = ""
    if(stageIds && stageIds.length > 0) {
      stageCondition = "r.stageId in " + makeSqlWildcards(stageIds)
    }

    var condition =  winnerCondition && stageCondition
        ? (winnerCondition + " and " + stageCondition)
        : (winnerCondition || stageCondition || "true")
    return "(" + condition + ")"
  }

  function getCharFilterCondition(charIds, colName) {
    if(charIds && charIds.length > 0) {
      return "(" + colName + " in " + makeSqlWildcards(charIds) + ")"
    }
    else {
      return "true"
    }
  }

  function getFilterCondition() {
    return "(" +
        // game
        getGameFilterCondition(gameFilter.stageIds, gameFilter.winnerPlayerIndex) +
        // me
        " and " + getPlayerFilterCondition(playerFilter.slippiCode, playerFilter.slippiName, "p") +
        " and " + getCharFilterCondition(playerFilter.charIds, "p.charId") +
        // opponent
        " and " + getPlayerFilterCondition(opponentFilter.slippiCode, opponentFilter.slippiName, "p2") +
        " and " + getCharFilterCondition(opponentFilter.charIds, "p2.charId") +
        ")"
  }

  function getPlayerFilterParams(slippiCode, slippiName) {
    var codeValue = mw(slippiCode)
    var nameValue = mw(slippiName)

    if(slippiCode.filterText && slippiName.filterText) {
      return [codeValue, nameValue]
    }
    else if(slippiCode.filterText) {
      return [codeValue]
    }
    else if(slippiName.filterText) {
      return [nameValue]
    }
    else {
      return []
    }
  }

  function getGameFilterParams(stageIds, winnerPlayerIndex) {
    if(stageIds && stageIds.length > 0) {
      return stageIds
    }
    else {
      return []
    }
  }

  function getCharFilterParams(charIds) {
    if(charIds && charIds.length > 0) {
      return charIds
    }
    else {
      return []
    }
  }

  function getFilterParams() {
    // game, then me, then opponent
    return getGameFilterParams(gameFilter.stageIds, gameFilter.winnerPlayerIndex)
    .concat(getPlayerFilterParams(playerFilter.slippiCode, playerFilter.slippiName))
    .concat(getCharFilterParams(playerFilter.charIds))
    .concat(getPlayerFilterParams(opponentFilter.slippiCode, opponentFilter.slippiName))
    .concat(getCharFilterParams(opponentFilter.charIds))
  }

  function getNumReplays() {
    return readFromDb(function(tx) {
      var results = tx.executeSql("select count(*) c from Replays")

      return results.rows.item(0).c
    }, 0)
  }

  function getNewReplays(fileList) {
    // find all files in fileList that do not have a replay in the database

    // do in 1 iteration instead of n*m:
    // -> sort fileList, and get sorted file list from DB
    // then iterate both lists and return all files only contained in the first

    // probably fails if files get renamed or moved

    return readFromDb(function(tx) {
      var results = tx.executeSql("select filePath from Replays order by filePath")

      fileList.sort()

      var fli = 0
      var rli = 0

      var newFiles = []
      while(fli < fileList.length) {
        var file = fileList[fli]
        var dbFile = rli < results.rows.length ? results.rows.item(rli).filePath : ""

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
    }, 0)
  }

  function getReplayStats() {
    log("get replay stats")

    return readFromDb(function(tx) {
      // if no player filter specified, match smaller port for P1
      var portCondition = playerFilter.hasPlayerFilter
          ? "p.port != p2.port" : "p.port < p2.port"

      var subSql = "select
count(r.id) count, avg(r.duration) avgDuration,
count(case when winnerPort >= 0 then 1 else null end) gameEndedCount,
count(case winnerPort when p.port then 1 else null end) winCount,
sum(p.lCancels) lc, sum(p.lCancelsMissed) lcm,
sum(p.numTaunts) numTaunts,
sum(p.damageDealt) damageDealt,
sum(p.startStocks - p.endStocks) totalStocksLost,
sum(p.edgeCancelAerials) edgeCancelAerials,
sum(p.edgeCancelSpecials) edgeCancelSpecials,
sum(p.teeterCancelAerials) teeterCancelAerials,
sum(p.teeterCancelSpecials) teeterCancelSpecials,
sum(p.numLedgedashes) numLedgedashes,
sum(p.numLedgedashes * p.avgGalint) totalGalint,
sum(p2.lCancels) lco, sum(p2.lCancelsMissed) lcmo,
sum(p2.numTaunts) numTauntsOpponent,
sum(p2.damageDealt) damageDealtOpponent,
sum(p2.startStocks - p2.endStocks) totalStocksLostOpponent,
sum(p2.numLedgedashes) numLedgedashesOpponent,
sum(p2.numLedgedashes * p2.avgGalint) totalGalintOpponent,
sum(p2.edgeCancelAerials) edgeCancelAerialsOpponent,
sum(p2.edgeCancelSpecials) edgeCancelSpecialsOpponent,
sum(p2.teeterCancelAerials) teeterCancelAerialsOpponent,
sum(p2.teeterCancelSpecials) teeterCancelSpecialsOpponent
from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and " + portCondition + "
where " + getFilterCondition()

      // compute extra stats directly in SQL based on expressions - needs a sub query
      var sql = "select *,
lc lCancels, lcm lCancelsMissed,
(lc * 1.0 / (lc + lcm)) lCancelRate,
lco lCancelsOpponent, lcmo lCancelsMissedOpponent,
(lco * 1.0 / (lco + lcmo)) lCancelRateOpponent
from (" + subSql + ")"

      var results = tx.executeSql(sql, getFilterParams())

      return results.rows.item(0)
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

  function getTopPlayerTags(max) {
    log("get top tags")

    return readFromDb(function(tx) {
      var sql = "select p.slippiName slippiName, count(distinct r.id) c from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and p.port != p2.port
where p.slippiName is not null and
p.slippiName is not \"\" and " + getFilterCondition() + "
group by p.slippiName
order by c desc
limit ?"

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

  function getTopPlayerTagsOpponent(max) {
    log("get top tags opponent")

    return readFromDb(function(tx) {
      var sql = "select p2.slippiName slippiName, count(distinct r.id) c from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and p.port != p2.port
where p2.slippiName is not null and
p2.slippiName is not \"\" and " + getFilterCondition() + "
group by p2.slippiName
order by c desc
limit ?"

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

  function getTopSlippiCodesOpponent(max) {
    log("get top codes opponent")

    return readFromDb(function(tx) {
      var sql = "select p2.slippiCode slippiCode, count(distinct r.id) c from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and p.port != p2.port
where p2.slippiCode is not null and
p2.slippiCode is not \"\" and " + getFilterCondition() + "
group by p2.slippiCode
order by c desc
limit ?"

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

  function getCharacterStats() {
    log("get char stats")

    return readFromDb(function(tx) {
      var sql = "select p.charId charId, count(distinct r.id) c from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and p.port != p2.port
where " + getFilterCondition() + "
group by p.charId
order by p.charId"

      var params = getFilterParams()

      var results = tx.executeSql(sql, params)

      var result = {}

      for (var i = 0; i < results.rows.length; i++) {
        var row = results.rows.item(i)

        result[row.charId] = {
          id: row.charId,
          count: row.c,
          name: MeleeData.charNames[row.charId]
        }
      }

      return result
    }, {})
  }

  function getCharacterStatsOpponent() {
    log("get oppo char stats")

    return readFromDb(function(tx) {
      var sql = "select p2.charId charId, count(distinct r.id) c from replays r
join players p on p.replayId = r.id
join players p2 on p2.replayId = r.id and p2.port != p.port
where " + getFilterCondition() + "
group by p2.charId
order by p2.charId"

      var params = getFilterParams()

      var results = tx.executeSql(sql, params)

      var result = {}

      for (var i = 0; i < results.rows.length; i++) {
        var row = results.rows.item(i)

        result[row.charId] = {
          id: row.charId,
          count: row.c,
          name: MeleeData.charNames[row.charId]
        }
      }

      return result
    }, {})
  }

  function getStageStats() {
    log("get stage stats")

    return readFromDb(function(tx) {
      var sql = "select stageId, count(distinct r.id) c from replays r
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

        result[row.stageId] = {
          id: row.stageId,
          count: row.c,
          name: data.name || "Unknown",
          shortName: data.shortName || "Unknown"
        }
      }

      return result
    }, [])
  }

  function getReplayList(max, start) {
    log("get list")

    return readFromDb(function(tx) {
      var sql = "select
r.id id, r.date date, r.filePath filePath, r.duration duration, r.stageId stageId, r.winnerPort winnerPort,
p.slippiName name1, p.slippiCode code1, p.charIdOriginal char1, p.skinId skin1, p.endStocks endStocks1, p.port port1,
p2.slippiName name2, p2.slippiCode code2, p2.charIdOriginal char2, p2.skinId skin2, p2.endStocks endStocks2, p2.port port2
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

  // utils

  function makeFilterCondition(colName, filter) {
    if(filter.matchPartial && filter.matchCase) {
      // case sensitive wildcard (case sensitive like must be ON)
      return colName + " like ?"
    }
    else if(filter.matchPartial) {
      // case insensitive wildcard -> compare upper
      return qsTr("upper(%1) like upper(?)").arg(colName)
    }
    else if(filter.matchCase) {
      // case sensitive comparison
      return colName + " = ?"
    }
    else {
      // case insensitive comparison
      return colName + " = ? collate nocase"
    }
  }

  // make SQL wildcard if filter.matchPartial is true
  function mw(filter) {
    return filter.matchPartial ? "%" + filter.filterText + "%" : filter.filterText
  }

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
