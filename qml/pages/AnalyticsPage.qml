import QtQuick 2.0
import QtQuick.Controls 2.0
import Felgo 3.0

import "../model/db"
import "../model/filter"
import "../model/stats"
import "../views/controls"
import "../views/visual"

BasePage {
  id: analyticsPage
  title: qsTr("Analytics")

  flickable.interactive: false

  filterModal.onClosed: if(stats) stats.refresh()

  rightBarItem: NavigationBarRow {
    LoadingIcon {
    }

    IconButtonBarItem {
      icon: IconType.filter
      onClicked: showFilteringPage()
    }
  }

  Column {
    id: header
    width: parent.width

    FilterInfoItem {
      stats: analyticsPage.stats
      clickable: true
    }

    AppTabBar {
      id: filterTabs
      contentContainer: contentSwipe

      AppTabButton {
        text: "Characters"
      }
      AppTabButton {
        text: "Matchups"
      }
      AppTabButton {
        text: "Stages"
      }
      AppTabButton {
        text: "Time"
      }
    }
  }

  SwipeView {
    id: contentSwipe
    anchors.fill: parent
    anchors.topMargin: header.height

    width: parent.width
    height: currentItem ? currentItem.implicitHeight : dp(500)

    AnalyticsListView {
      showsCharacters: true
      model: stats.statsPlayer.charDataAnalytics

      infoText: "Stats based on your characters"
      infoDetailText: "Calculated from all games where you used the specific character."

      onShowList: analyticsPage.showList(id, -1, -1)
      onShowStats: analyticsPage.showStats(id, -1, -1)
    }

    AnalyticsListView {
      showsCharacters: true
      model: stats.statsOpponent.charDataAnalytics

      infoText: "Stats based on matchups"
      infoDetailText: "Calculated from all games where your opponents used the specific character."

      onShowList: analyticsPage.showList(-1, id, -1)
      onShowStats: analyticsPage.showStats(-1, id, -1)
    }

    AnalyticsListView {
      showsStages: true
      model: stats.stageDataAnalytics

      infoText: "Stats based on stages"
      infoDetailText: "Calculated from all games played on the specific stage."

      onShowList: analyticsPage.showList(-1, -1, id)
      onShowStats: analyticsPage.showStats(-1, -1, id)
    }

    AnalyticsListView {
      model: stats.timeDataAnalytics
      sortByWinRate: false

      infoText: "Stats over time"
      infoDetailText: "Calculated from all games played in the specified time."

      onShowList: analyticsPage.showList(-1, -1, id)
      onShowStats: analyticsPage.showStats(-1, -1, id)
    }
  }


  FilterSettings {
    id: analyticsFilter

    playerFilter: PlayerFilterSettings {
      settingsCategory: "analytics-player-filter"
    }

    opponentFilter: PlayerFilterSettings {
      settingsCategory: "analytics-opponent-filter"
    }

    gameFilter: GameFilterSettings {
      settingsCategory: "analytics-game-filter"
    }
  }

  ReplayStats {
    id: analyticsStats

    dataBase: DataBase {
      filterSettings: analyticsFilter
    }
  }

  Component {
    id: replayListPageC

    ReplayListPage {
      filterChangeable: false
      stats: analyticsStats
    }
  }

  Component {
    id: statisticsPageC

    StatisticsPage {
      filterChangeable: false
      stats: analyticsStats
    }
  }

  function setFilter(charId, opponentCharId, stageId) {
    // set desired filters:
    analyticsFilter.playerFilter.setCharFilter(charId >= 0
        ? [charId]
        : dataModel.playerFilter.charIds)

    analyticsFilter.opponentFilter.setCharFilter(opponentCharId >= 0
        ? [opponentCharId]
        : dataModel.opponentFilter.charIds)

    analyticsFilter.gameFilter.setStage(stageId >= 0
        ? [stageId]
        : dataModel.gameFilter.stageIds)

    // copy all filters from global filter - TODO find better way to do this:
    analyticsFilter.playerFilter.slippiCode.filterText = dataModel.playerFilter.slippiCode.filterText
    analyticsFilter.playerFilter.slippiName.filterText = dataModel.playerFilter.slippiName.filterText
    analyticsFilter.playerFilter.filterCodeAndName = dataModel.playerFilter.filterCodeAndName

    analyticsFilter.opponentFilter.slippiCode.filterText = dataModel.opponentFilter.slippiCode.filterText
    analyticsFilter.opponentFilter.slippiName.filterText = dataModel.opponentFilter.slippiName.filterText
    analyticsFilter.opponentFilter.filterCodeAndName = dataModel.opponentFilter.filterCodeAndName

    analyticsFilter.gameFilter.winnerPlayerIndex = dataModel.gameFilter.winnerPlayerIndex
    analyticsFilter.gameFilter.startDateMs = dataModel.gameFilter.startDateMs
    analyticsFilter.gameFilter.endDateMs = dataModel.gameFilter.endDateMs
    analyticsFilter.gameFilter.minFrames = dataModel.gameFilter.minFrames
    analyticsFilter.gameFilter.maxFrames = dataModel.gameFilter.maxFrames
    analyticsFilter.gameFilter.endStocks = dataModel.gameFilter.endStocks
  }

  function showList(charId, opponentCharId, stageId) {
    setFilter(charId, opponentCharId, stageId)

    navigationStack.push(replayListPageC)
  }

  function showStats(charId, opponentCharId, stageId) {
    setFilter(charId, opponentCharId, stageId)

    navigationStack.push(statisticsPageC)
  }
}
