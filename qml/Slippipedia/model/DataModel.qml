import QtQuick 2.0

import Felgo 4.0

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

  property bool videoOutputEnabled: false
  property bool autoDeleteFrameDumps: true

  property string videoOutputPath: ""
  readonly property string videoOutputPathDefault: fileUtils.storageLocation(FileUtils.MoviesLocation, "/Replays")
  readonly property bool hasVideoOutputPath: fileUtils.existsFile(videoOutputPath)

  property int videoBitrate: 5000
  property string videoCodec: "libx264"
  property real punishPaddingFrames: 60 * 2 // 2 seconds

  property var createdVideos: []

  Component.onCompleted: {
    if(!replayFolder) replayFolder = replayFolderDefault
    if(!desktopAppFolder) desktopAppFolder = desktopAppFolderDefault
    if(!videoOutputPath) videoOutputPath = videoOutputPathDefault
    // no default path for melee iso

    ensureVideoOutputPath()
  }

  function ensureVideoOutputPath() {
    if(!hasVideoOutputPath) {
      Utils.mkdirs(videoOutputPath)
      videoOutputPathChanged()
    }
  }

  // analyze progress
  property bool progressCancelled: false
  property int numFilesSucceeded: 0
  property int numFilesFailed: 0
  property int numFilesProcessing: 0
  readonly property int numFilesProcessed: numFilesSucceeded + numFilesFailed
  readonly property bool isProcessing: !progressCancelled && numFilesProcessed < numFilesProcessing || numDumpsProcessing > 0
  readonly property real processProgress: isProcessing ? numFilesProcessed / numFilesProcessing : 0

  property int numDumpsProcessing: 0

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
    property alias videoOutputPath: dataModel.meleeIsoPath

    property alias videoOutputEnabled: dataModel.videoOutputEnabled
    property alias autoDeleteFrameDumps: dataModel.autoDeleteFrameDumps

    property alias videoBitrate: dataModel.videoBitrate
    property alias videoCodec: dataModel.videoCodec
    property alias punishPaddingFrames: dataModel.punishPaddingFrames
  }

  SlippiParser {
    id: parser

    onReplayParsed: (filePath, replay) => {
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

  function formatDate(date, format="dd/MM/yyyy HH:mm") {
    return date && date.toLocaleString(Qt.locale("en_GB"), format) || ""
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

    // convert to playback dolphin input format:
    var punishQueue = punishList.map(pu => ({
                                         path: pu.filePath,
                                         startFrame: pu.startFrame - punishPaddingFrames - startFrames,
                                         endFrame: pu.endFrame + punishPaddingFrames
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
    Utils.startCommand(desktopDolphinPath, options, _saveFrameDump, function(msg) {
      console.log("[Playback Dolphin]", msg)
    })
  }

  function _saveFrameDump(dolphinPath) {
    if(!videoOutputEnabled) {
      return
    }

    console.log("_saveFrameDump", desktopDolphinPath)

    var dumpFolder = qsTr("%1/playback/User/Dump").arg(desktopAppFolder)

    var videoPath = qsTr("%1/Frames/").arg(dumpFolder)
    var audioDspPath = qsTr("%1/Audio/dspdump.wav").arg(dumpFolder)
    var audioDtkPath = qsTr("%1/Audio/dtkdump.wav").arg(dumpFolder)

    var iconImgPath = fileUtils.stripSchemeFromUrl(Qt.resolvedUrl("../../../resfiles/icon.png"))

    // dolphin can save multiple "framedumpN.avi" files - list all of them and concatenate
    var videoFiles = fileUtils.listFiles(videoPath, "*.avi")
    var videoPaths = videoFiles.map(f => videoPath + f)
    var videoInput = "concat:" + videoPaths.join("|")

    if(videoFiles.length === 0) {
      console.log("No frame dumps from Dolphin detected.")
      return
    }

    var outputName = qsTr("Replay %1.avi").arg(formatDate(new Date(), "yyyy-MM-dd HH-mm-ss"));
    var outputPath = videoOutputPath + "/" + outputName

    // use padding to even size
    var padFilter = "pad=ceil(iw/2)*2:ceil(ih/2)*2"

    // show watermark in bottom right
    var overlayFilter = "overlay=main_w-overlay_w-5:main_h-overlay_h-5:format=auto,format=yuv420p"

    var filter=qsTr("[0:v] %1 [vid]; [3:v] scale=48x48:flags=lanczos [img]; [vid][img] %2").arg(padFilter).arg(overlayFilter)

    var videoIndex = createdVideos.length

    createdVideos.push({
                         fileName: outputName,
                         filePath: outputPath,
                         folder: videoOutputPath,
                         progress: 0,
                         numFrames: 1
                       })
    createdVideosChanged()

    var ffmpegParams = [
          "-y", // always overwrite output file
          "-i", videoInput,
          "-i", audioDspPath,
          "-i", audioDtkPath,
          "-i", iconImgPath,
          "-filter_complex", filter,
          "-c:v", videoCodec,
          "-b:v", videoBitrate + "k",
          outputPath
        ]

    console.log("starting ffmpeg command: ffmpeg", ffmpegParams.map(p => "\"" + p + "\"").join(" "))

    Utils.startCommand("ffmpeg", ffmpegParams, function() {
                         console.log("Replay saved. Clear", videoPaths.length, "video dumps + audio dumps.")

                         numDumpsProcessing--

                         createdVideos[videoIndex].progress = 1
                         createdVideosChanged()

                         if(autoDeleteFrameDumps) {
                           // cleanup dolphin dump
                           videoPaths.forEach(path => fileUtils.removeFile(path))
                           fileUtils.removeFile(audioDspPath)
                           fileUtils.removeFile(audioDtkPath)
                         }
                       }, function(msg) {
                          // find out length of input audio file from the log output:
                          var match = msg.match(/Input #1, wav.*[\r\n]+ +Duration: ([0-9]+):([0-9]+):([0-9]+).([0-9]+),/m)
                          if(match) {
                            console.log("duration input:", match[1], match[2], match[3], match[4])

                            var seconds = parseInt(match[4]) / 100 + parseInt(match[3]) + parseInt(match[2]) * 60 + parseInt(match[1]) * 60 * 60
                            var frames = seconds * 60

                            console.log("num frames is", seconds, frames, match)
                            createdVideos[videoIndex].numFrames = frames
                          }

                          // find out current encoded frame from the log output:
                          match = msg.match(/frame= *([0-9]+) /)
                          if(match) {
                            var currentFrame = match[1]
                            createdVideos[videoIndex].progress = currentFrame / createdVideos[videoIndex].numFrames
                            createdVideosChanged()
                          }

                          // show output on console / log file:
                          console.log("[ffmpeg]", msg)
                       })

    numDumpsProcessing++

    console.log("started ffmpeg")
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
