import QtQuick 2.0

import Qt.labs.settings 1.1
import QtQuick.LocalStorage 2.12

import Slippi 1.0

Item {
  id: dataModel

  // replay settings
  property alias replayFolder: settings.replayFolder
  readonly property var allFiles: Utils.listFiles(replayFolder, ["*.slp"], true)

  // filtering settings
  property alias slippiCode: settings.slippiCode
  property alias slippiName: settings.slippiName
  readonly property bool hasSlippiCode: slippiCode != "" || slippiName != ""
  property int stageId: 0 // -1 = "other" stages

  readonly property string filterDisplayText: {
    var pText
    if(slippiCode && slippiName) {
      pText = qsTr("%1/%2").arg(slippiCode).arg(slippiName)
    }
    else {
      pText = slippiCode || slippiName || ""
    }

    var sText
    if(stageId < 0) {
      sText = "Other stage"
    }
    else if(stageId > 0) {
      sText = "Stage: " + stageMap[stageId].name
    }

    return sText && pText ? (pText + ", " + sText) : sText || pText || "(nothing)"
  }

  // db
  property var db: null
  property int dbUpdater: 0

  // stats
  readonly property int totalReplays: getNumReplays(dbUpdater)
  readonly property int totalReplaysFiltered: getNumReplaysFiltered(dbUpdater, slippiCode, slippiName, stageId)
  readonly property int totalReplaysFilteredWithResult: getNumReplaysFilteredWithResult(dbUpdater, slippiCode, slippiName, stageId)
  readonly property int totalReplaysFilteredWon: getNumReplaysFilteredWon(dbUpdater, slippiCode, slippiName, stageId)
  readonly property int totalReplaysFilteredWithTie: totalReplaysFiltered - totalReplaysFilteredWithResult

  readonly property real tieRate: dataModel.totalReplaysFilteredWithTie / dataModel.totalReplaysFiltered
  readonly property real winRate: dataModel.totalReplaysFilteredWon / dataModel.totalReplaysFilteredWithResult

  // analyze progress
  property bool progressCancelled: false
  property int numFilesSucceeded: 0
  property int numFilesFailed: 0
  property int numFilesProcessing: 0
  readonly property int numFilesProcessed: numFilesSucceeded + numFilesFailed
  readonly property bool isProcessing: !progressCancelled && numFilesProcessed < numFilesProcessing
  readonly property real processProgress: isProcessing ? numFilesProcessed / numFilesProcessing : 0

  // data structs
  readonly property var stageMap: {
    32: { id: 32, name: "Final Destination", shortName: "FD" },
    31: { id: 31, name: "Battlefield", shortName: "BF" },
    3: { id: 3, name: "Pokémon Stadium", shortName: "PS" },
    28: { id: 28, name: "Dreamland", shortName: "DL" },
    2: { id: 2, name: "Fountain of Dreams", shortName: "FoD" },
    8: { id: 8, name: "Yoshi's Story", shortName: "YS" },
  }

  readonly property var stageData: Object.values(stageMap)

  readonly property var stageIds: stageData.map(obj => obj.id)

  onIsProcessingChanged: {
    if(!isProcessing) {
      dbUpdaterChanged() // refresh bindings
    }
  }

  Component.onCompleted: {
    db = LocalStorage.openDatabaseSync("SlippiStatsDB", "1.0", "Slippi Stats DB", 1000000)

    db.transaction(createTablesTx)

    console.log("DB open", db, db.version)
  }

  Settings {
    id: settings
    property string replayFolder
    property string slippiCode
    property string slippiName
  }

  SlippiParser {
    id: parser

    onReplayParsed: analyzeReplay(filePath, replay)
    onReplayFailedToParse: {
      console.warn("Could not parse replay", filePath, ":", errorMessage)
      numFilesFailed++
    }
  }

  function createTablesTx(tx) {
    tx.executeSql("create table if not exists Replays (
id integer not null primary key,
date date,
stageName text,
stageId integer,
winnerPort integer,
duration integer
    )")

    tx.executeSql("create table if not exists Players (
port integer,
replayId integer,
slippiName text,
slippiCode text,
cssTag text,
startStocks integer,
endStocks integer,
endPercent integer,
isWinner bool,
primary key(replayId, port),
foreign key(replayId) references replays(id)
    )")
  }

  function analyzeReplay(fileName, replay) {
    db.transaction(function(tx) {
      var winnerIndex = replay.winningPlayerIndex
      var winnerTag = winnerIndex >= 0 ? replay.players[winnerIndex].slippiName : null

      tx.executeSql("insert or replace into Replays (id, date, stageName, stageId, winnerPort, duration)
                     values (?, ?, ?, ?, ?, ?)",
                    [
                      replay.uniqueId,
                      replay.date,
                      replay.stageName,
                      replay.stageId,
                      winnerIndex,
                      replay.gameDuration
                    ])

      replay.players.forEach(function(player) {
        tx.executeSql("insert or replace into Players (port, replayId, slippiName, slippiCode, cssTag, startStocks, endStocks, endPercent, isWinner)
                       values (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                      [
                        player.port,
                        replay.uniqueId,
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

  function parseReplays(replayFiles) {
    numFilesSucceeded = 0
    numFilesFailed = 0
    numFilesProcessing = replayFiles.length
    progressCancelled = false
    replayFiles.forEach(parseReplay)
  }

  function parseReplay(fileName) {
    parser.parseReplay(fileName)
  }

  function readFromDb(callback, defaultValue) {
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

    return res
  }

  function getPlayerFilterCondition(slippiCode, slippiName) {
    if(slippiCode && slippiName) {
      return "(p.slippiCode = ? or p.slippiName = ?)"
    }
    else if(slippiCode) {
      return "(p.slippiCode = ?)"
    }
    else if(slippiName) {
      return "(p.slippiName = ?)"
    }
    else {
      return "true"
    }
  }

  function getStageFilterCondition(stageId) {
    if(stageId < 0) {
      return "(r.stageId not in (%1))".arg(stageIds.map(_ => "?").join(",")) // add one question mark placeholder per argument
    }
    else if(stageId > 0) {
      return "(r.stageId = ?)"
    }
    else {
      return "true"
    }
  }

  function getFilterCondition() {
    return "(" +
        getPlayerFilterCondition(slippiCode, slippiName) +
        " and " + getStageFilterCondition(stageId) +
        ")"
  }

  function getPlayerFilterParams(slippiCode, slippiName) {
    if(slippiCode && slippiName) {
      return [slippiCode, slippiName]
    }
    else if(slippiCode) {
      return [slippiCode]
    }
    else if(slippiName) {
      return [slippiName]
    }
    else {
      return []
    }
  }

  function getStageFilterParams(stageId) {
    if(stageId < 0) {
      return stageIds
    }
    else if(stageId > 0) {
      return [stageId]
    }
    else {
      return []
    }
  }

  function getFilterParams() {
    return getPlayerFilterParams(slippiCode, slippiName).concat(getStageFilterParams(stageId))
  }

  function getNumReplays() {
    return readFromDb(function(tx) {
      var results = tx.executeSql("select count(*) c from Replays")

      return results.rows.item(0).c
    }, 0)
  }

  function getNumReplaysFiltered() {
    return readFromDb(function(tx) {
      var sql = "select count(distinct replayId) c from replays r
join players p on p.replayId = r.id
where " + getFilterCondition()

      var results = tx.executeSql(sql, getFilterParams())

      return results.rows.item(0).c
    }, 0)
  }

  function getNumReplaysFilteredWithResult() {
    return readFromDb(function(tx) {
      var results = tx.executeSql("select count(distinct replayId) c from replays r
join players p on p.replayId = r.id
 where r.winnerPort >= 0 and " + getFilterCondition(), getFilterParams())

      return results.rows.item(0).c
    }, 0)
  }

  function getNumReplaysFilteredWon() {
    return readFromDb(function(tx) {
      var results = tx.executeSql("select count(distinct replayId) c from replays r
 join players p on p.replayId = r.id
where p.isWinner and " + getFilterCondition(), getFilterParams())

      return results.rows.item(0).c
    }, 0)
  }

  function getAverageGameDuration() {
    return readFromDb(function(tx) {
      var results = tx.executeSql("select avg(duration) d from Replays")

      return results.rows.item(0).d || 0
    }, 0)
  }

  function getStageAmount(stageId) {
    return readFromDb(function(tx) {
      var results = tx.executeSql("select count(*) c from Replays where stageId = ?", [stageId])

      return results.rows.item(0).c
    }, 0)
  }

  function getOtherStageAmount() {
    return readFromDb(function(tx) {
      var results = tx.executeSql(qsTr("select count(*) c from Replays where stageId not in (%1)")
                                  .arg(stageIds.map(_ => "?").join(",")), // add one question mark placeholder per argument
                                  stageIds)

      return results.rows.item(0).c
    }, 0)
  }

  function getTopPlayerTags(max) {
    return readFromDb(function(tx) {
      var sql = "select slippiName, count(distinct replayId) c from players p
join replays r on p.replayId = r.id
where slippiName is not null and
slippiName is not \"\" and " + getFilterCondition() + "
group by slippiName
order by c desc
limit ?"

      var params = getFilterParams().concat([max])

      console.log("get tags", sql, params)

      var results = tx.executeSql(sql, params)

      console.log("results", results.rows.length)

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

  function cancelAll() {
    parser.cancelAll()
  }

  function clearDatabase() {
    db.transaction(function(tx) {
      tx.executeSql("delete from Replays")
    })

    dbUpdaterChanged() // refresh bindings
  }

  function formatPercentage(amount) {
    return amount ? qsTr("%1 %").arg((amount * 100).toFixed(2)) : "0 %"
  }
}
