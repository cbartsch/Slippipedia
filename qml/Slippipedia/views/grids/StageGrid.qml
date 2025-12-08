import QtQuick 2.0
import Felgo 4.0

import Slippipedia 1.0

Column {
  id: stageGrid

  property ReplayStats stats: null

  signal stageSelected(int stageId, bool isSelected)

  property alias sourceModel: jsonModel.source

  property var stageIds: []
  property bool highlightFilteredStage: true
  property bool hideStagesWithNoReplays: false
  property bool sortByCount: true

  property bool showIcon: false
  property bool showData: true
  property bool showOtherItem: true
  property bool enableEmpty: true

  property string toolTipText: ""

  property Filter emptyFilter: ExpressionFilter {
    expression: count > 0
  }

  property Sorter countSorter: RoleSorter {
    roleName: "count"
    ascendingOrder: false
  }

  Grid {
    id: stageGridLayout

    columns: {
      if(showIcon) {
        return width <= dp(180) ? 1 : width <= dp(270) ? 2 : width <= dp(540) ? 3 : 6
      }
      else {
        return width <= dp(320) ? 2 : width <= dp(640) ? 3 : 6
      }
    }

    width: parent.width

    Repeater {
      model: SortFilterProxyModel {
        filters: hideStagesWithNoReplays ? [emptyFilter] : []

        sorters: sortByCount ? [countSorter] : []

        sourceModel: JsonListModel {
          id: jsonModel
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
                 ? Qt.darker(Theme.selectedBackgroundColor, 1.5)
                 : Theme.controlBackgroundColor

        RippleMouseArea {
          id: stageMouse
          anchors.fill: parent
          onClicked: stageSelected(id, stageItem.isSelected)

          cursorShape: Qt.PointingHandCursor
          enabled: enableEmpty || model.count > 0
          hoverEffectEnabled: true
          backgroundColor: Theme.listItem.selectedBackgroundColor
          fillColor: backgroundColor

          CustomToolTip {
            shown: !!toolTipText && stageMouse.containsMouse
            text: toolTipText ? qsTr(toolTipText).arg(model.count).arg(model.name) : ""
          }

          StageIcon {
            anchors.centerIn: parent
            scale: parent.height / height

            stageId: id
            visible: showIcon

            opacity: showData || (!isSelected && stageIds.length > 0) ? 0.5 : 1

            Behavior on opacity { UiAnimation { } }
          }

          Column {
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter

            AppText {
              enabled: false
              width: parent.width
              horizontalAlignment: Text.AlignHCenter
              font.pixelSize: showData ? sp(20) : dp(30)
              text: shortName
              style: Text.Outline
              styleColor: Theme.backgroundColor
            }

            AppText {
              visible: showData
              enabled: false
              width: parent.width
              horizontalAlignment: Text.AlignHCenter
              text: qsTr("%1 game%2\n(%3)")
                .arg(count)
                .arg(count === 1 ? "" : "s")
                .arg(dataModel.formatPercentage(count / stats.totalReplaysFiltered))
              style: Text.Outline
              styleColor: Theme.backgroundColor
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

    color: !otherStageMouse.enabled
           ? Theme.backgroundColor
           : isSelected
             ? Theme.selectedBackgroundColor
             : Theme.controlBackgroundColor

    RippleMouseArea {
      id: otherStageMouse
      anchors.fill: parent

      // filtering for "other stages" is not currently supported
      enabled: false// enableEmpty || stats.otherStageAmount > 0

      cursorShape: Qt.PointingHandCursor
      hoverEffectEnabled: true

      backgroundColor: Theme.listItem.selectedBackgroundColor
      fillColor: backgroundColor


      onClicked: stageSelected(0, otherItem.isSelected)

      CustomToolTip {
        shown: !!toolTipText && otherStageMouse.containsMouse
        text: toolTipText ? qsTr(toolTipText).arg(stats.otherStageAmount).arg("other stages") : ""
      }
    }

    AppText {
      anchors.fill: parent
      verticalAlignment: Text.AlignVCenter
      horizontalAlignment: Text.AlignHCenter
      text: qsTr("Other stages (%1 games, %2)")
      .arg(stats ? stats.otherStageAmount : 0)
      .arg(dataModel.formatPercentage(stats && stats.totalReplays > 0
      ? stats.otherStageAmount / stats.totalReplays
      : 0))
      style: Text.Outline
      styleColor: Theme.backgroundColor
    }

    Divider { }
  }
}
