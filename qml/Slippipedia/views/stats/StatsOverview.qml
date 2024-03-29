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
    text: qsTr("Games finished: %1 (%2)")
    .arg(dataModel.formatPercentage(stats.finishedRate))
    .arg(dataModel.formatNumber(stats.totalReplaysFilteredFinished))

    backgroundColor: Theme.backgroundColor
    enabled: false
  }

  AppListItem {
    text: qsTr("Games tied: %1 (%2)")
    .arg(dataModel.formatPercentage(stats.tieRate))
    .arg(dataModel.formatNumber(stats.totalReplaysFilteredWithTie))

    backgroundColor: Theme.backgroundColor
    enabled: false
  }

  AppListItem {
    text: qsTr("LRAS - Me: %1 (%2) / Opponent: %3 (%4)")
    .arg(dataModel.formatPercentage(stats.statsPlayer.lrasCount.avg))
    .arg(dataModel.formatNumber(stats.statsPlayer.lrasCount.value))
    .arg(dataModel.formatPercentage(stats.statsOpponent.lrasCount.avg))
    .arg(dataModel.formatNumber(stats.statsOpponent.lrasCount.value))

    backgroundColor: Theme.backgroundColor
    enabled: false
  }

  SimpleSection {
    title: "Top chars used"
  }

  CharacterGrid {
    stats: statisticsPage.stats
    sourceModel: stats.statsPlayer.charDataCss

    highlightFilteredChar: false
    showData: true
    showIcon: true
    enableEmpty: false
    sortByCssPosition: true
    hideCharsWithNoReplays: false

    toolTipText: "List all %1 games as %2"

    onCharSelected: (charId, isSelected) => showList({ charId: charId, exact: true, sourceFilter: stats.dataBase.filterSettings })
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

    highlightFilteredChar: false
    showData: true
    showIcon: true
    enableEmpty: false
    sortByCssPosition: true
    hideCharsWithNoReplays: false

    toolTipText: "List all %1 games vs %2"

    onCharSelected: (charId, isSelected) => showList({ opponentCharId: charId, exact: true, sourceFilter: stats.dataBase.filterSettings })
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

    highlightFilteredStage: false

    toolTipText: "List all %1 games on %2"

    onStageSelected: (stageId, isSelected) => showList({ stageId: stageId, exact: true, sourceFilter: stats.dataBase.filterSettings })
  }
}
