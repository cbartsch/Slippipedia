import QtQuick 2.0
import Felgo 3.0

import "../model"

AppListItem {
  id: replayListItem

  backgroundColor: Theme.backgroundColor
  mouseArea.enabled: false

  text: stageId && stageId >= 0
        ? qsTr("%1 - %2").arg(dataModel.formatTime(duration))
          .arg((MeleeData.stageMap[stageId] || {
                  name: "Unknown stage", shortName: "?"
                })[replayListItem.width > dp(510) ? "name" : "shortName"])
        : ""

  Binding {
    target: textItem
    property: "maximumLineCount"
    value: 1
  }

  leftItem: ReplayIcons {
    replayModel: model
    anchors.verticalCenter: parent.verticalCenter

    width: replayListItem.width > dp(455)
           ? implicitWidth
           : (replayListItem.width - dp(455) + implicitWidth)
  }

  rightItem: IconButtonBarItem {
    icon: IconType.play
    onClicked: openReplay(filePath)
    height: width
    anchors.verticalCenter: parent.verticalCenter
  }

  function openReplay(filePath) {
    fileUtils.openFile(filePath)
  }
}
