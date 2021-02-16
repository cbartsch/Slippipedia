import QtQuick 2.0
import QtQuick.Controls 2.12

import Felgo 3.0

import "../controls"
import "../model"

Page {
  id: filterPage
  title: qsTr("Filtering")

  property ReplayStats stats: null

  FilterInfoItem {
    id: header
    stats: filterPage.stats
    showResetButton: true
  }

  AppFlickable {
    anchors.fill: parent
    anchors.topMargin: header.height

    // somehow the list doesn't scroll all the way to the bottom so add extra spacing
    contentHeight: content.height + dp(18)

    Column {
      id: content
      width: parent.width

      SimpleSection {
        title: "Stage matching"
      }

      AppListItem {
        text: "Filter by specific stage"
        detailText: "Select a stage to limit all stats to that stage. Click again to unselect."

        backgroundColor: Theme.backgroundColor
        enabled: false
      }

      StageGrid {
        width: parent.width

        sourceModel: stats ? stats.stageDataSss : []
        stats: filterPage.stats

        hideStagesWithNoReplays: false
        sortByCount: false
        showIcon: true
        showData: false
        showOtherItem: false

        stageIds: dataModel.stageFilter.stageIds
        onStageSelected:{
          if(isSelected) {
            // char is selected -> unselect
            dataModel.stageFilter.removeStage(stageId)
          }
          else {
            dataModel.stageFilter.addStage(stageId)
          }
        }
      }

      //    SimpleSection {
      //      title: "Date matching"
      //    }

      //    AppListItem {
      //      text: "Filter by replay date"
      //      detailText: "Select a date range to match replays in."

      //      backgroundColor: Theme.backgroundColor
      //      enabled: false
      //    }

      //    AppListItem {
      //      text: "Start date: "

      //      onSelected: nativeUtils.displayDatePicker()
      //    }

      SimpleSection {
        title: "Player matching"
      }

      Item {
        width: 1
        height: dp(Theme.contentPadding)
      }

      AppTabBar {
        id: filterTabs
        contentContainer: filterSwipe

        AppTabButton {
          text: "Me"
        }
        AppTabButton {
          text: "Opponent"
        }
      }

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
      }
    }
  }
}
