import QtQuick 2.0
import QtQuick.Controls 2.0
import Felgo 4.0

import Slippipedia 1.0

Column {
  id: filterItem
  width: parent.width

  property ReplayStats stats: null

  property bool showListButton: false
  property bool showStatsButton: false
  property bool showResetButton: false
  property bool showQuickFilters: false

  signal showList
  signal showStats

  property bool clickable: false
  property alias showPunishFilter: description.showPunishFilter

  property int numReplays: stats ? stats.totalReplays : 0
  property int numReplaysFiltered: stats ? stats.totalReplaysFiltered : 0
  property real amountFiltered: stats ? stats.totalReplaysFiltered / stats.totalReplays : 0

  Behavior on numReplaysFiltered { UiAnimation { } }
  Behavior on amountFiltered { UiAnimation { } }

  property alias titleSection: titleSection

  signal quickFilterChanged

  SimpleSection {
    id: titleSection
    title: "Filtering"
  }

  Row {
    width: parent.width
    height: filterInfoItem.height

    AppListItem {
      id: filterInfoItem

      text: qsTr("Matched replays: %1/%2 (%3)")
      .arg(numReplaysFiltered).arg(numReplays)
      .arg(dataModel.formatPercentage(amountFiltered))

      width: parent.width - quickFilterItem.width

      detailTextItem: FilterDescription {
        id: description
        filter: stats && stats.dataBase.filterSettings || null
        height: Math.max(implicitHeight, dp(64))
      }

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

    AppListItem {
      id: quickFilterItem
      text: qsTr("Quick filters")
      width: visible ? dp(400) : 0
      height: parent.height
      mouseArea.hoverEffectEnabled: false
      backgroundColor: Theme.backgroundColor
      visible: parent.width > dp(1000) &&  showQuickFilters

      textVerticalSpacing: dp(Theme.contentPadding) / 2

      detailTextItem: QuickFilterOptions {
        id: quickFilterOptions
        height: description.height
        width: quickFilterItem.textItemAvailableWidth
        showPunishOptions: filterItem.showPunishFilter
        onQuickFilterChanged: filterItem.quickFilterChanged()
      }
    }
  }
}
