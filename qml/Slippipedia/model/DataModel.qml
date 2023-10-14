import QtQuick 2.0

import Felgo 4.0

// note: must be below Felgo import
import Qt.labs.settings 1.1

import Slippi 1.0
import Slippipedia 1.0

Item {
  id: dataModel

  readonly property int flagFavorite: 1

  readonly property var userFlagNames: ["Favorite"]
  readonly property var userFlagIcons: [IconType.star]

  readonly property var allGameModes: [SlippiReplay.Ranked, SlippiReplay.Unranked, SlippiReplay.Direct, SlippiReplay.Unknown]

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
  property string videoCodec: videoCodecDefault
  property string videoCodecDefault: "libx264"
  property real punishPaddingFrames: 60 * 2 // 2 seconds

  property var createdVideos: []

  property bool hasFfmpeg: false
  property string ffmpegVersion: ""
  property int ffmpegYear: 0

  // analyze progress
  property bool progressCancelled: false
  property int numFilesSucceeded: 0
  property int numFilesFailed: 0
  property int numFilesProcessing: 0
  readonly property int numFilesProcessed: numFilesSucceeded + numFilesFailed
  readonly property bool isProcessing: !progressCancelled && numFilesProcessed < numFilesProcessing
  readonly property real processProgress: isProcessing ? numFilesProcessed / numFilesProcessing : 0

  property int numVideosEncoding: 0
  readonly property bool isEncoding: numVideosEncoding > 0

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

  Component.onCompleted: {
    if(!replayFolder) replayFolder = replayFolderDefault
    if(!desktopAppFolder) desktopAppFolder = desktopAppFolderDefault
    if(!videoOutputPath) videoOutputPath = videoOutputPathDefault
    // no default path for melee iso

    ensureVideoOutputPath()

    Utils.startCommand("ffmpeg", ["-version"], function(success, command, error) {
      if(!success) {
        console.warn("Could not find ffmpeg:", error)
      }
      hasFfmpeg = success
    }, function(msg) {
      var match = msg.match(/ffmpeg version (.*) Copyright.*[0-9]+-([0-9]+) /)
      if(match) {
        console.log("ffmpeg version:", match[1], "year:", match[2])
        ffmpegVersion = match[1]
        ffmpegYear = parseInt(match[2])
      }
      else {
        console.log("ffmpeg log", msg, match)
      }
    })
  }

  function ensureVideoOutputPath() {
    if(!hasVideoOutputPath) {
      Utils.mkdirs(videoOutputPath)
      videoOutputPathChanged()
    }
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
    dbUpdaterChanged() // refresh bindings
  }

  // utils (TODO move to another file)

  function parseTime(text) {
    // convert text "hh:mm:ss" to time in ms

    if(!text) {
      return -1
    }

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

  function parseTimeFrames(text) {
    var timeMs = parseTime(text)

    return timeMs >= 0 ? timeMs * 60 / 1000 : undefined
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
    else if((number >= 1 || number === 0) && (number === Math.floor(number))) {
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

  function gameModeName(gameMode) {
    return {
      [SlippiReplay.Direct]: "Direct",
      [SlippiReplay.Ranked]: "Ranked",
      [SlippiReplay.Unranked]: "Unranked"
    }[gameMode] || "Unknown"
  }

  function platformText(platform) {
    return capitalize(platform)
  }

  function platformIcon(platform) {
    switch(platform) {
    case "console":
    case "nintendont": return Qt.resolvedUrl("../../../assets/img/gamecube.png")
    case "network":    return Qt.resolvedUrl("../../../assets/img/broadcast.svg")
    case "dolphin":
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

  function colorWithAlpha(col, alpha) {
    return Qt.rgba(col.r, col.g, col.b, alpha)
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

    var dateTimeText = formatDate(new Date(), "yyyy-MM-dd HH-mm-ss")

    var dumpFolder = qsTr("%1/playback/User/Dump").arg(desktopAppFolder)

    var videoPath = qsTr("%1/Frames/").arg(dumpFolder)
    var audioDspPathOrig = qsTr("%1/Audio/dspdump.wav").arg(dumpFolder)
    var audioDtkPathOrig = qsTr("%1/Audio/dtkdump.wav").arg(dumpFolder)

    // move all input files to a temp folder, this way dolphin can save new dumps already while ffmpeg is encoding this one
    var tempPath = qsTr("%1/dump-%2/").arg(dumpFolder).arg(dateTimeText)
    Utils.mkdirs(tempPath)

    var audioDspPath = qsTr("%1/dspdump.wav").arg(tempPath)
    var audioDtkPath = qsTr("%1/dtkdump.wav").arg(tempPath)

    Utils.moveFile(audioDspPathOrig, audioDspPath)
    Utils.moveFile(audioDtkPathOrig, audioDtkPath)

    var iconImgPath = fileUtils.stripSchemeFromUrl(Utils.executablePath + "/resfiles/icon.png")

    // dolphin can save multiple "framedumpN.avi" files - list all of them and concatenate
    var videoFiles = fileUtils.listFiles(videoPath, "*.avi").sort()
    var videoPathsOrig = videoFiles.map(f => videoPath + f)
    var videoPaths = videoFiles.map(f => tempPath + f)

    videoPathsOrig.forEach((path, index) => Utils.moveFile(path, videoPaths[index]))

    // skip small frame dumps, those are often empty/corrupted and cause problems with ffmpeg
    var inputVideos = videoPaths.filter(p => Utils.fileSize(p) > 10000)

    var outputName = qsTr("Replay %1.mp4").arg(dateTimeText);
    var outputPath = videoOutputPath + "/" + outputName

    var cleanup = function() {
      if(autoDeleteFrameDumps) {
        console.log("Clear", videoPaths.length, "video dumps + audio dumps + temp folder.")
        // cleanup dolphin dump
        fileUtils.removeDir(tempPath)
      }
    }

    var doEncode = function() {
      // use padding to even size
      var padFilter = "pad=ceil(iw/2)*2:ceil(ih/2)*2"

      // read input video at original frame rate (59.94) by setting presentation timestamp
      var ptsFilter = "setpts=(PTS-STARTPTS)*60/59.94"

      // show watermark in bottom right
      var overlayFilter = "overlay=main_w-overlay_w-5:main_h-overlay_h-5:format=auto,format=yuv420p"

      // concat all input videos
      var concatFilter = qsTr("concat=n=%1:v=1:a=0:unsafe=1").arg(inputVideos.length)

      // create input tags for concat filter e.g. [3:v][4:v]...
      var videoInputTags = inputVideos.map((file, index) => qsTr("[%1:v]").arg(index + 3)).join("")

      // overlay watermark onto video
      var filter = qsTr("%1 %2 [vid]; [vid] %3, %4 [vidP]; [2:v] scale=48x48:flags=lanczos [img]; [vidP][img] %5")
        .arg(videoInputTags).arg(concatFilter).arg(padFilter).arg(ptsFilter).arg(overlayFilter)

      // no watermark
      //var filter = qsTr("[0:v] %1").arg(padFilter).arg(overlayFilter)

      var videoIndex = createdVideos.length

      createdVideos.push({
                           fileName: outputName,
                           filePath: outputPath,
                           folder: videoOutputPath,
                           progress: 0,
                           numFrames: 1,
                           success: true,
                           errorMessage: ""
                         })
      createdVideosChanged()

      var ffmpegParams = [
            "-y", // always overwrite output file
            "-i", audioDspPath,
            "-i", audioDtkPath,
            "-i", iconImgPath,
            "-filter_complex", filter,
            "-c:v", videoCodec,
            "-b:v", videoBitrate + "k",
            outputPath
          ]

      // add every input video as input like "-i filename"
      inputVideos.forEach((p, index) => ffmpegParams.splice(7 + index * 2, 0, "-i", p))

      console.log("starting ffmpeg command: ffmpeg", ffmpegParams.map(p => "\"" + p + "\"").join(" "))

      Utils.startCommand("ffmpeg", ffmpegParams, function(success, command, errorMessage) {
        if(success) {
          console.log("Replay saved.")
        }
        else {
          console.warn("ffmpeg process crashed at", formatPercentage(createdVideos[videoIndex].progress), ":", errorMessage)
        }

        numVideosEncoding--

        createdVideos[videoIndex].progress = 1
        createdVideos[videoIndex].success = success
        createdVideos[videoIndex].errorMessage = errorMessage
        createdVideosChanged()

        cleanup()
      }, function(msg) {
        // find out length of input audio file from the log output:
        var match = msg.match(/Input #0, wav.*[\r\n]+ +Duration: ([0-9]+):([0-9]+):([0-9]+).([0-9]+),/m)
        if(match) {
          var seconds = parseInt(match[4]) / 100 + parseInt(match[3]) + parseInt(match[2]) * 60 + parseInt(match[1]) * 60 * 60
          var frames = seconds * 60

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

      numVideosEncoding++
    }

    if(videoFiles.length === 0) {
      console.log("No frame dumps from Dolphin detected.")
      cleanup()
      return
    }

    var dialog = app.confirm(
          "Save video file for last played replay?",
          qsTr("Video file will be saved to '%1'.").arg(outputPath),
          function(accepted) {
            if(accepted) {
              doEncode()
            }
            else {
              cleanup()
            }
          })
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
