import QtQuick 2.0
import Felgo 3.0
import Slippi 1.0

import "../controls"
import "../visual"
import "../../model/data"

AppListItem {
  id: replayListItem

  backgroundColor: Theme.backgroundColor
  mouseArea.enabled: false

  text: stageId && stageId >= 0
        ? qsTr("%1 - %2").arg(dataModel.formatTime(duration))
          .arg((MeleeData.stageMap[stageId] || {
                  name: "Unknown stage", shortName: "?"
                })[replayListItem.width > dp(550) ? "name" : "shortName"])
        : ""

  Binding {
    target: textItem
    property: "maximumLineCount"
    value: 1
  }

  leftItem: ReplayIcons {
    replayModel: model
    anchors.verticalCenter: parent.verticalCenter

    width: replayListItem.width > dp(500)
           ? implicitWidth
           : (replayListItem.width - dp(500) + implicitWidth)
  }

  rightItem: Row {
    height: dp(48)
    spacing: dp(Theme.contentPadding) / 2
    AppToolButton {
      iconType: IconType.folder
      onClicked: openReplayFolder(filePath)
      toolTipText: qsTr("Show in file explorer: %1").arg(fileUtils.cropPathAndKeepFilename(filePath))
      height: width
      anchors.verticalCenter: parent.verticalCenter
    }
    AppToolButton {
      iconType: IconType.play
      onClicked: openReplay(filePath)
      toolTipText: "Open replay file"
      height: width
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  function openReplayFolder(filePath) {
    Utils.exploreToFile(filePath)
  }

  function openReplay(filePath) {
    fileUtils.openFile(filePath)
  }
}
