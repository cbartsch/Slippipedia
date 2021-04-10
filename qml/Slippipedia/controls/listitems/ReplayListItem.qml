import QtQuick 2.0
import Felgo 3.0
import Slippipedia 1.0

AppListItem {
  id: replayListItem

  property var replayModel: model

  property alias toolBtnFolder: toolBtnFolder
  property alias toolBtnOpen: toolBtnOpen

  signal openReplayFolder(string filePath)
  signal openReplayFile(string filePath)

  property bool showPercent: showOptions

  readonly property bool showOptions: mouseArea.containsMouse || toolBtnFolder.hovered || toolBtnOpen.hovered || toolBtnSetup.hovered
  readonly property bool useShortStageName: replayListItem.width > dp(510)
  readonly property string stageNameProperty: useShortStageName  ? "name" : "shortName"
  readonly property var emptyStage: ({ name: "Unknown stage", shortName: "?" })
  readonly property var stageData: replayModel.stageId && replayModel.stageId >= 0 && MeleeData.stageMap[replayModel.stageId] || emptyStage
  readonly property string stageName: stageData[stageNameProperty]

  width: parent ? parent.width : 0

  backgroundColor: Theme.backgroundColor

  text: showOptions
        ? fileUtils.cropPathAndKeepFilename(replayModel.filePath)
        : qsTr("%1 - %2").arg(dataModel.formatTime(replayModel.duration)).arg(stageName)

  Binding { target: textItem; property: "maximumLineCount"; value: 1 }
//  Binding { target: textItem; property: "visible"; value: !mouseArea.containsMouse }

  leftItem: ReplayIcons {
    replayModel: replayListItem.replayModel
    anchors.verticalCenter: parent.verticalCenter

    showPercent: replayListItem.showPercent

    width: replayListItem.width > dp(412)
           ? implicitWidth
           : (replayListItem.width - dp(412) + implicitWidth)
  }

  rightItem: Row {
    visible: showOptions
    height: dp(48)
    spacing: dp(Theme.contentPadding) / 2

    AppToolButton {
      id: toolBtnFolder
      iconType: IconType.folder
      onClicked: openReplayFolder(replayModel.filePath)
      toolTipText: "Show in file explorer"
      height: width
      anchors.verticalCenter: parent.verticalCenter
    }

    AppToolButton {
      id: toolBtnOpen
      iconType: IconType.play
      toolTipText: "Open replay file"
      height: width
      anchors.verticalCenter: parent.verticalCenter

      visible: dataModel.hasDesktopApp
      onClicked: openReplayFile(replayModel.filePath)
    }

    AppToolButton {
      id: toolBtnSetup
      iconType: IconType.gear
      toolTipText: "Set Slippi Desktop App folder to play replays."
      height: width
      anchors.verticalCenter: parent.verticalCenter

      visible: !dataModel.hasDesktopApp
      onClicked: showSetup()
    }
  }
}
