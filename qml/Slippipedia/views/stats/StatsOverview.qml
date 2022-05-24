import QtQuick 2.0
import Felgo 4.0

import Slippipedia 1.0

Column {
  AppListItem {
    text: "Data from all matched games"
    detailText: "Data calculated only from games matched by the selected filter."
    enabled: false
    backgroundColor: Theme.backgroundColor
  }

  SimpleSection {
    title: "Game stats"
  }

  AppListItem {
    text: qsTr("Average game time: %1 (%2 frames)")
    .arg(dataModel.formatTime(stats.averageGameDuration))
    .arg(stats.averageGameDuration.toFixed(0))

    backgroundColor: Theme.backgroundColor
    enabled: false
  }

  AppListItem {
    text: qsTr("Total game time: %1 (%2 frames)")
    .arg(dataModel.formatTime(stats.totalGameDuration))
    .arg(dataModel.formatNumber(stats.totalGameDuration))

    backgroundColor: Theme.backgroundColor
    enabled: false
  }

  SimpleSection {
    title: "Player stats"
  }

  AppListItem {
    backgroundColor: Theme.backgroundColor
    enabled: false
    visible: dataModel.playerFilter.hasPlayerFilter

    leftItem: GameCountRow {
      anchors.verticalCenter: parent.verticalCenter

      gamesWon: stats.totalReplaysFilteredWon
      gamesFinished: stats.totalReplaysFilteredWithResult
    }
  }

  AppListItem {
    text: "No player filter configured."
    detailText: "Filter by player code, name or port to see win rate."

    visible: !dataModel.playerFilter.hasPlayerFilter
    onSelected: showFilteringPage(0)
  }

  AppListItem {
    text: qsTr("Games not finished: %1 (%2/%3)")
    .arg(dataModel.formatPercentage(stats.tieRate))
    .arg(stats.totalReplaysFilteredWithTie)
    .arg(stats.totalReplaysFiltered)

    backgroundColor: Theme.backgroundColor
    enabled: false
  }

  SimpleSection {
    title: "Top chars used"
  }

  CharacterGrid {
    stats: statisticsPage.stats
    sourceModel: stats.statsPlayer.charDataCss

    enabled: false
    highlightFilteredChar: false
    showData: true
    showIcon: true
    sortByCssPosition: true
    hideCharsWithNoReplays: false
  }

  SimpleSection {
    title: "Top chars used (opponent)"
  }

  AppListItem {
    text: "No player filter configured."
    detailText: "Filter by player code, name or port to see opposing characters."

    visible: !dataModel.playerFilter.hasPlayerFilter
    onSelected: showFilteringPage(0)
  }

  CharacterGrid {
    visible: dataModel.playerFilter.hasPlayerFilter

    stats: statisticsPage.stats
    sourceModel: stats.statsOpponent.charDataCss

    enabled: false
    highlightFilteredChar: false
    showData: true
    showIcon: true
    sortByCssPosition: true
    hideCharsWithNoReplays: false
  }


  SimpleSection {
    title: "Top stages"
  }

  StageGrid {
    width: parent.width

    sourceModel: stats ? stats.stageDataSss : []
    stats: statisticsPage.stats

    hideStagesWithNoReplays: true
    sortByCount: true
    showIcon: true

    enabled: false
    highlightFilteredStage: false
  }
}
