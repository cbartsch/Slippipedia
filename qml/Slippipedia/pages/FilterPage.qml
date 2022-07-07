import QtQuick 2.0
import QtQuick.Controls 2.12

import Felgo 4.0

import Slippipedia 1.0

Page {
  id: filterPage
  title: qsTr("Filtering")

  property ReplayStats stats: null

  property bool showPunishOptions: false

  Column {
    id: header
    width: parent.width

    FilterInfoItem {
      titleSection.visible: false
      stats: filterPage.stats
      showResetButton: true
      showPunishFilter: filterPage.showPunishOptions && filterTabs.currentIndex === 4
    }

    AppTabBar {
      id: filterTabs
      contentContainer: filterSwipe

      CustomTabButton {
        text: "Me"
        showIcon: stats ? stats.dataBase.playerFilter.hasFilter : false
        tabIcon: IconType.check
      }
      CustomTabButton {
        text: "Opponent"
        showIcon: stats ? stats.dataBase.opponentFilter.hasFilter : false
        tabIcon: IconType.check
      }
      CustomTabButton {
        text: "Results"
        showIcon: stats ? stats.dataBase.gameFilter.hasResultFilter : false
        tabIcon: IconType.check
      }
      CustomTabButton {
        text: "Game"
        showIcon: stats ? stats.dataBase.gameFilter.hasGameFilter : false
        tabIcon: IconType.check
      }
      Repeater {
        model: showPunishOptions ? 1 : 0

        CustomTabButton {
          text: "Punishes"
          showIcon: stats ? stats.dataBase.punishFilter.hasFilter : false
          tabIcon: IconType.check
        }
      }
    }
  }

  AppFlickable {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: header.bottom
    anchors.bottom: parent.bottom

    // somehow the list doesn't scroll all the way to the bottom so add extra spacing
    contentHeight: content.height + dp(18)

    Column {
      id: content
      width: parent.width

      SwipeView {
        id: filterSwipe
        width: parent.width
        height: currentItem ? currentItem.implicitHeight : dp(500)

        PlayerFilterOptions {
          id: filterOptionsMe
          me: true
          stats: filterPage.stats
        }
        PlayerFilterOptions {
          id: filterOptionsOpponent
          me: false
          stats: filterPage.stats
        }
        ResultFilterOptions {
          stats: filterPage.stats
        }
        GameFilterOptions {
          stats: filterPage.stats
        }
        PunishFilterOptions {
          stats: filterPage.stats
          visible: showPunishOptions
        }
      }
    }
  }

  function showTab(index) {
    filterTabs.currentIndex = index
  }
}
