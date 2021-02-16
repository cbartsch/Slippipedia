import Felgo 3.0

import QtQuick 2.0

import "../controls"
import "../model"

BasePage {
  id: statisticsPage
  title: qsTr("Replay statistics")

  rightBarItem: NavigationBarRow {
    LoadingIcon {
    }

    IconButtonBarItem {
      icon: IconType.filter
      onClicked: showFilteringPage()
    }
  }

  FilterInfoItem {
    id: header
    stats: statisticsPage.stats
    clickable: true
  }

  Flickable {
    anchors.fill: parent
    anchors.topMargin: header.height
    contentHeight: content.height
    clip: true

    Column {
      id: content
      width: parent.width

      SimpleSection {
        title: "Game stats"
      }

      AppListItem {
        text: qsTr("Average game time: %1 (%3 frames)")
        .arg(dataModel.formatTime(stats.averageGameDuration))
        .arg(stats.averageGameDuration.toFixed(0))

        backgroundColor: Theme.backgroundColor
        enabled: false
      }

      SimpleSection {
        title: "Player stats"
      }

      AppListItem {
        text: qsTr("Win rate: %1 (%2/%3)")
        .arg(dataModel.formatPercentage(stats.winRate))
        .arg(stats.totalReplaysFilteredWon)
        .arg(stats.totalReplaysFilteredWithResult)

        backgroundColor: Theme.backgroundColor
        enabled: false
        visible: dataModel.playerFilter.hasPlayerFilter
      }

      AppListItem {
        text: "No name filter configured."
        detailText: "Filter by Slippi code and/or name to see win rate."

        visible: !dataModel.playerFilter.hasPlayerFilter
        onSelected: showFilteringPage()
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
        title: "Tech skill stats"
      }

      AppListItem {
        text: qsTr("L-cancels: %1 (%2 / %3)")
        .arg(dataModel.formatPercentage(stats.lCancelRate))
        .arg(stats.lCancels).arg(stats.lCancelsMissed + stats.lCancels)

        backgroundColor: Theme.backgroundColor
        enabled: false
      }

      SimpleSection {
        title: "Tech skill stats (opponent)"
      }

      AppListItem {
        text: qsTr("L-cancels: %1 (%2 / %3)").arg(dataModel.formatPercentage(stats.lCancelRateOpponent))
        .arg(stats.lCancelsOpponent).arg(stats.lCancelsMissedOpponent + stats.lCancelsOpponent)

        backgroundColor: Theme.backgroundColor
        enabled: false
      }

      SimpleSection {
        title: "Top chars used"
      }

      CharacterGrid {
        stats: statisticsPage.stats
        sourceModel: stats.charDataCss

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
        text: "No name filter configured."
        detailText: "Filter by Slippi code and/or name to see opposing characters."

        visible: !dataModel.playerFilter.hasPlayerFilter
        onSelected: showFilteringPage()
      }

      CharacterGrid {
        visible: dataModel.playerFilter.hasPlayerFilter

        stats: statisticsPage.stats
        sourceModel: stats.charDataOpponentCss

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

        sourceModel: stats.stageDataSss
        stats: statisticsPage.stats

        hideStagesWithNoReplays: true
        sortByCount: true
        showIcon: true

        enabled: false
        highlightFilteredStage: false
      }

      SimpleSection {
        title: "Top player tags"
      }

      NameGrid {
        model: dataModel.getTopPlayerTags(columns * 5)
      }

      SimpleSection {
        title: "Top player tags (opponent)"
      }

      AppListItem {
        text: "No name filter configured."
        detailText: "Filter by Slippi code and/or name to see opposing player tags."

        visible: !dataModel.playerFilter.hasPlayerFilter
        onSelected: showFilteringPage()
      }

      NameGrid {
        visible: dataModel.playerFilter.hasPlayerFilter
        model: dataModel.getTopPlayerTagsOpponent(columns * 5)
      }

      SimpleSection {
        title: "Top Slippi codes (opponent)"
      }

      AppListItem {
        text: "No name filter configured."
        detailText: "Filter by Slippi code and/or name to see opposing Slippi codes."

        visible: !dataModel.playerFilter.hasPlayerFilter
        onSelected: showFilteringPage()
      }

      NameGrid {
        visible: dataModel.playerFilter.hasPlayerFilter
        model: dataModel.getTopSlippiCodesOpponent(columns * 5)
      }
    }
  }
}
