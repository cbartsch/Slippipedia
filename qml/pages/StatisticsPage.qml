import Felgo 3.0

import QtQuick 2.13
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.12

import "../views/controls"
import "../views/grids"
import "../views/stats"
import "../views/visual"
import "../model"

BasePage {
  id: statisticsPage
  title: qsTr("Replay statistics")

  property bool filterChangeable: true
  readonly property int nameColumns: Math.round(width / dp(200))

  onSelected: stats.refresh(nameColumns * 5)
  onPushed: stats.refresh(nameColumns * 5)
  filterModal.onClosed: if(stats) stats.refresh(nameColumns * 5)

  flickable.interactive: false

  rightBarItem: NavigationBarRow {
    LoadingIcon {
    }

    IconButtonBarItem {
      icon: IconType.filter
      onClicked: showFilteringPage()
      visible: filterChangeable
    }
  }

  Column {
    id: header
    width: parent.width

    FilterInfoItem {
      stats: statisticsPage.stats
      clickable: filterChangeable
    }

    AppTabBar {
      id: filterTabs
      contentContainer: contentSwipe

      AppTabButton {
        text: "Overview"
      }
      AppTabButton {
        text: "Stats"
      }
      AppTabButton {
        text: "Players"
      }
    }
  }

  AppFlickable {
    anchors.fill: parent
    anchors.topMargin: header.height

    contentHeight: content.height

    Column {
      id: content
      width: parent.width

      SwipeView {
        id: contentSwipe
        width: parent.width
        height: currentItem ? currentItem.implicitHeight : dp(500)

        StatsOverview { }

        StatsGrids { }

        StatsTags { }
      }
    }
  }
}
