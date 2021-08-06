import Felgo 3.0

import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.0

import Slippipedia 1.0

BasePage {
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

      FileDialog {
        id: fileDialogReplays
        title: "Select replay folder"
        selectMultiple: false
        selectFolder: true
        folder: fileUtils.getUrlByAddingSchemeToFilename(dataModel.replayFolder)

        onAccepted: dataModel.replayFolder = fileUtils.stripSchemeFromUrl(fileUrl)
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

      backgroundColor: Theme.backgroundColor
      enabled: false
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
      detailText: "Used to play replays & combos."

      onSelected: fileDialogDesktop.open()

      FileDialog {
        id: fileDialogDesktop
        title: "Select Slippi Desktop App folder"
        selectMultiple: false
        selectFolder: true
        folder: fileUtils.getUrlByAddingSchemeToFilename(dataModel.desktopAppFolder)

        onAccepted: dataModel.desktopAppFolder = fileUtils.stripSchemeFromUrl(fileUrl)
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

      enabled: false
      backgroundColor: Theme.backgroundColor
    }

    AppListItem {
      visible: !dataModel.hasDesktopApp

      property url desktopAppDownloadUrl: "https://slippi.gg/downloads"

      leftItem: Item {
        height: dp(24)
        width: height
        anchors.verticalCenter: parent.verticalCenter

        AppImage {
          id: slippiImg
          anchors.fill: parent
          visible: false
          source: "../../../assets/img/slippi.svg"
          fillMode: Image.PreserveAspectFit
        }

        ColorOverlay {
          anchors.fill: parent
          source: slippiImg
          color: Theme.tintColor
        }
      }

      text: "Download Desktop App (Launcher)"
      detailText: desktopAppDownloadUrl

      onSelected: nativeUtils.openUrl(desktopAppDownloadUrl)
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
        selectMultiple: false
        selectFolder: false
        nameFilters: ["ISO files (*.iso)"]
        folder: fileUtils.getUrlByAddingSchemeToFilename(dataModel.meleeIsoPath)

        onAccepted: dataModel.meleeIsoPath = fileUtils.stripSchemeFromUrl(fileUrl)
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
  }

  function clearDb() {
    InputDialog.confirm(app, "Really clear the whole database?", function(accepted) {
      if(accepted) {
        dataModel.clearDatabase()
      }
    })
  }
}
