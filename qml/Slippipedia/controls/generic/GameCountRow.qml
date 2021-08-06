import QtQuick 2.0
import Felgo 3.0

import Slippipedia 1.0

Flow {
  id: gameCountRow

  property int gamesWon
  property int gamesFinished

  property color textColor: Theme.textColor

  readonly property real winRate: gamesWon / gamesFinished || 0

  spacing: dp(4)

  AppText {
    font.pixelSize: dp(16)
    color: gameCountRow.textColor

    maximumLineCount: 1
    elide: Text.ElideRight

    text: dataModel.playerFilter.hasPlayerFilter ? "Win rate:" : "Configure player filter to see win rate"

    RippleMouseArea {
      anchors.fill: parent
      onClicked: showFilteringPage(0)
      enabled: !dataModel.playerFilter.hasPlayerFilter

      hoverEffectEnabled: true
      backgroundColor: Theme.listItem.selectedBackgroundColor
      fillColor: backgroundColor
      opacity: 0.5
    }
  }

  AppText {
    text: qsTr("%3").arg(dataModel.formatPercentage(winRate))
    font.bold: true
    color: dataModel.winRateColor(winRate)
    visible: dataModel.playerFilter.hasPlayerFilter
  }

  AppText {
    text:  qsTr("(%1 / %2)").arg(gamesWon).arg(gamesFinished)
    color: gameCountRow.textColor
    visible: dataModel.playerFilter.hasPlayerFilter
  }
}
