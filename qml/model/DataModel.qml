import QtQuick 2.0

import Qt.labs.settings 1.1

import Slippi 1.0

Item {
  id: dataModel

  property int dbUpdater: 0

  // replay settings
  property alias replayFolder: settings.replayFolder
  readonly property var allFiles: Utils.listFiles(replayFolder, ["*.slp"], true)

  // analyze progress
  property bool progressCancelled: false
  property int numFilesSucceeded: 0
  property int numFilesFailed: 0
  property int numFilesProcessing: 0
  readonly property int numFilesProcessed: numFilesSucceeded + numFilesFailed
  readonly property bool isProcessing: !progressCancelled && numFilesProcessed < numFilesProcessing
  readonly property real processProgress: isProcessing ? numFilesProcessed / numFilesProcessing : 0

  // stats
  readonly property int totalReplays: dataBase.getNumReplays(dbUpdater)
  readonly property int totalReplaysFiltered: dataBase.getNumReplaysFiltered(dbUpdater, slippiCode, slippiName, stageId)
  readonly property int totalReplaysFilteredWithResult: dataBase.getNumReplaysFilteredWithResult(dbUpdater, slippiCode, slippiName, stageId)
  readonly property int totalReplaysFilteredWon: dataBase.getNumReplaysFilteredWon(dbUpdater, slippiCode, slippiName, stageId)
  readonly property int totalReplaysFilteredWithTie: totalReplaysFiltered - totalReplaysFilteredWithResult

  readonly property real tieRate: dataModel.totalReplaysFilteredWithTie / dataModel.totalReplaysFiltered
  readonly property real winRate: dataModel.totalReplaysFilteredWon / dataModel.totalReplaysFilteredWithResult

  readonly property real otherStageAmount: dataBase.getOtherStageAmount(dbUpdater)

  readonly property real averageGameDuration: dataBase.getAverageGameDuration(dbUpdater)

  // TODO: refactor to use only one DB access with group by
  readonly property var charData: {
    var time = new Date().getTime()
    var data = dataBase.getCharacterStats(dbUpdater)
    console.log("cd took", (new Date().getTime() - time), "ms")
    return data
  }

  // filtering settings
  property alias slippiCode: settings.slippiCode
  property alias slippiName: settings.slippiName
  readonly property bool hasSlippiCode: slippiCode != "" || slippiName != ""
  property alias stageId: settings.stageId // -1 = "other" stages

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
      sText = "Stage: " + MeleeData.stageMap[stageId].name
    }

    return sText && pText ? (pText + ", " + sText) : sText || pText || "(nothing)"
  }

  onIsProcessingChanged: {
    if(!isProcessing) {
      dbUpdaterChanged() // refresh bindings
    }
  }

  Settings {
    id: settings

    property string replayFolder
    property string slippiCode
    property string slippiName
    property int stageId
  }

  SlippiParser {
    id: parser

    onReplayParsed: dataBase.analyzeReplay(filePath, replay)

    onReplayFailedToParse: {
      console.warn("Could not parse replay", filePath, ":", errorMessage)
      numFilesFailed++
    }
  }

  DataBase {
    id: dataBase
  }

  // replay / db management

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

  function cancelAll() {
    parser.cancelAll()
  }

  function clearDatabase() {
    dataBase.clearAllData()

    dbUpdaterChanged() // refresh bindings
  }

  // stats

  function getStageAmount(stageId) {
    return dataBase.getStageAmount(stageId)
  }

  function getTopPlayerTags(max) {
    return dataBase.getTopPlayerTags(max)
  }

  // utils

  function formatPercentage(amount) {
    return amount > 1
        ? "100%"
        : amount <= 0
          ? "0%"
          : qsTr("%1%").arg((amount * 100).toFixed(2))
  }
}
