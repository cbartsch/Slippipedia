import QtQuick 2.0
import QtQuick.Layouts 1.0
import Felgo 3.0

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

  height: Math.max(content.height, dateText.height)

  Column {
    id: content
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignVCenter

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

    AppText {
      font.pixelSize: dp(16)
      color: statsInfoItem.textColor

      width: parent.width
      visible: "numGames" in stats

      text: qsTr("%1 game%2").arg(stats.numGames).arg(stats.numGames === 1 ? "" : "s")
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
