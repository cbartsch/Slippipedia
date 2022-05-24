import Felgo 4.0

import QtQuick 2.0
import QtQuick.Controls 2.0

import Slippipedia 1.0

BasePage {
  id: browserPage
  title: qsTr("Replay browser")

  property bool filterChangeable: true

  flickable.interactive: false

  // load first page when showing this page
  onAppeared: loadInitial()

  filterModal.onClosed: if(stats) loadInitial()
  filterModal.showPunishOptions: listTabs.currentIndex === 1

  Connections {
    target: stats ? stats.dataBase.filterSettings : null
    onFilterChanged: clear()
  }

  rightBarItem: NavigationBarRow {
    LoadingIcon {
    }
    IconButtonBarItem {
      icon: IconType.filter
      onClicked: showFilteringPage()
      visible: filterChangeable
    }
    IconButtonBarItem {
      icon: IconType.refresh
      onClicked: refresh()
    }
  }

  Column {
    id: header
    width: parent.width

    FilterInfoItem {
      stats: browserPage.stats
      clickable: filterChangeable
      showPunishFilter: filterModal.showPunishOptions

      showStatsButton: browserPage.navigationStack.depth > 1
      onShowStats: app.showStats({ sourceFilter: browserPage.stats.dataBase.filterSettings })
    }

    AppTabBar {
      id: listTabs
      contentContainer: contentSwipe

      AppTabButton {
        text: "Games"
      }
      AppTabButton {
        text: "Punishes"
      }
    }
  }

  SwipeView {
    id: contentSwipe
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: header.bottom
    anchors.bottom: parent.bottom

    onCurrentItemChanged: loadInitial()

    ReplayListView {
      id: replayListView
    }

    PunishListView {
      id: punishListView
    }
  }

  function loadInitial() {
    var item = contentSwipe.currentItem
    if(item && item.count === 0) {
      item.loadMore()
    }
  }

  function clear() {
    replayListView.clear()
    punishListView.clear()
  }

  function refresh() {
    clear()
    loadInitial()
  }
}
