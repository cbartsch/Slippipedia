import Felgo 3.0

import QtQuick 2.13
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.12

import Slippipedia 1.0

BasePage {
  id: statisticsPage
  title: qsTr("Replay statistics")

  property bool filterChangeable: true
  readonly property int nameColumns: Math.round(content.width / dp(200))

  readonly property bool openingsVisible: contentSwipe.currentIndex === 3

  onOpeningsVisibleChanged: if(openingsVisible) stats.refresh(nameColumns * 5, openingsVisible)

  onAppeared: stats.refresh(nameColumns * 5, openingsVisible)
  filterModal.onClosed: if(stats) stats.refresh(nameColumns * 5, openingsVisible)
  filterModal.showPunishOptions: openingsVisible

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

      showListButton: statisticsPage.navigationStack.depth > 1
      onShowList: app.showList({ sourceFilter: statisticsPage.stats.dataBase.filterSettings })
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
      AppTabButton {
        text: "Neutral"
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

        StatsList { }

        StatsTags { }

        StatsNeutral { }
      }
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
      style: Text.Outline
      styleColor: "black"
    }
  }
}
