import QtQuick 2.0
import QtQuick.Layouts 1.0
import Felgo 3.0

import "../controls"

RowLayout {
  property var stats: ({})

  property bool listButtonVisible: true
  property bool statsButtonVisible: true

  readonly property int gamesUnfinished: stats.numGames - stats.gamesFinished

  signal showList
  signal showStats

  Column {
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignVCenter

    AppText {
      font.pixelSize: dp(16)
      color: Theme.secondaryTextColor

      width: parent.width
      visible: text

      text: !stats || !(stats.dateFirst || stats.dateLast)
            ? "" : (dataModel.formatDate(stats.dateFirst) + " - " + dataModel.formatDate(stats.dateLast))
    }

    AppText {
      font.pixelSize: dp(16)
      color: Theme.secondaryTextColor

      width: parent.width

      text: qsTr("%1 games").arg(stats.numGames)
    }

    AppText {
      Layout.preferredWidth: parent.width
      font.pixelSize: dp(16)
      color: Theme.secondaryTextColor

      maximumLineCount: 1
      elide: Text.ElideRight

      width: parent.width
      text: !stats ? "" : !dataModel.playerFilter.hasPlayerFilter ? "Configure name filter to see win rate"
                                                                  : qsTr("Win Rate: %3 (%1 / %2)")
      .arg(stats.gamesWon).arg(stats.gamesFinished)
      .arg(dataModel.formatPercentage(stats.gamesWon / stats.gamesFinished))

      RippleMouseArea {
        anchors.fill: parent
        onClicked: showFilteringPage()
      }
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
