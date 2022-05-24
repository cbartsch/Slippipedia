import QtQuick 2.0
import Felgo 4.0
import Slippipedia 1.0

AppListItem {
  id: replayListItem

  property var replayModel: model

  property alias toolBtnFolder: toolBtnFolder
  property alias toolBtnOpen: toolBtnOpen

  signal openReplayFolder(string filePath)
  signal openReplayFile(string filePath)

  property bool showPercent: showOptions

  readonly property bool showOptions: mouseArea.containsMouse ||
                                      toolBtnFolder.hovered || toolBtnOpen.hovered ||
                                      toolBtnSetup.hovered || toolBtnFavorite.hovered

  readonly property bool useShortStageName: replayListItem.width < dp(580 + (isFavorite ? 48 : 0))
  readonly property string stageNameProperty: useShortStageName ? "shortName" : "name"
  readonly property var emptyStage: ({ name: "Unknown stage", shortName: "?" })
  readonly property var stageData: replayModel.stageId && replayModel.stageId >= 0 && MeleeData.stageMap[replayModel.stageId] || emptyStage
  readonly property string stageName: stageData[stageNameProperty]
  readonly property bool isFavorite: toolBtnFavorite.checked

  width: parent ? parent.width : 0

  backgroundColor: Theme.backgroundColor

  text: showOptions ? fileUtils.cropPathAndKeepFilename(replayModel.filePath) : stageName

  Binding { target: textItem; property: "maximumLineCount"; value: 1 }

  leftItem: ReplayIcons {
    replayModel: replayListItem.replayModel
    anchors.verticalCenter: parent.verticalCenter

    showPercent: replayListItem.showPercent

    width: replayListItem.width > dp(412)
           ? implicitWidth
           : (replayListItem.width - dp(412) + implicitWidth)
  }

  Item {
    visible: isFavorite && !showOptions
    anchors.verticalCenter: parent.verticalCenter
    anchors.right: parent.right
    anchors.rightMargin: dp(Theme.contentPadding + 3) / 2
    width: dp(48)
    height: dp(48)

    Icon {
      anchors.centerIn: parent
      icon: IconType.star
      color: Theme.tintColor
    }
  }

  rightItem: Row {
    visible: showOptions
    height: dp(48)
    spacing: dp(Theme.contentPadding) / 2

    AppToolButton {
      id: toolBtnFolder
      iconType: IconType.folder
      onClicked: openReplayFolder(replayModel.filePath)
      toolTipText: Qt.platform.os === "osx" ? "Show in finder" : "Show in file explorer"
      height: width
      anchors.verticalCenter: parent.verticalCenter
    }

    AppToolButton {
      id: toolBtnOpen
      iconType: IconType.play
      toolTipText: "Start replay with Dolphin"
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

    AppToolButton {
      id: toolBtnFavorite
      iconType: IconType.star
      toolTipText: isFavorite ? "Unmark as favorite" : "Mark as favorite"
      checkable: true
      height: width
      anchors.verticalCenter: parent.verticalCenter

      checked: dataModel.hasFlag(replayModel.userFlag, dataModel.flagFavorite)
      onClicked: dataModel.setReplayFlag(replayModel.replayId, dataModel.flagFavorite, checked)
    }
  }
}
