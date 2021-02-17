import Felgo 3.0

import QtQuick 2.0
import QtQuick.Layouts 1.12

import "../controls"
import "../model"

BasePage {
  id: statisticsPage
  title: qsTr("Replay statistics")

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

      SimpleSection {
        title: "Tech skill stats"
      }

      Item {
        width: 1
        height: dp(Theme.contentPadding)
      }

      GridLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: columnSpacing
        columnSpacing: dp(Theme.contentPadding)
        rowSpacing: columnSpacing / 2
        columns: dataModel.playerFilter.hasPlayerFilter ? 3 : 2

        AppText {
          text: "Stat"
          color: Theme.secondaryTextColor
          Layout.preferredWidth: statisticsPage.width * 0.3
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: dataModel.playerFilter.hasPlayerFilter ? "Me" : "Player"
          color: Theme.secondaryTextColor
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: "Opponent"
          color: Theme.secondaryTextColor
          visible: dataModel.playerFilter.hasPlayerFilter
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.3
          text: "Aerials L-cancelled"
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: qsTr("%1").arg(dataModel.formatPercentage(stats.lCancelRate))
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: qsTr("%1").arg(dataModel.formatPercentage(stats.lCancelRateOpponent))
          visible: dataModel.playerFilter.hasPlayerFilter
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.3
          text: "Edge/teeter-cancelled"
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: qsTr("%1").arg(dataModel.formatPercentage(stats.edgeCancelRate))
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: qsTr("%1").arg(dataModel.formatPercentage(stats.edgeCancelRateOpponent))
          visible: dataModel.playerFilter.hasPlayerFilter
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.3
          text: "Laggy aerials"
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: qsTr("%1").arg(dataModel.formatPercentage(stats.nonCancelledAerialRate))
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: qsTr("%1").arg(dataModel.formatPercentage(stats.nonCancelledAerialRateOpponent))
          visible: dataModel.playerFilter.hasPlayerFilter
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.3
          text: "Intangible ledgedashes / game"
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: qsTr("%1").arg(stats.avgLedgedashes.toFixed(2))
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: qsTr("%1").arg(stats.avgLedgedashesOpponent.toFixed(2))
          visible: dataModel.playerFilter.hasPlayerFilter
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.3
          text: "Average GALINT"
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: qsTr("%1").arg(stats.avgGalint.toFixed(2))
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: qsTr("%1").arg(stats.avgGalintOpponent.toFixed(2))
          visible: dataModel.playerFilter.hasPlayerFilter
        }
      }

      SimpleSection {
        title: "Offensive stats"
      }

      Item {
        width: 1
        height: dp(Theme.contentPadding)
      }

      GridLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: columnSpacing
        columnSpacing: dp(Theme.contentPadding)
        rowSpacing: columnSpacing / 2
        columns: dataModel.playerFilter.hasPlayerFilter ? 3 : 2

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.3
          text: "Stat"
          color: Theme.secondaryTextColor
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: dataModel.playerFilter.hasPlayerFilter ? "Me" : "Player"
          color: Theme.secondaryTextColor
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: "Opponent"
          color: Theme.secondaryTextColor
          visible: dataModel.playerFilter.hasPlayerFilter
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.3
          text: "Total stocks taken"
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: qsTr("%1").arg(dataModel.formatNumber(stats.totalStocksLostOpponent))
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: qsTr("%1").arg(dataModel.formatNumber(stats.totalStocksLost))
          visible: dataModel.playerFilter.hasPlayerFilter
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.3
          text: "Stocks taken / game"
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: qsTr("%1").arg(stats.averageStocksLostOpponent.toFixed(2))
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: qsTr("%1").arg(stats.averageStocksLost.toFixed(2))
          visible: dataModel.playerFilter.hasPlayerFilter
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.3
          text: "Total damage dealt"
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: qsTr("%1").arg(dataModel.formatNumber(stats.totalDamageDealt))
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: qsTr("%1").arg(dataModel.formatNumber(stats.totalDamageDealtOpponent))
          visible: dataModel.playerFilter.hasPlayerFilter
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.3
          text: "Damage / minute"
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: qsTr("%1").arg(stats.damagePerMinute.toFixed(2))
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: qsTr("%1").arg(stats.damagePerMinuteOpponent.toFixed(2))
          visible: dataModel.playerFilter.hasPlayerFilter
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.3
          text: "Avg. Kill %"
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: qsTr("%1").arg(stats.damagePerStock.toFixed(2))
        }

        AppText {
          Layout.preferredWidth: statisticsPage.width * 0.25
          horizontalAlignment: Text.AlignRight
          text: qsTr("%1").arg(stats.damagePerStockOpponent.toFixed(2))
          visible: dataModel.playerFilter.hasPlayerFilter
        }
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
        model: stats.topPlayerTags
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
        model: stats.topPlayerTagsOpponent
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
        model: stats.topSlippiCodesOpponent
        columns: nameColumns
      }

      Item {
        width: 1
        height: dp(Theme.contentPadding) / 2
      }
    }
  }
}
