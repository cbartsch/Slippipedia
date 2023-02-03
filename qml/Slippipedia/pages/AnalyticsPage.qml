import QtQuick 2.0
import QtQuick.Controls 2.0
import Felgo 4.0

import Slippipedia 1.0

BasePage {
  id: analyticsPage
  title: qsTr("Analytics")

  flickable.interactive: false

  onAppeared: stats.refresh()
  filterModal.onClosed: if(stats) stats.refresh()

  rightBarItem: NavigationBarRow {
    LoadingIcon {
    }

    IconButtonBarItem {
      iconType: IconType.filter
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

      CustomTabButton {
        text: "Characters"
      }
      CustomTabButton {
        text: "Matchups"
      }
      CustomTabButton {
        text: "Stages"
      }
      CustomTabButton {
        text: "Time"
      }
    }
  }

  SwipeView {
    id: contentSwipe
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: header.bottom
    anchors.bottom: parent.bottom

    AnalyticsListView {
      showsCharacters: true
      model: stats.statsPlayer.charDataAnalytics

      infoText: "Stats based on your characters"
      infoDetailText: "Calculated from all games where you used the specific character."

      onShowList: app.showList(filterData(id, -1, -1, ""))
      onShowStats: app.showStats(filterData(id, -1, -1, ""))
    }

    AnalyticsListView {
      showsCharacters: true
      model: stats.statsOpponent.charDataAnalytics

      infoText: "Stats based on matchups"
      infoDetailText: "Calculated from all games where your opponents used the specific character."

      onShowList: app.showList(filterData(-1, id, -1, ""))
      onShowStats: app.showStats(filterData(-1, id, -1, ""))
    }

    AnalyticsListView {
      showsStages: true
      model: stats.stageDataAnalytics

      infoText: "Stats based on stages"
      infoDetailText: "Calculated from all games played on the specific stage."

      onShowList: app.showList(filterData(-1, -1, id, ""))
      onShowStats: app.showStats(filterData(-1, -1, id, ""))
    }

    AnalyticsListView {
      model: stats.timeDataAnalytics
      sortByWinRate: false

      infoText: "Stats over time"
      infoDetailText: "Calculated from all games played in the specified time."

      onShowList: app.showList(filterData(-1, -1, -1, id))
      onShowStats: app.showStats(filterData(-1, -1, -1, id))
    }
  }

  Rectangle {
    anchors.fill: parent
    anchors.topMargin: header.height

    color: "#80000000"

    visible: stats.isLoading

    AppText {
      anchors.centerIn: parent
      text: "Loading..."
      font.pixelSize: sp(32)
    }
  }

  function filterData(charId, opponentCharId, stageId, yearMonth) {
    return {
      charId: charId,
      opponentCharId: opponentCharId,
      stageId: stageId,
      yearMonth: yearMonth
    }
  }
}
