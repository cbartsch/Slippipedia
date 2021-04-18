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

  Rectangle {
    width: parent.width
    height: dateOptionsRow.height
    color: Theme.controlBackgroundColor

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

  TextInputField {
    id: textFieldStart
    labelText: "After:"
    placeholderText: qsTr("DD/MM/YYYY hh:mm")
    showOptions: false

    text: filter ? dateText(filter.date.from) : ""
    onEditingFinished: text = Qt.binding(() => dateText(filter.date.from))

    onTextChanged: {
      if(text == "") {
        filter.date.from = 0
        return
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
        return
      }

      text = text // break binding to not re-format the date

      filter.date.from = date.getTime()
    }
  }

  TextInputField {
    id: textFieldEnd
    labelText: "Before:"
    placeholderText: qsTr("DD/MM/YYYY hh:mm")
    showOptions: false

    text: filter ? dateText(filter.date.to) : ""
    onEditingFinished: text = Qt.binding(() => dateText(filter.date.to))

    onTextChanged: {
      if(text == "") {
        filter.date.to = 0
        return
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
        return
      }

      text = text // break binding to not re-format the date

      filter.date.to = date.getTime()
    }
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
    textFieldStart.text = Qt.binding(() => dateText(filter.date.from))
    textFieldEnd.text = Qt.binding(() => dateText(filter.date.to))
  }

  function dateText(dateMs) {
     return dateMs <= 0 ? "" : dataModel.formatDate(new Date(dateMs))
  }
}
