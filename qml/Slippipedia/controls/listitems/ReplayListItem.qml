import QtQuick 2.0
import Felgo 3.0
import Slippipedia 1.0

AppListItem {
  id: replayListItem

  property var replayModel: model

  width: parent ? parent.width : 0

  backgroundColor: Theme.backgroundColor

  text: replayModel.stageId && replayModel.stageId >= 0
        ? qsTr("%1 - %2").arg(dataModel.formatTime(replayModel.duration))
          .arg((MeleeData.stageMap[replayModel.stageId] || {
                  name: "Unknown stage", shortName: "?"
                })[replayListItem.width > dp(510) ? "name" : "shortName"])
        : ""

  Binding { target: textItem; property: "maximumLineCount"; value: 1 }
//  Binding { target: textItem; property: "visible"; value: !mouseArea.containsMouse }

  leftItem: ReplayIcons {
    replayModel: replayListItem.replayModel
    anchors.verticalCenter: parent.verticalCenter

    width: replayListItem.width > dp(412)
           ? implicitWidth
           : (replayListItem.width - dp(412) + implicitWidth)
  }

  rightItem: Row {
    visible: mouseArea.containsMouse || toolBtnFolder.hovered || toolBtnOpen.hovered
    height: dp(48)
    spacing: dp(Theme.contentPadding) / 2

    AppToolButton {
      id: toolBtnFolder
      iconType: IconType.folder
      onClicked: openReplayFolder(replayModel.filePath)
      toolTipText: qsTr("Show in file explorer: %1").arg(fileUtils.cropPathAndKeepFilename(filePath))
      height: width
      anchors.verticalCenter: parent.verticalCenter
    }

    AppToolButton {
      id: toolBtnOpen
      iconType: IconType.play
      onClicked: openReplay(replayModel.filePath)
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
