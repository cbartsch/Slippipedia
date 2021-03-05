import QtQuick 2.0
import Felgo 3.0
import Slippipedia 1.0

AppListItem {
  id: replayListItem

  backgroundColor: Theme.backgroundColor

  text: stageId && stageId >= 0
        ? qsTr("%1 - %2").arg(dataModel.formatTime(duration))
          .arg((MeleeData.stageMap[stageId] || {
                  name: "Unknown stage", shortName: "?"
                })[replayListItem.width > dp(450) ? "name" : "shortName"])
        : ""

  Binding { target: textItem; property: "maximumLineCount"; value: 1 }
//  Binding { target: textItem; property: "visible"; value: !mouseArea.containsMouse }

  leftItem: ReplayIcons {
    replayModel: model
    anchors.verticalCenter: parent.verticalCenter

    width: replayListItem.width > dp(410)
           ? implicitWidth
           : (replayListItem.width - dp(410) + implicitWidth)
  }

  rightItem: Row {
    visible: mouseArea.containsMouse || toolBtnFolder.hovered || toolBtnOpen.hovered
    height: dp(48)
    spacing: dp(Theme.contentPadding) / 2
    AppToolButton {
      id: toolBtnFolder
      iconType: IconType.folder
      onClicked: openReplayFolder(filePath)
      toolTipText: qsTr("Show in file explorer: %1").arg(fileUtils.cropPathAndKeepFilename(filePath))
      height: width
      anchors.verticalCenter: parent.verticalCenter
    }
    AppToolButton {
      id: toolBtnOpen
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
