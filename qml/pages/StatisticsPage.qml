import Felgo 3.0

import QtQuick 2.0

import "../controls"

BasePage {
  title: qsTr("Replay statistics")

  flickable.contentHeight: content.height

  Column {
    id: content
    width: parent.width

    SimpleSection {
      title: "Replay statistics"
    }

    AppListItem {
      text: qsTr("Filtered replays: %1/%2 (%3)")
        .arg(dataModel.totalReplaysFiltered)
        .arg(dataModel.totalReplays)
        .arg(dataModel.formatPercentage(dataModel.totalReplaysFiltered / dataModel.totalReplays))

      detailText: qsTr("Matching: %1").arg(dataModel.filterDisplayText)

      backgroundColor: Theme.backgroundColor
      enabled: false
    }

//    AppListItem {
//      text: qsTr("%1 total replays stored.").arg(dataModel.totalReplays)

//      backgroundColor: Theme.backgroundColor
//      enabled: false
//    }

    AppListItem {
      text: qsTr("Average game time: %1 (%3 frames)")
        .arg(dataModel.formatTime(dataModel.averageGameDuration))
        .arg(dataModel.averageGameDuration.toFixed(0))

      backgroundColor: Theme.backgroundColor
      enabled: false
    }

    SimpleSection {
      title: "Player stats"
    }

    AppListItem {
      text: qsTr("Win rate: %1 (%2/%3)")
      .arg(dataModel.formatPercentage(dataModel.winRate))
      .arg(dataModel.totalReplaysFilteredWon).arg(dataModel.totalReplaysFilteredWithResult)

      backgroundColor: Theme.backgroundColor
      enabled: false
    }

    AppListItem {
      text: qsTr("Games not finished: %1 (%2/%3)")
      .arg(dataModel.formatPercentage(dataModel.tieRate))
      .arg(dataModel.totalReplaysFilteredWithTie).arg(dataModel.totalReplaysFiltered)

      backgroundColor: Theme.backgroundColor
      enabled: false
    }

    SimpleSection {
      title: "Top chars used"
    }

    CharacterGrid {
      charIds: dataModel.filterCharIds
      enabled: false
      highlightFilteredChar: false
      showData: true
      showIcon: false
      sortByCssPosition: false
      hideCharsWithNoReplays: true
    }

    SimpleSection {
      title: "Top player tags"
    }

    Grid {
      id: nameGrid
      columns: Math.round(width / dp(200))
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: dp(Theme.contentPadding)
      spacing: dp(Theme.contentPadding) / 2
      rowSpacing: dp(1)

      Repeater {
        model: dataModel.getTopPlayerTags(nameGrid.columns * 5)

        Item {
          width: parent.width / parent.columns
          height: dp(48)

          Column {
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter

            AppText {
              width: parent.width
              text: modelData.tag
              maximumLineCount: 1
              elide: Text.ElideRight
              font.pixelSize: sp(20)
            }
            AppText {
              width: parent.width
              text: qsTr("%1 (%2)").arg(modelData.count).arg(dataModel.formatPercentage(modelData.count / dataModel.totalReplaysFiltered))
              maximumLineCount: 1
              elide: Text.ElideRight
            }
          }
        }
      }
    }

    SimpleSection {
      title: "Top stages"
    }

    StageGrid {
      width: parent.width

      stageId: dataModel.filterStageId
      enabled: false
      highlightFilteredStage: false
    }
  }
}
