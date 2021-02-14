import QtQuick 2.0
import Felgo 3.0

import "../model"

Column {
  id: stageGrid
  signal stageSelected(int stageId, bool isSelected)

  property var stageIds: []
  property bool highlightFilteredStage: true
  property bool hideStagesWithNoReplays: false
  property bool sortByCount: true

  property bool showIcon: false
  property bool showData: true
  property bool showOtherItem: true

  property Filter emptyFilter: ExpressionFilter {
    expression: count > 0
  }

  property Sorter countSorter: RoleSorter {
    roleName: "count"
    ascendingOrder: false
  }

  Grid {
    id: stageGridLayout
    columns: width <= dp(320) ? 2 : width <= dp(640) ? 3 : 6
    width: parent.width

    Repeater {
      model: SortFilterProxyModel {
        filters: hideStagesWithNoReplays ? [emptyFilter] : []

        sorters: sortByCount ? [countSorter] : []

        sourceModel: JsonListModel {
          source: dataModel.stageDataSss
          keyField: "id"
          fields: ["id", "count", "name", "shortName"]
        }
      }

      Rectangle {
        id: stageItem
        readonly property bool isSelected: highlightFilteredStage && stageIds.indexOf(id) >= 0 // TODO probably use faster lookup

        width: parent.width / stageGridLayout.columns
        height: dp(72)
        color: !enabled
               ? Theme.backgroundColor
               : isSelected
                 ? Theme.selectedBackgroundColor
                 : Theme.controlBackgroundColor

        RippleMouseArea {
          anchors.fill: parent
          onClicked: stageSelected(id, stageItem.isSelected)

          Column {
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter

            AppText {
              enabled: false
              width: parent.width
              horizontalAlignment: Text.AlignHCenter
              font.pixelSize: sp(20)
              text: shortName
            }

            AppText {
              visible: showData
              enabled: false
              width: parent.width
              horizontalAlignment: Text.AlignHCenter
              text: qsTr("%2 games\n(%3)")
              .arg(count)
              .arg(dataModel.formatPercentage(count / dataModel.totalReplaysFiltered))
            }
          }
        }

        Divider { }
      }
    }
  }

  Rectangle {
    id: otherItem
    readonly property bool isSelected: highlightFilteredStage && stageIds.indexOf(0) >= 0 // TODO probably use faster lookup

    visible: showOtherItem
    width: parent.width
    height: dp(48)
    color: !enabled
           ? Theme.backgroundColor
           : isSelected
             ? Theme.selectedBackgroundColor
             : Theme.controlBackgroundColor

    RippleMouseArea {
      anchors.fill: parent

      onClicked: stageSelected(0, otherItem.isSelected)

      AppText {
        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("Other (%2)")
        .arg(dataModel.formatPercentage(dataModel.totalReplays > 0
        ? dataModel.otherStageAmount / dataModel.totalReplays
        : 0))
      }
    }

    Divider { }
  }
}
