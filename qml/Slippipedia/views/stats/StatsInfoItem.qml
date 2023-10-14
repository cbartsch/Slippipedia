import QtQuick 2.0
import QtQuick.Layouts 1.0
import Qt5Compat.GraphicalEffects 6.0
import Felgo 4.0

import Slippi 1.0
import Slippipedia 1.0

RowLayout {
  id: statsInfoItem

  property var stats: ({})

  property bool listButtonVisible: true
  property bool statsButtonVisible: true

  readonly property int gamesUnfinished: stats.numGames - stats.gamesFinished

  signal showList
  signal showStats

  property color textColor: Theme.textColor

  property bool showPlatform: true

  height: Math.max(content.height, dateText.height)

  Column {
    id: content
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignVCenter
    spacing: dp(2)

    AppText {
      id: dateText
      font.pixelSize: dp(16)
      color: statsInfoItem.textColor

      width: parent.width
      visible: text

      text: !stats || !(stats.dateFirst || stats.dateLast)
            ? stats.date ? dataModel.formatDate(stats.date) : ""
      : (dataModel.formatDate(stats.dateFirst) + " - " + dataModel.formatDate(stats.dateLast))
    }

    Row {
      width: parent.width
      height: dp(24)
      spacing: dp(Theme.contentPadding) / 2

      AppText {
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: dp(16)
        color: statsInfoItem.textColor
        visible: showPlatform

        text: stats.gameMode !== SlippiReplay.Unknown ? dataModel.gameModeName(stats.gameMode) : dataModel.platformText(stats.platform)
      }

      Item {
        anchors.verticalCenter: parent.verticalCenter
        width: dp(24)
        height: dp(24)
        visible: showPlatform

        RippleMouseArea {
          id: platformMouse
          anchors.fill: parent
          hoverEffectEnabled: true
          cursorShape: Qt.ArrowCursor
          backgroundColor: Theme.listItem.selectedBackgroundColor
          fillColor: backgroundColor
          opacity: 0.5
        }

        AppImage {
          id: platformIcon
          anchors.fill: parent
          source: dataModel.platformIcon(stats.platform)
          fillMode: Image.PreserveAspectFit
          visible: !colorOverlay.visible
          mipmap: true
        }

        // show dolphin icon in green
        ColorOverlay {
          id: colorOverlay
          anchors.fill: platformIcon
          source: platformIcon
          color: Theme.tintColor
          visible: stats.platform === "dolphin" || stats.platform === "slippi" || stats.platform === "network"
        }

        CustomToolTip {
          shown: platformMouse.containsMouse
          text: qsTr("Played on %1, Slippi version %2").arg(dataModel.platformDescription(stats.platform)).arg(stats.slippiVersion || "Unknown")
        }
      }

      AppText {
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: dp(16)
        color: statsInfoItem.textColor

        visible: "numGames" in stats

        text: qsTr("%1 game%2")
          .arg(stats.numGames)
          .arg(stats.numGames === 1 ? "" : "s")
      }
    }

    GameCountRow {
      width: parent.width
      visible: "gamesFinished" in stats
      textColor: statsInfoItem.textColor

      gamesWon: stats && stats.gamesWon || 0
      gamesFinished: stats && stats.gamesFinished || 0
    }
  }

  AppToolButton {
    Layout.preferredWidth: implicitWidth

    visible: listButtonVisible
    iconType: IconType.list
    toolTipText: "Show list of games"

    onClicked: showList()
  }

  AppToolButton {
    Layout.preferredWidth: implicitWidth

    visible: statsButtonVisible
    iconType: IconType.barchart
    toolTipText: "Show statistics for games"

    onClicked: showStats()
  }
}
