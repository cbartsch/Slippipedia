import QtQuick 2.0
import Felgo 3.0

import "../model"

Column {
  id: stageGrid
  signal stageSelected(int stageId, bool isSelected)

  property int stageId
  property bool highlightFilteredStage: true

  Grid {
    id: stageGridLayout
    columns: width <= dp(320) ? 2 : width <= dp(640) ? 3 : 6
    width: parent.width

    Repeater {
      model: SortFilterProxyModel {
        filters: ExpressionFilter {
          expression: count > 0
        }

        sorters: [
          RoleSorter {
            roleName: "count"
            ascendingOrder: false
          }
        ]

        sourceModel: JsonListModel {
          source: dataModel.stageData
          keyField: "id"
          fields: ["id", "count", "name", "shortName"]
        }
      }

      Rectangle {
        id: stageItem
        readonly property bool isSelected: highlightFilteredStage && stageId === id

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
    readonly property bool isSelected: highlightFilteredStage && stageId === 0

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
