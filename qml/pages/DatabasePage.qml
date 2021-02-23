import Felgo 3.0

import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.2

BasePage {
  title: qsTr("Replay database")

  flickable.contentHeight: content.height

  Column {
    id: content
    width: parent.width

    SimpleSection {
      title: "Replay database"
    }

    AppListItem {
      visible: dataModel.dbNeedsUpdate

      text: "Database version outdated"
      detailText: qsTr("Your app's database version is outdated (%1 < %2). \
This happens when updating to a new app version. \
Please clear and re-build the database. \
Otherwise, some app features might not work properly. \
Click to clear database.").arg(dataModel.dbCurrentVersion).arg(dataModel.dbLatestVersion)

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
      title: "Replay folder"
    }

    AppListItem {
      text: dataModel.replayFolder || "Select replay folder..."
      onSelected: {
        console.log("open to", fileDialog.folder)
        fileDialog.open()
      }
      detailText: dataModel.allFiles.length +  " replays found."
    }

    SimpleSection {
      title: "Analyze"
      visible: !dataModel.isProcessing
    }

    AppListItem {
      text: qsTr("Analyze %1 replays").arg(dataModel.allFiles.length)

      visible: !dataModel.isProcessing

      onSelected: dataModel.parseReplays(dataModel.allFiles)
    }

    AppListItem {
      text: dataModel.newFiles
            ? qsTr("Analyze %1 new replays").arg(dataModel.newFiles.length)
            : "No new replays found."
      enabled: dataModel.newFiles
      visible: !dataModel.isProcessing

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
  }

  FileDialog {
    id: fileDialog
    title: "Please choose a file"
    selectMultiple: false
    selectFolder: true
    folder: fileUtils.getUrlByAddingSchemeToFilename(dataModel.replayFolder)

    onAccepted: dataModel.replayFolder = fileUtils.stripSchemeFromUrl(fileUrl)
    onRejected: console.log("Folder dialog canceled")
  }

  function clearDb() {
    InputDialog.confirm(app, "Really clear the whole database?", function(accepted) {
      if(accepted) {
        dataModel.clearDatabase()
      }
    })
  }
}
