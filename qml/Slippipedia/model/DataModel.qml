import QtQuick 2.0
import QtQuick.LocalStorage 2.12

import Felgo 3.0

import Qt.labs.settings 1.1

import Slippipedia 1.0

Item {
  id: dataModel

  property int dbUpdater: 0

  // replay settings
  property string replayFolder: fileUtils.storageLocation(FileUtils.DocumentsLocation, "Slippi")
  readonly property var allFiles: Utils.listFiles(replayFolder, ["*.slp"], true)
  property var newFiles: globalDataBase.getNewReplays(allFiles, dbUpdater)

  // analyze progress
  property bool progressCancelled: false
  property int numFilesSucceeded: 0
  property int numFilesFailed: 0
  property int numFilesProcessing: 0
  readonly property int numFilesProcessed: numFilesSucceeded + numFilesFailed
  readonly property bool isProcessing: !progressCancelled && numFilesProcessed < numFilesProcessing
  readonly property real processProgress: isProcessing ? numFilesProcessed / numFilesProcessing : 0

  // filter settings
  property alias filterSettings: filterSettings
  property alias gameFilter: filterSettings.gameFilter
  property alias playerFilter: filterSettings.playerFilter
  property alias opponentFilter: filterSettings.opponentFilter

  // global data
  property int totalReplays: globalDataBase.getNumReplays(dbUpdater)

  // stats
  property alias stats: stats

  // db
  property alias globalDataBase: globalDataBase
  property var dataBaseConnection

  readonly property string dbLatestVersion: "1.5"
  readonly property string dbCurrentVersion: dataBaseConnection.version
  readonly property bool dbNeedsUpdate: dbCurrentVersion !== dbLatestVersion

  signal initialized

  Component.onCompleted: {
    dataBaseConnection = LocalStorage.openDatabaseSync("SlippiStatsDB", "", "Slippi Stats DB", 50 * 1024 * 1024)
    if(dataBaseConnection.version === "") {
      dataBaseConnection.changeVersion("", dbLatestVersion, function(tx) {
        console.log("DB initialized at version", dbCurrentVersion, dbLatestVersion)
      })
      // reload object to update version property:
      dataBaseConnection = LocalStorage.openDatabaseSync("SlippiStatsDB", "", "Slippi Stats DB", 50 * 1024 * 1024)
    }

    console.log("DB open", dataBaseConnection, dataBaseConnection.version)

    initialized()
  }

  onNumFilesSucceededChanged: {
    // refresh after 100 items
    if(numFilesSucceeded % 100 === 0) {
      dbUpdaterChanged()
      stats.refresh()
    }
  }

  onIsProcessingChanged: {
    if(!isProcessing) {
      dbUpdaterChanged() // refresh bindings
    }
  }

  DataBase {
    id: globalDataBase

    filterSettings: filterSettings
  }

  FilterSettings {
    id: filterSettings

    persistenceEnabled: true // persist only the global filter
  }

  ReplayStats {
    id: stats

    dataBase: globalDataBase
  }

  Settings {
    id: globalSettings

    property alias replayFolder: dataModel.replayFolder
  }

  SlippiParser {
    id: parser

    onReplayParsed: {
      if(numFilesSucceeded === 0) {
        globalDataBase.createTables(replay)
      }

      globalDataBase.analyzeReplay(filePath, replay)

      numFilesSucceeded++
    }

    onReplayFailedToParse: {
      // store "failed" replay to not show it as "new" file
      globalDataBase.analyzeReplay(filePath, null)

      console.warn("Could not parse replay", filePath, ":", errorMessage)
      numFilesFailed++
    }
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
    globalDataBase.clearAllData()
    dataBaseConnection.changeVersion(dbCurrentVersion, dbLatestVersion, function(tx) {
    })
    dataBaseConnection = LocalStorage.openDatabaseSync("SlippiStatsDB", "", "Slippi Stats DB", 50 * 1024 * 1024)
    console.log("DB version updated.", dataBaseConnection.version, dbCurrentVersion)

    dbUpdaterChanged() // refresh bindings
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
    else if(minutes > 0) {
      return qsTr("%1:%2")
        .arg(leadingZeros(minutes, 2))
        .arg(leadingZeros(seconds, 2))
    }
    else {
      return seconds + "s"
    }
  }

  function formatNumber(number) {
    if(number > 1000 * 1000) {
      return (number / 1000 / 1000).toFixed(2) + "M"
    }
    else if(number > 1000) {
      return (number / 1000).toFixed(2) + "K"
    }
    else if((number > 1 || number === 0) && (number === (number % 1))) {
      return number.toFixed(0)
    }
    else if(number > 0.1) {
      return number.toFixed(2)
    }
    else {
      return number ? number.toFixed(4) : "0"
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
