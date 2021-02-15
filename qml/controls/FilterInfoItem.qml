import QtQuick 2.0
import Felgo 3.0

import "../model"

Column {
  id: filterItem
  width: parent.width

  property ReplayStats stats: null

  property bool showResetButton: false
  property bool clickable: false

  SimpleSection {
    title: "Filtering"
  }

  AppListItem {
    text: qsTr("Matched replays: %1/%2 (%3)")
    .arg(stats.totalReplaysFiltered)
    .arg(stats.totalReplays)
    .arg(dataModel.formatPercentage(stats.totalReplaysFiltered / stats.totalReplays))

    detailText: qsTr("Matching: %1").arg(dataModel.filter.displayText)

    onSelected: showFilteringPage()

    mouseArea.enabled: filterItem.clickable
    backgroundColor: filterItem.clickable ? Theme.controlBackgroundColor : Theme.backgroundColor

    rightItem: AppToolButton {
      iconType: IconType.trash
      onClicked: dataModel.resetFilters()
      toolTipText: "Reset all filters"
      visible: showResetButton
      anchors.verticalCenter: parent.verticalCenter
    }
  }
}
