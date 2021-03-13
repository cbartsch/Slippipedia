import QtQuick 2.0
import Felgo 3.0

import Slippipedia 1.0

Column {
  id: filterItem
  width: parent.width

  property ReplayStats stats: null

  property bool showListButton: false
  property bool showStatsButton: false
  property bool showResetButton: false

  signal showList
  signal showStats

  property bool clickable: false

  property int numReplays: stats ? stats.totalReplays : 0
  property int numReplaysFiltered: stats ? stats.totalReplaysFiltered : 0
  property real amountFiltered: stats ? stats.totalReplaysFiltered / stats.totalReplays : 0

  Behavior on numReplaysFiltered { UiAnimation { } }
  Behavior on amountFiltered { UiAnimation { } }

  SimpleSection {
    title: "Filtering"
  }

  AppListItem {
    text: qsTr("Matched replays: %1/%2 (%3)")
    .arg(numReplaysFiltered).arg(numReplays)
    .arg(dataModel.formatPercentage(amountFiltered))

    detailText: qsTr("Matching:\n%1").arg(stats ? stats.dataBase.filterSettings.displayText : "")

    onSelected: showFilteringPage()

    mouseArea.enabled: filterItem.clickable
    backgroundColor: filterItem.clickable ? Theme.controlBackgroundColor : Theme.backgroundColor

    rightItem: Row {
      anchors.verticalCenter: parent.verticalCenter
      spacing: dp(Theme.contentPadding)

      AppToolButton {
        visible: showListButton
        iconType: IconType.list
        toolTipText: "Show list of games"

        onClicked: showList()
      }

      AppToolButton {
        visible: showStatsButton
        iconType: IconType.barchart
        toolTipText: "Show statistics for games"

        onClicked: showStats()
      }

      AppToolButton {
        iconType: IconType.trash
        toolTipText: "Reset all filters"
        visible: showResetButton

        onClicked: InputDialog.confirm(app, "Reset all filters?", accepted => {
                                         if(accepted) stats.dataBase.filterSettings.reset()
                                       })
      }
    }
  }
}
