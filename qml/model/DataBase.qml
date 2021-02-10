import QtQuick 2.0
import QtQuick.LocalStorage 2.12
import Felgo 3.0

Item {
  id: dataBase

  property var debugLog: false

  // db
  property var db: null

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
port integer,
replayId integer,
slippiName text,
slippiCode text,
cssTag text,
charId integer,
startStocks integer,
endStocks integer,
endPercent integer,
isWinner bool,
primary key(replayId, port),
foreign key(replayId) references replays(id)
    )")

    tx.executeSql("create index if not exists char_index on players(charId)")
    tx.executeSql("create index if not exists stage_index on replays(stageId)")
    tx.executeSql("create index if not exists player_replay_index on players(replayId)")

    // can only configure this globally, set like to be case sensitive:
    tx.executeSql("pragma case_sensitive_like = true")
  }

  function clearAllData() {
    db.transaction(function(tx) {
      tx.executeSql("delete from Replays")
      tx.executeSql("delete from Players")
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
        tx.executeSql("insert or replace into Players (port, replayId, charId, slippiName, slippiCode, cssTag, startStocks, endStocks, endPercent, isWinner)
                       values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                      [
                        player.port,
                        replay.uniqueId,
                        player.charId,
                        player.slippiName,
                        player.slippiCode,
                        player.inGameTag,
                        player.startStocks,
                        player.endStocks,
                        player.endPercent,
                        player.isWinner
                      ])
      })
    })

    numFilesSucceeded++
  }

  function readFromDb(callback, defaultValue) {
    var time = new Date().getTime()

    var res = defaultValue

    db.readTransaction(function(tx) {
      try {
         res = callback(tx)
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

  function getPlayerFilterCondition(codeFilter, nameFilter) {
    var cf = makeFilterCondition("p.slippiCode", codeFilter)
    var nf = makeFilterCondition("p.slippiName", nameFilter)

    if(codeFilter.filterText && nameFilter.filterText) {
      return qsTr("(%1 %2 %3)")
        .arg(cf)
        .arg(filterCodeAndName ? "and" : "or")
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

  function getStageFilterCondition(stageId) {
    if(stageId === 0) {
      return "(r.stageId not in (%1))".arg(MeleeData.stageIds.map(_ => "?").join(",")) // add one question mark placeholder per argument
    }
    else if(stageId > 0) {
      return "(r.stageId = ?)"
    }
    else {
      return "true"
    }
  }

  function getCharFilterCondition(charId) {
    if(charId >= 0) {
      return "(p.charId = ?)"
    }
    else {
      return "true"
    }
  }

  function getFilterCondition() {
    return "(" +
        getPlayerFilterCondition(filterSlippiCode, filterSlippiName) +
        " and " + getStageFilterCondition(filterStageId) +
        " and " + getCharFilterCondition(filterCharId) +
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

  function getStageFilterParams(stageId) {
    if(stageId === 0) {
      return MeleeData.stageIds
    }
    else if(stageId > 0) {
      return [stageId]
    }
    else {
      return []
    }
  }

  function getCharFilterParams(charId) {
    if(charId >= 0) {
      return [charId]
    }
    else {
      return []
    }
  }

  function getFilterParams() {
    return getPlayerFilterParams(filterSlippiCode, filterSlippiName)
      .concat(getStageFilterParams(filterStageId))
      .concat(getCharFilterParams(filterCharId))
  }

  function getNumReplays() {
    return readFromDb(function(tx) {
      var results = tx.executeSql("select count(*) c from Replays")

      return results.rows.item(0).c
    }, 0)
  }

  function getNumReplaysFiltered() {
    log("get num replays")

    return readFromDb(function(tx) {
      var sql = "select count(distinct replayId) c from replays r
join players p on p.replayId = r.id
where " + getFilterCondition()

      //console.log("get filtered replays with sql", sql, getFilterParams())

      var results = tx.executeSql(sql, getFilterParams())

      //console.log("count", results.rows.item(0).c)

      return results.rows.item(0).c
    }, 0)
  }

  function getNumReplaysFilteredWithResult() {
    log("get num filtered")

    return readFromDb(function(tx) {
      var results = tx.executeSql("select count(distinct replayId) c from replays r
join players p on p.replayId = r.id
 where r.winnerPort >= 0 and " + getFilterCondition(), getFilterParams())

      return results.rows.item(0).c
    }, 0)
  }

  function getNumReplaysFilteredWon() {
    log("get num replays won")

    return readFromDb(function(tx) {
      var results = tx.executeSql("select count(distinct replayId) c from replays r
 join players p on p.replayId = r.id
where p.isWinner and " + getFilterCondition(), getFilterParams())

      return results.rows.item(0).c
    }, 0)
  }

  function getNumReplaysFilteredWithCharacter(charId) {
    log("get num with char")

    return readFromDb(function(tx) {
      var results = tx.executeSql("select count(distinct replayId) c from replays r
 join players p on p.replayId = r.id
where p.charId = ? and " + getFilterCondition(), [charId].concat(getFilterParams()))

      return results.rows.item(0).c
    }, 0)
  }

  function getAverageGameDuration() {
    log("get avg duration")

    return readFromDb(function(tx) {
      var results = tx.executeSql("select avg(duration) d from Replays")

      return results.rows.item(0).d || 0
    }, 0)
  }

  function getStageAmount(stageId) {
    log("get stage amount")

    return readFromDb(function(tx) {
      var results = tx.executeSql("select count(distinct replayId) c from Replays r
join Players p on p.replayId = r.id
where stageId = ? and " + getFilterCondition(),
                                  [stageId].concat(getFilterParams()))

      return results.rows.item(0).c
    }, 0)
  }

  function getOtherStageAmount() {
    log("get other stage amount")

    return readFromDb(function(tx) {
      var results = tx.executeSql(qsTr("select count(distinct replayId) c from Replays r
join Players p on p.replayId = r.id
where stageId not in (%1) and " + getFilterCondition())
                                  .arg(MeleeData.stageIds.map(_ => "?").join(",")), // add one question mark placeholder per argument
                                  MeleeData.stageIds.concat(getFilterParams()))

      return results.rows.item(0).c
    }, 0)
  }

  function getTopPlayerTags(max) {
    log("get top tags")

    return readFromDb(function(tx) {
      var sql = "select slippiName, count(distinct replayId) c from players p
join replays r on p.replayId = r.id
where slippiName is not null and
slippiName is not \"\" and " + getFilterCondition() + "
group by slippiName
order by c desc
limit ?"

      var params = getFilterParams().concat([max])

      var results = tx.executeSql(sql, params)

      var result = []
      for (var i = 0; i < results.rows.length; i++) {
        result.push({
                      tag: results.rows.item(i).slippiName,
                      count: results.rows.item(i).c
                    })
      }

      return result
    }, [])
  }

  function getCharacterStats() {
    log("get char stats")

    return readFromDb(function(tx) {
      var sql = "select charId, count(distinct replayId) c from players p
join replays r on p.replayId = r.id
where " + getFilterCondition() + "
group by charId
order by c desc"

      var params = getFilterParams()

      var results = tx.executeSql(sql, params)

      var result = []

      for (var i = 0; i < results.rows.length; i++) {
        var row = results.rows.item(i)

        result.push({
                      id: row.charId,
                      count: row.c,
                      name: MeleeData.charNames[row.charId]
                    })
      }

      return result
    }, [])
  }

  function getStageStats() {
    log("get stage stats")

    return readFromDb(function(tx) {
      var sql = "select stageId, count(distinct replayId) c from players p
join replays r on p.replayId = r.id
where " + getFilterCondition() + "
group by stageId
order by c desc"

      var params = getFilterParams()

      var results = tx.executeSql(sql, params)

      var result = []

      for (var i = 0; i < results.rows.length; i++) {
        var row = results.rows.item(i)

        var data = MeleeData.stageMap[row.stageId]

        if(!data) {
          // do not include unknown stages
          continue
        }

        result.push({
                      id: row.stageId,
                      count: row.c,
                      name: data.name || "Unknown",
                      shortName: data.shortName || "Unknown"
                    })
      }

      return result
    }, [])
  }

  function getReplayList(max, start) {
    log("get list")

    return readFromDb(function(tx) {
      var sql = "select
r.id id, r.date date, r.filePath filePath, r.duration duration,
p.slippiName name1, p.slippiCode code1, p.charId char1, p.endStocks endStocks1,
p2.slippiName name2, p2.slippiCode code2, p2.charId char2, p2.endStocks endStocks2
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

  function log() {
    if(debugLog) {
      console.log(...arguments)
    }
  }
}
