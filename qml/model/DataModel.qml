import QtQuick 2.0

import Qt.labs.settings 1.1

import Slippi 1.0

import "data"
import "db"
import "filter"
import "stats"

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
  property alias playerFilter: playerFilter
  property alias opponentFilter: opponentFilter
  property alias gameFilter: gameFilter

  // stats
  property alias stats: stats

  readonly property string filterDisplayText: {
    var pText = playerFilter.displayText
    pText = pText ? "Me: " + pText : ""

    var oText = opponentFilter.displayText
    oText = oText ? "Opponent: " + oText : ""

    var sText = null
    if(gameFilter.stageIds.length > 0) {
      sText = "Stages: " + gameFilter.stageIds.map(id => MeleeData.stageMap[id].name).join(", ")
    }

    var wText = gameFilter.winnerPlayerIndex == -3
        ? "" : ("Winner: " + gameFilter.winnerTexts[gameFilter.winnerPlayerIndex])

    return [pText, oText, sText, wText].filter(_ => _).join("\n") || "(nothing)"
  }

  onIsProcessingChanged: {
    if(!isProcessing) {
      dbUpdaterChanged() // refresh bindings
    }
  }

  PlayerFilterSettings {
    id: playerFilter

    settingsCategory: "player-filter"

    onFilterChanged: dbUpdaterChanged()
  }

  PlayerFilterSettings {
    id: opponentFilter

    settingsCategory: "player-filter-opponent"

    onFilterChanged: dbUpdaterChanged()
  }

  GameFilterSettings {
    id: gameFilter

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

    playerFilter: dataModel.playerFilter
    opponentFilter: dataModel.opponentFilter
    gameFilter: dataModel.gameFilter
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

  // replay list

  function getReplayList(max, start) {
    return dataBase.getReplayList(max, start)
  }

  function resetFilters() {
    playerFilter.reset()
    opponentFilter.reset()
    gameFilter.reset()
  }

  // utils

  function formatPercentage(amount, numDecimals = 2) {
    return amount > 1
        ? "100%"
        : amount <= 0 || amount !== amount
          ? "0%"
          : qsTr("%1%").arg((amount * 100).toFixed(numDecimals))
  }

  function formatTime(numFrames) {
    var days = Math.floor(numFrames / 60 / 60 / 60 / 24)
    var hours = Math.floor(numFrames / 60 / 60 / 60 % 24)
    var minutes = Math.floor(numFrames / 60 / 60 % 60)
    var seconds = Math.floor(numFrames / 60 % 60)

    if(days > 0) {
      return qsTr("%1 days %2:%3:%4")
        .arg(days)
        .arg(leadingZeros(hours, 2))
        .arg(leadingZeros(minutes, 2))
        .arg(leadingZeros(seconds, 2))
    }
    else if(hours > 0) {
      return qsTr("%1:%2:%3")
        .arg(leadingZeros(hours, 2))
        .arg(leadingZeros(minutes, 2))
        .arg(leadingZeros(seconds, 2))
    }
    else {
      return qsTr("%1:%2")
        .arg(leadingZeros(minutes, 2))
        .arg(leadingZeros(seconds, 2))
    }
  }

  function formatNumber(number) {
    if(number > 1000 * 1000) {
      return (number / 1000 / 1000).toFixed(2) + "M"
    }
    else if(number > 1000) {
      return (number / 1000).toFixed(2) + "K"
    }
    else {
      return number.toFixed(2)
    }
  }

  function leadingZeros(number, numDigits) {
    var str = ""

    var max = Math.pow(10, numDigits - 1)

    while(number < max) {
      str += "0"
      max = Math.floor(max / 10)
    }

    return str + (number ? number : "")
  }

  function formatDate(date) {
    return date && date.toLocaleString("dd/MM/yyyy HH:mm") || ""
  }

  function playersText(replay) {
    return qsTr("%1 (%2) vs %3 (%4)")
        .arg(replay.name1).arg(replay.code1)
        .arg(replay.name2).arg(replay.code2)
  }
}
