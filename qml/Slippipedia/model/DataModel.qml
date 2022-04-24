import QtQuick 2.0

import Felgo 3.0

// note: must be below Felgo import
import Qt.labs.settings 1.1

import Slippipedia 1.0

Item {
  id: dataModel

  readonly property int flagFavorite: 1

  readonly property var userFlagNames: ["Favorite"]
  readonly property var userFlagIcons: [IconType.star]

  readonly property var monthNames: [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ]

  property int dbUpdater: 0
  property int fileUpdater: 0

  // settings
  property string replayFolder: ""
  readonly property string replayFolderDefault: fileUtils.storageLocation(FileUtils.DocumentsLocation, "Slippi")
  readonly property var allFiles: fileUpdater, Utils.listFiles(replayFolder, ["*.slp"], true)
  property var newFiles: globalDataBase.getNewReplays(allFiles, dbUpdater)

  property string desktopAppFolder: ""
  readonly property string desktopAppFolderDefault: fileUtils.storageLocation(FileUtils.AppDataLocation, "../Slippi Launcher")
  readonly property string desktopDolphinPath: desktopAppFolder + "/playback/Slippi Dolphin." + (Qt.platform.os === "osx" ? "app" : "exe")
  readonly property bool hasDesktopApp: fileUtils.existsFile(desktopDolphinPath)

  property string meleeIsoPath: ""
  readonly property bool hasMeleeIso: !!meleeIsoPath && fileUtils.existsFile(meleeIsoPath)

  Component.onCompleted: {
    if(!replayFolder) replayFolder = replayFolderDefault
    if(!desktopAppFolder) desktopAppFolder = desktopAppFolderDefault
    // no default path for melee iso
  }

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

  signal initialized

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

  Connections {
    target: Qt.application

    onActiveChanged: {
       // refresh file list e.g. if new replays exist when app comes to foreground
      if(active) fileUpdaterChanged()
    }
  }

  DataBase {
    id: globalDataBase

    filterSettings: filterSettings
    db: dataBaseConnection

    onInitialized: dataModel.initialized()
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

  function parseTime(text) {
    // convert text "hh:mm:ss" to time in ms

    var inElems = text.split(":")
    var elems = inElems

    if(elems.length === 2) {
      elems = ["00"].concat(elems)
    }
    if(elems.length === 3 && inElems.every((a, index) => a.match(index === 0 ? "^[0-9]{1,2}$" : "^[0-9]{2}$"))) {
      var hours = parseInt(elems[0])
      var minutes = parseInt(elems[1])
      var seconds = parseInt(elems[2])

      return ((hours * 60 + minutes) * 60 + seconds) * 1000
    }

    return -1
  }

  function formatPercentage(amount, numDecimals = 2) {
    return amount > 1
        ? "100%"
        : amount <= 0 || amount !== amount
          ? "0%"
          : qsTr("%1%").arg((amount * 100).toFixed(numDecimals))
  }

  function formatTimeMs(numMs, showDays = true) {
    return formatTime(numMs * 60 / 1000, showDays)
  }

  function formatTime(numFrames, showDays = true) {
    var days = Math.floor(numFrames / 60 / 60 / 60 / 24)
    var hours = Math.floor(numFrames / 60 / 60 / 60)
    if(showDays) {
      hours = hours % 24
    }
    var minutes = Math.floor(numFrames / 60 / 60 % 60)
    var seconds = Math.floor(numFrames / 60 % 60)

    if(days > 0 && showDays) {
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

  function capitalize(string) {
    return string ? string[0].toUpperCase() + string.substring(1) : ""
  }

  function formatDate(date) {
    return date && date.toLocaleString(Qt.locale("en_GB"), "dd/MM/yyyy HH:mm") || ""
  }

  function playersText(replay) {
    return qsTr("%1/%2 (%3) P%4 vs %5/%6 (%7) P%8")
        .arg(replay.name1).arg(replay.tag1).arg(replay.code1).arg(replay.port1)
        .arg(replay.name2).arg(replay.tag2).arg(replay.code2).arg(replay.port2)
  }

  function platformDescription(platform) {
    return {
      dolphin: "Slippi dolphin (netplay)",
      network: "Slippi broadcast (streamed from console or netplay)",
      nintendont: "Nintendont (local recording from console)"
    }[platform] || platformText(platform)
  }

  function platformText(platform) {
    return capitalize(platform)
  }

  function platformIcon(platform) {
    switch(platform) {
    case "console":
    case "nintendont": return Qt.resolvedUrl("../../../assets/img/gamecube.png")
    case "network":     return Qt.resolvedUrl("../../../assets/img/broadcast.svg")
    case "slippi":
    default:           return Qt.resolvedUrl("../../../assets/img/slippi.svg")
    }
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

  function hasFlag(flagMask, flagId) {
    return (flagMask & (1 << flagId)) > 0
  }

  function setFlag(flagMask, flagId, flagValue) {
    if(flagValue) {
      return flagMask | (1 << flagId)
    }
    else {
      return flagMask & ~(1 << flagId)
    }
  }

  function hasReplayFlag(replayId, flagId) {
    var flagMask = globalDataBase.getUserFlag(replayId)

    return hasFlag(flagMask, flagId)
  }

  function setReplayFlag(replayId, flagId, flagValue) {
    var flagMask = globalDataBase.getUserFlag(replayId)

    flagMask = setFlag(flagMask, flagId, flagValue)

    globalDataBase.setUserFlag(replayId, flagMask)

    return flagMask
  }
}
