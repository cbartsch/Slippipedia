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

  property ListView replayListView: ListView.view

  readonly property bool showOptions: !replayListView.dragging &&
                                      mouseArea.containsMouse || icons.stockHovered ||
                                      [toolBtnStats, toolBtnFolder, toolBtnOpen, toolBtnSetup, toolBtnFavorite].some(btn => btn.hovered)

  readonly property var stockSummary: showOptions
                                      ? dataModel.globalDataBase.getStockSummary(replayModel.replayId, [replayModel.port1, replayModel.port2])
                                      : null

  readonly property bool useShortStageName: replayListItem.width < dp(580 + (isFavorite ? 48 : 0))
  readonly property string stageNameProperty: useShortStageName ? "shortName" : "name"
  readonly property var emptyStage: ({ name: "Unknown stage", shortName: "?" })
  readonly property var stageData: replayModel.stageId && replayModel.stageId >= 0 && MeleeData.stageMap[replayModel.stageId] || emptyStage
  readonly property string stageName: stageData[stageNameProperty]
  readonly property bool isFavorite: toolBtnFavorite.checked

  width: parent ? parent.width : 0

  backgroundColor: Theme.backgroundColor
  mouseArea.cursorShape: Qt.ArrowCursor

  text: showOptions ? ""/*fileUtils.cropPathAndKeepFilename(replayModel.filePath)*/ : stageName

  Binding { target: textItem; property: "maximumLineCount"; value: 1 }

  leftItem: ReplayIcons {
    id: icons
    anchors.verticalCenter: parent.verticalCenter

    replayModel: replayListItem.replayModel
    stockSummary: replayListItem.stockSummary

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

    AppIcon {
      anchors.centerIn: parent
      iconType: IconType.star
      color: Theme.tintColor
    }
  }

  rightItem: Rectangle {
    id: optionsItem
    visible: showOptions
    height: dp(44)
    width: optionsRow.width + dp(Theme.contentPadding) * 2/3
    color: Theme.backgroundColor
    border.width: dp(1)
    border.color: Theme.controlBackgroundColor
    radius: toolBtnFolder.radius
    anchors.verticalCenter: parent.verticalCenter

    Row {
      id: optionsRow
      spacing: dp(Theme.contentPadding) / 3
      anchors.centerIn: parent

      AppToolButton {
        id: toolBtnStats
        iconType: IconType.barchart
        toolTipText: "Show stats for single replay"
        height: width
        anchors.verticalCenter: parent.verticalCenter

        onClicked: app.showStats({ replayId: replayModel.replayId })
      }

      AppToolButton {
        id: toolBtnFolder
        iconType: IconType.folder
        toolTipText: Qt.platform.os === "osx" ? "Show in finder" : "Show in file explorer"
        height: width
        anchors.verticalCenter: parent.verticalCenter

        onClicked: openReplayFolder(replayModel.filePath)
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
}
