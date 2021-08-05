import QtQuick 2.0
import QtQuick.LocalStorage 2.12

import Felgo 3.0

import Qt.labs.settings 1.1

import Slippipedia 1.0

Item {
  id: dataModel

  property int dbUpdater: 0

  // settings
  property string replayFolder: fileUtils.storageLocation(FileUtils.DocumentsLocation, "Slippi")
  readonly property var allFiles: Utils.listFiles(replayFolder, ["*.slp"], true)
  property var newFiles: globalDataBase.getNewReplays(allFiles, dbUpdater)

  property string desktopAppFolder: fileUtils.storageLocation(FileUtils.AppDataLocation, "../Slippi Desktop App")
  readonly property string desktopDolphinPath: desktopAppFolder + "/dolphin/Slippi Dolphin.exe"
  readonly property bool hasDesktopApp: fileUtils.existsFile(desktopDolphinPath)

  property string meleeIsoPath: ""
  readonly property bool hasMeleeIso: !!meleeIsoPath && fileUtils.existsFile(meleeIsoPath)

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

  readonly property string dbLatestVersion: "2.1"
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
    // refresh after n items
    if(numFilesSucceeded % 500 === 0) {
      dbUpdaterChanged()

      //disable this if it causes the UI to lock up while analyzing
      stats.refresh()
    }
  }

  onIsProcessingChanged: {
    if(!isProcessing) {
      dbUpdaterChanged() // refresh bindings
      stats.refresh()
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
    property alias desktopAppFolder: dataModel.desktopAppFolder
    property alias meleeIsoPath: dataModel.meleeIsoPath
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

  // utils (TODO move to another file)

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
      return qsTr("%1 day%5 %2:%3:%4")
        .arg(days)
        .arg(leadingZeros(hours, 2))
        .arg(leadingZeros(minutes, 2))
        .arg(leadingZeros(seconds, 2))
        .arg(days === 1 ? "" : "s")
    }
    else if(hours > 0) {
      return qsTr("%1:%2:%3")
        .arg(leadingZeros(hours, 2))
        .arg(leadingZeros(minutes, 2))
        .arg(leadingZeros(seconds, 2))
    }
    else /*if(minutes > 0)*/ {
      return qsTr("%1:%2")
        .arg(leadingZeros(minutes, 2))
        .arg(leadingZeros(seconds, 2))
    }
//    else {
//      return seconds + "s"
//    }
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
    return date && date.toLocaleString(Qt.locale("en_GB"), "dd/MM/yyyy HH:mm") || ""
  }

  function playersText(replay) {
    return qsTr("%1 (%2) vs %3 (%4)")
        .arg(replay.name1).arg(replay.code1)
        .arg(replay.name2).arg(replay.code2)
  }

  function damageColor(damage) {
    var factor = damage / 100

    var base = Qt.rgba(1, 0, 0, 1)

    if(factor > 1) {
      return Qt.darker(base, factor)
    }
    else {
      return Qt.lighter(base, 2 - factor)
    }
  }

  function winRateColor(winRate) {
    var winAngle = Math.PI * 10/8
    var lossAngle = Math.PI * 5/8

    return polarColor(0.5, 0.5, lerp(lossAngle, winAngle, winRate))
  }

  function yuva(y, u, v, a) {
    return Qt.rgba(
          y + v * 1.403,
          y - u * 0.344 - v * 0.714,
          y + u * 1.77,
          a)
  }

  function polarColor(luminance, chrominance, angle) {
    var maxDist = 1 // distance to move from the center of the YUV plane when chrominance == 1

    //calc UV coordinates based on angle and radius (chrominance)
    var u = Math.cos(angle) * maxDist * chrominance
    var v = Math.sin(angle) * maxDist * chrominance
    return yuva(luminance, u, v, 1)
  }

  function lerp(a, b, ratio) {
    return a * (1 - ratio) + b * ratio
  }

  // replay functions

  function openReplayFolder(filePath) {
    Utils.exploreToFile(filePath)
  }

  function openReplayFile(filePath) {
    if(!hasDesktopApp) {
      // just open file normally
      fileUtils.openFile(filePath)
      return
    }

    var slippiInput = { replay: filePath }

    startDolphin(slippiInput)
  }

  function replayPunishes(punishList) {
    if(!hasDesktopApp) {
      return false
    }
    if(!punishList || punishList.length === 0) {
      return false
    }

    var startFrames = 60 * 5
    var paddingFrames = 60 * 2 // 2 seconds

    // convert to playback dolphin input format:
    var punishQueue = punishList.map(pu => ({
                                         path: pu.filePath,
                                         startFrame: pu.startFrame - paddingFrames - startFrames,
                                         endFrame: pu.endFrame + paddingFrames
                                       }))

    var slippiInput = {
      mode: "queue",
      replay: "", // not required in queue mode
      isRealTimeMode: false,
      outputOverlayFiles: false, // what is this?
      queue: punishQueue
    }

    startDolphin(slippiInput)
  }

  function startDolphin(slippiInput) {
    var tempJsonFilePath = fileUtils.storageLocation(FileUtils.AppDataLocation, "input.json")
    fileUtils.writeFile(tempJsonFilePath, JSON.stringify(slippiInput, null, "  "))

    var options = [
          "-i", tempJsonFilePath, // load input JSON file
        ]

    if(hasMeleeIso) {
      options = options.concat([
                                 "-e", meleeIsoPath // auto-start melee ISO in dolphin
                               ])
    }

    // start > Slippi Dolphin -i punish.json
    Utils.startCommand(desktopDolphinPath, options)
  }
}
