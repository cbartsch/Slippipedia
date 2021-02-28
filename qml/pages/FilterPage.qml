import QtQuick 2.0
import QtQuick.Controls 2.12

import Felgo 3.0

import "../model/stats"
import "../views/controls"
import "../views/grids"
import "../views/icons"
import "../views/visual"

Page {
  id: filterPage
  title: qsTr("Filtering")

  property ReplayStats stats: null

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
        showIcon: dataModel.playerFilter.hasFilter
        tabIcon: IconType.check
      }
      AppTabButton {
        text: "Opponent"
        showIcon: dataModel.opponentFilter.hasFilter
        tabIcon: IconType.check
      }
      AppTabButton {
        text: "Game"
        showIcon: dataModel.gameFilter.hasFilter
        tabIcon: IconType.check
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
          filter: dataModel.playerFilter
        }

        PlayerFilterOptions {
          id: filterOptionsOpponent
          me: false
          filter: dataModel.opponentFilter
        }

        GameFilterOptions {
          filter: dataModel.gameFilter
          stats: dataModel.stats
        }
      }
    }
  }
}
