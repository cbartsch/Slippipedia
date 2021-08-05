import QtQuick 2.0
import QtQuick.Controls 2.12 as QQ
import Felgo 3.0

import Slippipedia 1.0

Column {
  id: gameFilterOptions

  property ReplayStats stats: null
  readonly property GameFilterSettings filter: stats ? stats.dataBase.filterSettings.gameFilter : null

  SimpleSection {
    title: "Date range"
  }

  CustomListItem {
    text: "Filter by replay date"
    detailText: "Select a date range to match replays in."

    checked: filter ? filter.hasDateFilter : false
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      toolTipText: "Reset stage filter"
      visible: filter ? filter.hasDateFilter : false
      anchors.verticalCenter: parent.verticalCenter

      onClicked: clearDateRange()
    }
  }

  Item {
    width: parent.width
    height: dateOptionsRow.height

    Flow {
      id: dateOptionsRow
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: spacing
      spacing: dp(Theme.contentPadding)

      DateRangeRow {
        numDays: 1
        onSetPastRange: gameFilterOptions.setPastRange(numDays)
        onAddDateRange: gameFilterOptions.addDateRange(numDays)
      }

      DateRangeRow {
        numDays: 7
        onSetPastRange: gameFilterOptions.setPastRange(numDays)
        onAddDateRange: gameFilterOptions.addDateRange(numDays)
      }

      DateRangeRow {
        numDays: 30
        onSetPastRange: gameFilterOptions.setPastRange(numDays)
        onAddDateRange: gameFilterOptions.addDateRange(numDays)
      }

      DateRangeRow {
        numDays: 365
        onSetPastRange: gameFilterOptions.setPastRange(numDays)
        onAddDateRange: gameFilterOptions.addDateRange(numDays)
      }
    }
  }

  RangeOptions {
    id: dateOptions

    label.text: "Date:"
    labelWidth: dp(100)

    range: filter && filter.date

    textFunc: dateText
    valueFunc: dateValue
  }

  SimpleSection {
    title: "Stage"
  }

  CustomListItem {
    text: "Filter by specific stage"
    detailText: "Select a stage to limit all stats to that stage. Click again to unselect."

    checked: filter ? filter.hasStageFilter : false
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      toolTipText: "Reset stage filter"
      visible: filter ? filter.hasStageFilter : false
      anchors.verticalCenter: parent.verticalCenter

      onClicked: filter.removeAllStages()
    }
  }

  StageGrid {
    width: parent.width

    sourceModel: stats && stats.stageDataSss || []
    stats: gameFilterOptions.stats

    hideStagesWithNoReplays: false
    sortByCount: false
    showIcon: true
    showData: false
    showOtherItem: false

    stageIds: filter ? filter.stageIds : []
    onStageSelected: {
      if(isSelected) {
        // char is selected -> unselect
        filter.removeStage(stageId)
      }
      else {
        filter.addStage(stageId)
      }
    }
  }


  SimpleSection {
    title: "Other options"
  }

  CustomListItem {
    text: "Session split interval"
    detailText: "Split sessions against the same opponent after certain amount of time."

    checked: filter ? filter.hasSessionSplitInterval : false
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      toolTipText: qsTr("Reset session split interval to default (%1)").arg(dataModel.formatTimeMs(filter.sessionSplitIntervalMsDefault))
      visible: filter ? filter.hasSessionSplitInterval : false
      anchors.verticalCenter: parent.verticalCenter

      onClicked: filter.sessionSplitIntervalMs = filter.sessionSplitIntervalMsDefault
    }
  }

  TextInputField {
    labelText: "Interval (hh:mm:ss)"
    labelWidth: dp(240)
    showOptions: false

    text: filter && filter.sessionSplitIntervalMs > 0 ? dataModel.formatTimeMs(filter.sessionSplitIntervalMs, false) : ""
    placeholderText: "Never split sessions"

    onTextChanged: {
      if(!filter) {
        return
      }

      if(text.length === 0) {
        filter.sessionSplitIntervalMs = 0
        return
      }

      var intervalMs = dataModel.parseTime(text)

      if(intervalMs >= 0) {
        filter.sessionSplitIntervalMs = intervalMs
      }
    }
  }

  function setPastRange(numDays) {
    filter.setPastRange(numDays)

    updateTexts()
  }

  function addDateRange(numDays) {
    filter.addDateRange(numDays)

    updateTexts()
  }

  function clearDateRange() {
    filter.date.reset()

    updateTexts()
  }

  function updateTexts() {
    dateOptions.inputFrom.text = Qt.binding(() => dateText(filter.date.from))
    dateOptions.inputTo.text = Qt.binding(() => dateText(filter.date.to))
  }

  function dateText(dateMs) {
     return dateMs < 0 ? "" : dataModel.formatDate(new Date(dateMs))
  }

  function dateValue(text, input) {
    if(text === "") {
      return -1
    }

    var formats = [
          "dd/MM/yyyy hh:mm", "dd/MM/yyyy",
          "dd.MM.yyyy hh:mm", "dd.MM.yyyy",
        ]

    var date
    for(var i = 0; i < formats.length && !isDateValid(date); i++) {
      date = Date.fromLocaleString(Qt.locale(), text, formats[i])
    }

    if(!isDateValid(date)) {
      // text entered but no valid date - do not change value
      return undefined
    }

    input.text = text // break binding to not re-format the date

    return date.getTime()
  }
}
