import Felgo 4.0

import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects

import Slippipedia 1.0

BasePage {
  id: setupPage
  title: qsTr("Setup")

  flickable.contentHeight: content.height

  Column {
    id: content
    width: parent.width

    SimpleSection {
      title: "Replay folder"
    }

    AppListItem {
      text: "Click to select replay folder..."
      detailText: "Used for finding & analyzing replays."

      onSelected: fileDialogReplays.open()

      FolderDialog {
        id: fileDialogReplays
        title: "Select replay folder"
        currentFolder: filenameToUri(dataModel.replayFolder)

        onAccepted: dataModel.replayFolder = uriToFilename(selectedFolder)
      }
    }

    AppListItem {
      text: dataModel.replayFolder
      detailText: dataModel.allFiles.length +  " replays found."

      enabled: false
      backgroundColor: Theme.backgroundColor
    }

    SimpleSection {
      title: "Replay database"
    }

    AppListItem {
      visible: dataModel.globalDataBase.dbNeedsUpdate

      text: "Database version outdated"
      detailText: qsTr("Your app's database version is outdated (%1 < %2). \
This happens when updating to a new app version. \
Please clear and re-build the database. \
Otherwise, some app features might not work properly. \
Click to clear database.").arg(dataModel.globalDataBase.dbCurrentVersion).arg(dataModel.globalDataBase.dbLatestVersion)

      onSelected: clearDb()

      textColor: "red"
      detailTextColor: "#bb0000"
    }

    AppListItem {
      text: qsTr("%1 total replays stored.").arg(dataModel.stats.totalReplays)

      mouseArea.hoverEnabled: false
      mouseArea.cursorShape: Qt.ArrowCursor
      backgroundColor: Theme.backgroundColor

      rightItem: AppToolButton {
        anchors.verticalCenter: parent.verticalCenter
        iconType: IconType.folder
        toolTipText: qsTr("Show database file:\n%1").arg(Utils.offlineStoragePath)
        onClicked: Utils.exploreToFile(Utils.offlineStoragePath)
      }
    }

    AppListItem {
      text: "Clear database"
      onSelected: clearDb()
    }

    SimpleSection {
      title: "Analyze"
      visible: !dataModel.isProcessing
    }

    AppListItem {
      text: qsTr("Analyze %1 replays").arg(dataModel.allFiles.length)

      visible: !dataModel.isProcessing
      enabled: dataModel.allFiles.length > 0
      backgroundColor: enabled ? Theme.controlBackgroundColor : Theme.backgroundColor

      onSelected: dataModel.parseReplays(dataModel.allFiles)
    }

    AppListItem {
      text: dataModel.newFiles
            ? qsTr("Analyze %1 new replays").arg(dataModel.newFiles.length)
            : "No new replays found."

      visible: !dataModel.isProcessing
      enabled: dataModel.newFiles.length > 0
      backgroundColor: enabled ? Theme.controlBackgroundColor : Theme.backgroundColor

      onSelected: dataModel.parseReplays(dataModel.newFiles)
    }

    SimpleSection {
      title: "Progress"
      visible: dataModel.numFilesProcessing > 0
    }

    SimpleRow {
      text: qsTr("Analyzed %1/%2 replays%3%4")
      .arg(dataModel.numFilesSucceeded)
      .arg(dataModel.numFilesProcessing)
      .arg(dataModel.numFilesFailed > 0 ? " (" + dataModel.numFilesFailed + " failed)" : "")
      .arg(dataModel.isProcessing? "..." : ".")

      textItem.color: Theme.textColor

      enabled: false
      visible: dataModel.numFilesProcessing > 0
    }

    AppListItem {
      text: "Cancel"
      visible: dataModel.isProcessing
      onSelected: {
        dataModel.cancelAll()
        dataModel.progressCancelled = true
      }
    }

    ProgressBar {
      value: dataModel.processProgress
      width: parent.width
      visible: dataModel.isProcessing
    }

    SimpleSection {
      title: "Slippi Desktop App folder"
    }

    AppListItem {
      text: "Click to select Slippi Desktop App folder..."
      detailText: "Used to play replays & punishes."

      onSelected: fileDialogDesktop.open()

      FolderDialog {
        id: fileDialogDesktop
        title: "Select Slippi Desktop App folder"
        currentFolder: filenameToUri(dataModel.desktopAppFolder)

        onAccepted: dataModel.desktopAppFolder = uriToFilename(selectedFolder)
      }

      rightItem: AppToolButton {
        iconType: IconType.trash
        toolTipText: qsTr("Reset Desktop App folder to default: %1").arg(dataModel.desktopAppFolderDefault)
        anchors.verticalCenter: parent.verticalCenter

        onClicked: dataModel.desktopAppFolder = dataModel.desktopAppFolderDefault
      }
    }

    AppListItem {
      text: dataModel.desktopAppFolder
      detailText: dataModel.hasDesktopApp ? "Desktop app found." : "Desktop app not found."

      leftItem: Item {
        width: dp(24)
        height: width
        anchors.verticalCenter: parent.verticalCenter

        Icon {
          anchors.centerIn: parent
          size: dp(24)
          color: dataModel.hasDesktopApp ? Theme.tintColor : "red"
          icon: dataModel.hasDesktopApp ? IconType.check : IconType.times
        }
      }

      rightItem: Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: dp(Theme.contentPadding)

        AppToolButton {
          iconType: IconType.folderopen
          toolTipText: Qt.platform.os === "osx" ? "Show in finder" : "Show in file explorer"

          visible: dataModel.hasDesktopApp
          onClicked: Utils.exploreToFile(dataModel.desktopAppFolder)
        }

        AppToolButton {
          iconItem.visible: false
          toolTipText: "Configure playback Dolphin"

          visible: fileUtils.existsFile(dataModel.desktopDolphinPath)
          onClicked: Utils.startCommand(dataModel.desktopDolphinPath, [])

          AppImage {
            anchors.centerIn: parent
            width: parent.iconItem.size
            height: width
            source: "../../../assets/img/slippi.svg"
            fillMode: Image.PreserveAspectFit
            mipmap: true
          }
        }
      }

      mouseArea.hoverEnabled: false
      mouseArea.cursorShape: Qt.ArrowCursor
      backgroundColor: Theme.backgroundColor
    }

    AppListItem {
      visible: !dataModel.hasDesktopApp

      leftItem: Item {
        height: dp(24)
        width: height
        anchors.verticalCenter: parent.verticalCenter

        AppImage {
          id: slippiImg2
          anchors.fill: parent
          visible: false
          source: "../../../assets/img/slippi.svg"
          fillMode: Image.PreserveAspectFit
        }

        ColorOverlay {
          anchors.fill: parent
          source: slippiImg2
          color: Theme.tintColor
        }
      }

      text: "Download Desktop App (Launcher)"
      detailText: Constants.desktopAppDownloadUrl

      onSelected: nativeUtils.openUrl(Constants.desktopAppDownloadUrl)
    }

    SimpleSection {
      title: "Melee ISO file"
    }

    AppListItem {
      text: "Click to select your Melee ISO file..."
      detailText: "Used to auto-play replays & combos in the replay Dolphin.
Leave empty to start an ISO manually, which is useful if your replays are from different Melee mods/versions."

      onSelected: fileDialogIso.open()

      FileDialog {
        id: fileDialogIso
        title: "Select Melee ISO file"
        fileMode: FileDialog.OpenFile
        nameFilters: ["ISO files (*.iso)"]
        currentFolder: filenameToUri(fileUtils.getAbsolutePathFromUrlString(dataModel.meleeIsoPath))

        onAccepted: dataModel.meleeIsoPath = uriToFilename(selectedFile)
      }

      rightItem: AppToolButton {
        iconType: IconType.trash
        toolTipText: "Reset ISO path"
        visible: dataModel.hasMeleeIso
        anchors.verticalCenter: parent.verticalCenter

        onClicked: dataModel.meleeIsoPath = ""
      }
    }

    AppListItem {
      text: dataModel.meleeIsoPath
      detailText: dataModel.hasMeleeIso ? "File exists." : "Melee ISO not found."

      leftItem: Item {
        height: dp(24)
        width: height
        anchors.verticalCenter: parent.verticalCenter

        Icon {
          anchors.centerIn: parent
          size: dp(24)
          color: dataModel.hasMeleeIso ? Theme.tintColor : "red"
          icon: dataModel.hasMeleeIso ? IconType.check : IconType.times
        }
      }

      enabled: false
      backgroundColor: Theme.backgroundColor
    }

    SimpleSection {
      title: "Video output"
    }

    AppListItem {
      id: videoInfoItem
      text: "Slippipedia can automatically save playback as video files."
      detailText: "To use this, make sure to enable 'Dump Frames' and 'Dump Audio' under the 'Movie' menu in the Replay Dolphin (not the normal Netplay Dolphin)."

      mouseArea.hoverEnabled: false
      mouseArea.cursorShape: Qt.ArrowCursor
      backgroundColor: Theme.backgroundColor

      rightItem: AppToolButton {
        iconItem.visible: false
        toolTipText: "Configure playback Dolphin"

        visible: fileUtils.existsFile(dataModel.desktopDolphinPath)
        onClicked: Utils.startCommand(dataModel.desktopDolphinPath, [])

        AppImage {
          anchors.centerIn: parent
          width: parent.iconItem.size
          height: width
          source: "../../../assets/img/slippi.svg"
          fillMode: Image.PreserveAspectFit
          mipmap: true
        }
      }
    }

    AppListItem {
      text: "ffmpeg not found."
      detailText: "Slippipedia needs ffmpeg installed to create video files from replays. Make sure the ffmpeg executable is in the path environment."
                  + (Qt.platform.os === "osx" ? " You can install ffmpeg via homebrew (brew install ffmpeg)." : "")
      visible: !dataModel.hasFfmpeg

      leftItem: Icon {
        icon: IconType.warning
        color: "yellow"
        anchors.verticalCenter: parent.verticalCenter
        size: dp(24)
      }

      mouseArea.hoverEnabled: false
      mouseArea.cursorShape: Qt.ArrowCursor
      backgroundColor: Theme.backgroundColor

      rightItem: AppToolButton {
        iconType: IconType.download
        toolTipText: qsTr("Download ffmpeg from %1").arg(Constants.ffmpegUrl)

        anchors.verticalCenter: parent.verticalCenter

        onClicked: nativeUtils.openUrl(Constants.ffmpegUrl)
      }
    }

    AppListItem {
      text: "ffmpeg found (" + dataModel.ffmpegYear + ")"
      detailText: "Detected version: " + dataModel.ffmpegVersion
      visible: dataModel.hasFfmpeg

      leftItem: Icon {
        icon: IconType.check
        color: Theme.tintColor
        anchors.verticalCenter: parent.verticalCenter
        size: dp(24)
      }

      mouseArea.hoverEnabled: false
      mouseArea.cursorShape: Qt.ArrowCursor
      backgroundColor: Theme.backgroundColor
    }

    AppListItem {
      text: "Save dolphin frame dumps"
      detailText: dataModel.videoOutputEnabled
                  ? "Frame dumps from Dolphin will be saved to the below folder after playing a replay or punish."
                  : "Enable to save Dolphin frame dumps to the below folder after playing a replay or punish."

      onSelected: dataModel.videoOutputEnabled = !dataModel.videoOutputEnabled

      leftItem: Item {
        height: dp(24)
        width: height
        anchors.verticalCenter: parent.verticalCenter

        Icon {
          anchors.centerIn: parent
          size: dp(24)
          color: dataModel.videoOutputEnabled ? Theme.tintColor : "red"
          icon: dataModel.videoOutputEnabled ? IconType.check : IconType.times
        }
      }
    }

    AppListItem {
      text: "Auto-delete original frame dumps"
      detailText: dataModel.autoDeleteFrameDumps
                  ? "Original frame dumps from Dolphin will automatically be deleted after saving a replay."
                  : "Original frame dumps will remain in the Dolphin/User folder after saving a replay."

      onSelected: dataModel.autoDeleteFrameDumps = !dataModel.autoDeleteFrameDumps

      leftItem: Item {
        height: dp(24)
        width: height
        anchors.verticalCenter: parent.verticalCenter

        Icon {
          anchors.centerIn: parent
          size: dp(24)
          color: dataModel.autoDeleteFrameDumps ? Theme.tintColor : "red"
          icon: dataModel.autoDeleteFrameDumps ? IconType.check : IconType.times
        }
      }
    }

    AppListItem {
      text: "Replay videos saved to: (click to select new folder)"
      detailText: dataModel.videoOutputPath

      rightItem: Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: dp(Theme.contentPadding)

        AppToolButton {
          iconType: IconType.trash
          toolTipText: qsTr("Reset Video output folder to default: %1").arg(dataModel.videoOutputPathDefault)
          anchors.verticalCenter: parent.verticalCenter

          onClicked: dataModel.videoOutputPath = dataModel.videoOutputPathDefault
        }

        AppToolButton {
          iconType: dataModel.hasVideoOutputPath ? IconType.folderopen : IconType.times
          toolTipText: dataModel.hasVideoOutputPath
                       ? Qt.platform.os === "osx"
                         ? "Show in finder"
                         : "Show in file explorer"
          : "Path does not exist."

          enabled: dataModel.hasVideoOutputPath

          onClicked: Utils.exploreToFile(dataModel.videoOutputPath)
        }
      }

      onSelected: fileDialogVideoOputput.open()

      FolderDialog {
        id: fileDialogVideoOputput
        title: "Select Video output folder"
        currentFolder: filenameToUri(dataModel.videoOutputPath)

        onAccepted: dataModel.videoOutputPath = uriToFilename(selectedFolder)
      }
    }

    SimpleSection {
      title: "Punish & video settings"
    }

    TextInputField {
      labelWidth: dp(200)

      text: dataModel.punishPaddingFrames + ""

      labelText: "Padding frames for punish:"
      placeholderText: "Enter frames"

      toolTipText: "Replay additional frames at start and end of the punish."

      showOptions: false

      textInput.inputMethodHints: Qt.ImhDigitsOnly
      divider.visible: false

      textInput.validator: IntValidator { bottom: 0; top: 6000 }

      validationError: !textInput.acceptableInput
      validationText: "Enter bitrate in range 0 - 6000"

      onTextChanged: {
        if(textInput.acceptableInput) {
          dataModel.punishPaddingFrames = parseInt(text)
        }
      }
    }

    TextInputField {
      labelWidth: dp(200)

      text: dataModel.videoBitrate + ""

      labelText: "Video bitrate (kbps):"
      placeholderText: "Enter bitrate"

      toolTipText: "Bitrate for the converted video file.\nNote: the bitrate Dolphin exports at can be changed\nseparately in the User/Config/GFX.ini file (BitrateKbps)."

      showOptions: false

      textInput.inputMethodHints: Qt.ImhDigitsOnly
      divider.visible: false

      textInput.validator: IntValidator { bottom: 1000; top: 50000 }

      validationError: !textInput.acceptableInput
      validationText: "Enter bitrate in range 1000 - 50000"

      onTextChanged: {
        if(textInput.acceptableInput) {
          dataModel.videoBitrate = parseInt(text)
        }
      }
    }

    TextInputField {
      labelWidth: dp(200)

      text: dataModel.videoCodec

      labelText: "Video codec name:"
      placeholderText: "Enter codec name"

      toolTipText: "Name of codec to use for converting the video file.\nOnly change for advanced uses."

      showOptions: false

      divider.visible: false

      onTextChanged: {
        if(textInput.acceptableInput) {
          dataModel.videoCodec = text
        }
      }

      AppToolButton {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: dp(Theme.contentPadding)

        iconType: IconType.trash
        toolTipText: qsTr("Reset Video codec folder to default: %1").arg(dataModel.videoCodecDefault)

        visible: dataModel.videoCodec !== dataModel.videoCodecDefault
        onClicked: dataModel.videoCodec = dataModel.videoCodecDefault
      }
    }

    SimpleSection {
      title: "Created videos"
      visible: dataModel.createdVideos.length > 0
    }

    Repeater {
      model: dataModel.createdVideos

      AppListItem {
        text: modelData.progress >= 1
              ? "Video successfully saved."
              : !modelData.success
                ? qsTr("Could not save video: %1 (%2%)").arg(modelData.errorMessage).arg(dataModel.formatPercentage(modelData.progress))
                : qsTr("Currently encoding... (%1)").arg(dataModel.formatPercentage(modelData.progress))
        detailText: modelData.filePath

        mouseArea.hoverEnabled: false
        mouseArea.cursorShape: Qt.ArrowCursor
        backgroundColor: Theme.backgroundColor

        leftItem: Icon {
          size: dp(24)
          anchors.verticalCenter: parent.verticalCenter

          icon: modelData.progress >= 1 ? IconType.check : modelData.progress < 1 ? IconType.spinner : IconType.times
          color: modelData.progress >= 1 ? Theme.tintColor : modelData.progress < 1 ? Theme.textColor : "red"
        }

        rightItem: Row {
          anchors.verticalCenter: parent.verticalCenter
          spacing: dp(Theme.contentPadding)

          AppToolButton {
            iconType: IconType.play
            toolTipText: "Open file"
            anchors.verticalCenter: parent.verticalCenter

            visible: fileUtils.existsFile(modelData.filePath)
            onClicked: fileUtils.openFile(modelData.filePath)
          }

          AppToolButton {
            iconType: IconType.folderopen
            toolTipText: Qt.platform.os === "osx"
                           ? "Show in finder"
                           : "Show in file explorer"

            visible: fileUtils.existsFile(modelData.filePath)

            // call async in case this Repeater delegate object is destroyed in the meantime
            onClicked: Qt.callLater(() => Utils.exploreToFile(modelData.filePath))
          }
        }
      }
    }

  }

  function clearDb() {
    InputDialog.confirm(app, "Really clear the whole database?", function(accepted) {
      if(accepted) {
        dataModel.clearDatabase()
      }
    })
  }

  function uriToFilename(fileUri) {
    // remove scheme, then remove percent-encoding from file URI
    return decodeURIComponent(fileUtils.stripSchemeFromUrl(fileUri))
  }

  function filenameToUri(fileName) {
    return fileUtils.getUrlByAddingSchemeToFilename(encodeURIComponent(fileName))
  }
}
