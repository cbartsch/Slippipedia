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

      onShowList: app.showList(id, -1, -1, "")
      onShowStats: app.showStats(id, -1, -1, "")
    }

    AnalyticsListView {
      showsCharacters: true
      model: stats.statsOpponent.charDataAnalytics

      infoText: "Stats based on matchups"
      infoDetailText: "Calculated from all games where your opponents used the specific character."

      onShowList: app.showList(-1, id, -1, "")
      onShowStats: app.showStats(-1, id, -1, "")
    }

    AnalyticsListView {
      showsStages: true
      model: stats.stageDataAnalytics

      infoText: "Stats based on stages"
      infoDetailText: "Calculated from all games played on the specific stage."

      onShowList: app.showList(-1, -1, id, "")
      onShowStats: app.showStats(-1, -1, id, "")
    }

    AnalyticsListView {
      model: stats.timeDataAnalytics
      sortByWinRate: false

      infoText: "Stats over time"
      infoDetailText: "Calculated from all games played in the specified time."

      onShowList: app.showList(-1, -1, -1, id)
      onShowStats: app.showStats(-1, -1, -1, id)
    }
  }
}
