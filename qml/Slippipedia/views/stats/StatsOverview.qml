import QtQuick 2.0
import Felgo 4.0

import Slippipedia 1.0

Column {

  SimpleSection {
    title: "Stats Overview"
  }

  readonly property int numColumns: width > dp(600) ? 4 : 2

  component StatListItem: AppListItem {
    id: statListItem

    property int colSpan: 1
    property string toolTipText: ""

    width: parent.width / (numColumns / colSpan)
    backgroundColor: Theme.backgroundColor

    textMaximumLineCount: 1

    mouseArea.hoverEffectEnabled: false

    CustomToolTip {
      shown: mouseArea.containsMouse && !!text
      text: statListItem.toolTipText
    }
  }

  Flow {
    width: parent.width

    AppListItem {
      text: "Filter by player code, name or port to see win rate."

      width: parent.width / 2
      visible: !dataModel.playerFilter.hasPlayerFilter
      onSelected: showFilteringPage(0)
    }

    StatListItem {
      colSpan: 2
      visible: dataModel.playerFilter.hasPlayerFilter

      leftItem: GameCountRow {
        anchors.verticalCenter: parent.verticalCenter

        gamesWon: stats.totalReplaysFilteredWon
        gamesFinished: stats.totalReplaysFilteredWithResult
      }
    }

    StatListItem {
      text: qsTr("Total KOs: %1")
      .arg(dataModel.formatNumber(stats.statsPlayer.stocksTaken.value))
      toolTipText: qsTr("Number of stocks taken by you")
    }

    StatListItem {
      text: qsTr("OPK: %2")
      .arg(dataModel.formatNumber(stats.statsPlayer.openingsPerKill))
      toolTipText: qsTr("Openings per kill")
    }

    StatListItem {
      colSpan: 2
      text: qsTr("Total game time: %1 (%2 frames)")
      .arg(dataModel.formatTime(stats.totalGameDuration))
      .arg(dataModel.formatNumber(stats.totalGameDuration))
    }

    StatListItem {
      text: qsTr("L-Cancel: %2")
      .arg(dataModel.formatPercentage(stats.statsPlayer.lCancelRate))
      toolTipText: qsTr("Percentage of L-cancelled aerials")
    }

    StatListItem {
      text: qsTr("APM: %1")
      .arg(dataModel.formatNumber(stats.statsPlayer.actionsPerMinute.avg))
      toolTipText: qsTr("Actions per minute")
    }

    StatListItem {
      colSpan: 2
      text: qsTr("Games finished: %1 (%2), tied: %3 (%4)")
      .arg(dataModel.formatPercentage(stats.finishedRate))
      .arg(dataModel.formatNumber(stats.totalReplaysFilteredFinished))
      .arg(dataModel.formatPercentage(stats.tieRate))
      .arg(dataModel.formatNumber(stats.totalReplaysFilteredWithTie))
    }

    StatListItem {
      text: qsTr("LRAS - Me: %1")
      .arg(dataModel.formatNumber(stats.statsPlayer.lrasCount.value))
      toolTipText: qsTr("Number of games ended with LRAS quit out")
    }

    StatListItem {
      text: qsTr("Opponent: %1")
      .arg(dataModel.formatNumber(stats.statsOpponent.lrasCount.value))
      toolTipText: qsTr("Number of games ended with LRAS quit out")
    }
  }

  SimpleSection {
    title: "Top Opponents"
  }

  NameGrid {
    model: stats.statsOpponent.topSlippiCodes
    columns: nameColumns
    maxRows: 1

    namesClickable: true
    onNameClicked: name => showList({ code1: name, name1: ciEqual(name, stats.dataBase.filterSettings.playerFilter.slippiCode.filterText) ? "" : undefined,
                                      exact: true, sourceFilter: stats.dataBase.filterSettings })
  }

  SimpleSection {
    title: "Top Chars"
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
    title: "Top Chars (opponent)"
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
