import Felgo 3.0

import QtQuick 2.0
import QtQuick.Layouts 1.12

import "../views/controls"
import "../views/grids"
import "../views/visual"
import "../model"

BasePage {
  id: statisticsPage
  title: qsTr("Replay statistics")

  property bool filterChangeable: true
  readonly property int nameColumns: Math.round(width / dp(200))

  onSelected: stats.refresh(nameColumns * 5)
  filterModal.onClosed: if(stats) stats.refresh(nameColumns * 5)

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
    clickable: filterChangeable
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

      StatsGrid {
        width: parent.width

        title: "Tech skill stats"

        statsList: [ stats.statsPlayer, stats.statsOpponent ]

        rowData: [
          { header: "Aerials L-cancelled", property: "lCancelRate", type: "percentage" },
          { header: "Edge/teeter-cancelled", property: "edgeCancelRate", type: "percentage" },
          { header: "Laggy aerials", property: "nonCancelledAerialRate", type: "percentage" },
          { header: "Intangible ledgedashes / game", property: "avgLedgedashes", type: "decimal" },
          { header: "Average GALINT", property: "avgGalint", type: "decimal" },
        ]
      }

      StatsGrid {
        width: parent.width

        title: "Offensive stats"

        statsList: [ stats.statsPlayer, stats.statsOpponent ]

        rowData: [
          { header: "Total stocks taken", property: "totalStocksTaken", type: "number" },
          { header: "Stocks taken / game", property: "averageStocksTaken", type: "decimal" },
          { header: "Total damage dealt", property: "totalDamageDealt", type: "number" },
          { header: "Damage / minute", property: "damagePerMinute", type: "decimal" },
          { header: "Avg. Kill %", property: "damagePerStock", type: "decimal" },
        ]
      }

      StatsGrid {
        width: parent.width

        title: "Other stats"

        statsList: [ stats.statsPlayer, stats.statsOpponent ]

        rowData: [
          { header: "Total taunts", property: "numTaunts", type: "number" },
          { header: "Taunts / game", property: "avgTaunts", type: "decimal" },
        ]
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
        text: "No name filter configured."
        detailText: "Filter by Slippi code and/or name to see opposing characters."

        visible: !dataModel.playerFilter.hasPlayerFilter
        onSelected: showFilteringPage()
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

      SimpleSection {
        title: "Top player tags"
      }

      NameGrid {
        model: stats.statsPlayer.topPlayerTags
        columns: nameColumns
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
        model: stats.statsOpponent.topPlayerTags
        columns: nameColumns
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
        model: stats.statsOpponent.topSlippiCodes
        columns: nameColumns
      }

      Item {
        width: 1
        height: dp(Theme.contentPadding) / 2
      }
    }
  }
}
