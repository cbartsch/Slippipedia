import QtQuick 2.0

import Qt.labs.settings 1.1

import Slippi 1.0

Item {
  id: dataModel

  property int dbUpdater: 0

  // replay settings
  property alias replayFolder: globalSettings.replayFolder
  readonly property var allFiles: Utils.listFiles(replayFolder, ["*.slp"], true)
  property var newFiles: dataBase.getNewReplays(allFiles)

  // analyze progress
  property bool progressCancelled: false
  property int numFilesSucceeded: 0
  property int numFilesFailed: 0
  property int numFilesProcessing: 0
  readonly property int numFilesProcessed: numFilesSucceeded + numFilesFailed
  readonly property bool isProcessing: !progressCancelled && numFilesProcessed < numFilesProcessing
  readonly property real processProgress: isProcessing ? numFilesProcessed / numFilesProcessing : 0

  // filter settings
  property alias filter: filter

  // stats
  property alias stats: stats

  onIsProcessingChanged: {
    if(!isProcessing) {
      dbUpdaterChanged() // refresh bindings
    }
  }

  FilterSettings {
    id: filter

    onFilterChanged: dbUpdaterChanged()
  }

  ReplayStats {
    id: stats

    dataBase: dataBase
  }

  Settings {
    id: globalSettings

    property string replayFolder: ""
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

  function getTopSlippiCodesOpponent(max) {
    return dataBase.getTopSlippiCodesOpponent(max)
  }

  function getTopPlayerTagsOpponent(max) {
    return dataBase.getTopPlayerTagsOpponent(max)
  }

  // replay list

  function getReplayList(max, start) {
    return dataBase.getReplayList(max, start)
  }

  function resetFilters() {
    filter.reset()
  }

  // utils

  function formatPercentage(amount) {
    return amount > 1
        ? "100%"
        : amount <= 0 || amount !== amount
          ? "0%"
          : qsTr("%1%").arg((amount * 100).toFixed(2))
  }

  function formatTime(numFrames) {
    var minutes = Math.floor(numFrames / 60 / 60)
    var seconds = Math.floor(numFrames / 60 % 60)

    return qsTr("%1:%2").arg(minutes).arg(seconds)
  }

  function formatDate(date) {
    return date.toLocaleString("dd/MM/yyyy HH:mm")
  }
}
