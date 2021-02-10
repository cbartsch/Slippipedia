import Felgo 3.0

import QtQuick 2.0

import "../controls"

BasePage {
  title: qsTr("Replay statistics")

  flickable.contentHeight: content.height

  readonly property real averageGameDuration: dataModel.averageGameDuration
  readonly property int averageGameDurationMinutes: averageGameDuration / 60 / 60
  readonly property int averageGameDurationSeconds: averageGameDuration / 60 % 60

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
      text: qsTr("Average game time: %1:%2 (%3 frames)")
        .arg(averageGameDurationMinutes)
        .arg(averageGameDurationSeconds)
        .arg(averageGameDuration.toFixed(0))

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

    Grid {
      columns: Math.round(width / dp(200))
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: dp(Theme.contentPadding)
      spacing: dp(Theme.contentPadding) / 2

      Repeater {
        model: SortFilterProxyModel {

          filters: [
            ExpressionFilter {
              expression: count > 0
            }
          ]

          sorters: [
            RoleSorter {
              roleName: "count"
              ascendingOrder: false
            }
          ]

          sourceModel: JsonListModel {
            source: dataModel.charData
            keyField: "id"
          }
        }

        Item {
          visible: id < 26 // ids 0-25 are the useabls characters
          width: parent.width / parent.columns
          height: dp(48)

          Column {
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter

            AppText {
              width: parent.width
              text: name
              maximumLineCount: 1
              elide: Text.ElideRight
              font.pixelSize: sp(20)
            }
            AppText {
              width: parent.width
              text: qsTr("%1 (%2)").arg(count).arg(dataModel.formatPercentage(count / dataModel.totalReplaysFiltered))
              maximumLineCount: 1
              elide: Text.ElideRight
            }
          }
        }
      }
    }

    SimpleSection {
      title: "Top player tags"
    }

    Grid {
      id: charGrid
      columns: Math.round(width / dp(200))
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: dp(Theme.contentPadding)
      spacing: dp(Theme.contentPadding) / 2
      rowSpacing: dp(1)

      Repeater {
        model: dataModel.getTopPlayerTags(charGrid.columns * 5)

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

      enabled: false
      highlightFilteredStage: false
    }
  }
}
