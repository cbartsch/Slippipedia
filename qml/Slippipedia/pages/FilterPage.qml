import QtQuick 2.0
import QtQuick.Controls 2.12

import Felgo 3.0

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
      stats: filterPage.stats
      showResetButton: true
    }

    AppTabBar {
      id: filterTabs
      contentContainer: filterSwipe

      AppTabButton {
        text: "Me"
        showIcon: stats ? stats.dataBase.playerFilter.hasFilter : false
        tabIcon: IconType.check
      }
      AppTabButton {
        text: "Opponent"
        showIcon: stats ? stats.dataBase.opponentFilter.hasFilter : false
        tabIcon: IconType.check
      }
      AppTabButton {
        text: "Results"
        showIcon: stats ? stats.dataBase.gameFilter.hasResultFilter : false
        tabIcon: IconType.check
      }
      AppTabButton {
        text: "Game"
        showIcon: stats ? stats.dataBase.gameFilter.hasGameFilter : false
        tabIcon: IconType.check
      }
      Repeater {
        model: showPunishOptions ? 1 : 0

        AppTabButton {
          text: "Punishes"
          showIcon: stats ? stats.dataBase.punishFilter.hasFilter : false
          tabIcon: IconType.check
        }
      }
    }
  }

  AppFlickable {
    anchors.fill: parent
    anchors.topMargin: header.height

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
