import QtQuick 2.0
import QtQuick.Controls 2.0
import Felgo 3.0

import Slippipedia 1.0

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

      onShowList: analyticsPage.showList(id, -1, -1, "")
      onShowStats: analyticsPage.showStats(id, -1, -1, "")
    }

    AnalyticsListView {
      showsCharacters: true
      model: stats.statsOpponent.charDataAnalytics

      infoText: "Stats based on matchups"
      infoDetailText: "Calculated from all games where your opponents used the specific character."

      onShowList: analyticsPage.showList(-1, id, -1, "")
      onShowStats: analyticsPage.showStats(-1, id, -1, "")
    }

    AnalyticsListView {
      showsStages: true
      model: stats.stageDataAnalytics

      infoText: "Stats based on stages"
      infoDetailText: "Calculated from all games played on the specific stage."

      onShowList: analyticsPage.showList(-1, -1, id, "")
      onShowStats: analyticsPage.showStats(-1, -1, id, "")
    }

    AnalyticsListView {
      model: stats.timeDataAnalytics
      sortByWinRate: false

      infoText: "Stats over time"
      infoDetailText: "Calculated from all games played in the specified time."

      onShowList: analyticsPage.showList(-1, -1, -1, id)
      onShowStats: analyticsPage.showStats(-1, -1, -1, id)
    }
  }

  Component {
    id: replayListPageC

    ReplayListPage {
      property var filterData: ({})
      property alias analyticsFilter: analyticsFilter

      filterChangeable: false
      stats: analyticsStats

      Component.onCompleted: setFilter(this, filterData)

      FilterSettings {
        id: analyticsFilter

        persistenceEnabled: false
      }

      ReplayStats {
        id: analyticsStats

        dataBase: DataBase {
          filterSettings: analyticsFilter
        }
      }
    }
  }

  Component {
    id: statisticsPageC

    StatisticsPage {
      property var filterData: ({})
      property alias analyticsFilter: analyticsFilter

      filterChangeable: false
      stats: analyticsStats

      Component.onCompleted: setFilter(this, filterData)

      FilterSettings {
        id: analyticsFilter

        persistenceEnabled: false
      }

      ReplayStats {
        id: analyticsStats

        dataBase: DataBase {
          filterSettings: analyticsFilter
        }
      }
    }
  }

  function setFilter(page, data) {
    // copy all filters from global filter
    page.analyticsFilter.copyFrom(analyticsPage.stats.dataBase.filterSettings)

    // set desired filters:
    page.analyticsFilter.playerFilter.setCharFilter(data.charId >= 0
        ? [data.charId]
        : dataModel.playerFilter.charIds)

    page.analyticsFilter.opponentFilter.setCharFilter(data.opponentCharId >= 0
        ? [data.opponentCharId]
        : dataModel.opponentFilter.charIds)

    page.analyticsFilter.gameFilter.setStage(data.stageId >= 0
        ? [data.stageId]
        : dataModel.gameFilter.stageIds)

    if(data.time) {
      var date = Date.fromLocaleDateString(Qt.locale(), data.time, "yyyy-MM")
      page.analyticsFilter.gameFilter.startDateMs = date.getTime()

      date.setMonth(date.getMonth() + 1)
      page.analyticsFilter.gameFilter.endDateMs = date.getTime()
    }
    else {
      page.analyticsFilter.gameFilter.startDateMs = dataModel.gameFilter.startDateMs
      page.analyticsFilter.gameFilter.endDateMs = dataModel.gameFilter.endDateMs
    }
  }

  function showList(charId, opponentCharId, stageId, time) {
    navigationStack.push(replayListPageC, { filterData: {
                             charId: charId,
                             opponentCharId: opponentCharId,
                             stageId: stageId,
                             time: time
                           } })
  }

  function showStats(charId, opponentCharId, stageId, time) {
    navigationStack.push(statisticsPageC, { filterData: {
                             charId: charId,
                             opponentCharId: opponentCharId,
                             stageId: stageId,
                             time: time
                           } })
  }
}
