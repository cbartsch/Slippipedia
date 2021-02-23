import QtQuick 2.0
import QtQuick.Controls 2.12 as QQ
import Felgo 3.0

import "../../model/filter"
import "../../model/stats"
import "../grids"
import "../visual"

Column {
  id: gameFilterOptions

  property GameFilterSettings filter: null
  property ReplayStats stats: null


  SimpleSection {
    title: "Date range"
  }

  AppListItem {
    text: "Filter by replay date"
    detailText: "Select a date range to match replays in."

    backgroundColor: Theme.backgroundColor
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      toolTipText: "Reset stage filter"

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

    text: filter ? dateText(filter.startDateMs) : ""
    onEditingFinished: text = Qt.binding(() => dateText(filter.startDateMs))

    onTextChanged: {
      if(text == "") {
        filter.startDateMs = -1
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

      filter.startDateMs = date.getTime()
    }
  }

  TextInputField {
    id: textFieldEnd
    labelText: "Before:"
    placeholderText: qsTr("DD/MM/YYYY hh:mm")
    showOptions: false

    text: filter ? dateText(filter.endDateMs) : ""
    onEditingFinished: text = Qt.binding(() => dateText(filter.endDateMs))

    onTextChanged: {
      if(text == "") {
        filter.endDateMs = -1
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

      filter.endDateMs = date.getTime()
    }
  }

  SimpleSection {
    title: "Winner"
  }

  Item {
    width: 1
    height: dp(Theme.contentPadding)
  }

  Rectangle {
    width: parent.width
    height: winnerRadioRow.height
    color: Theme.controlBackgroundColor

    Flow {
      id: winnerRadioRow
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: spacing
      spacing: dp(Theme.contentPadding)

      QQ.ButtonGroup {
        id: rbgWinner
        buttons: [winnerRadioAny, winnerRadioTie, winnerRadioEither, winnerRadioMe, winnerRadioOpponent]

        onCheckedButtonChanged: filter.winnerPlayerIndex = checkedButton.value
      }

      AppRadio {
        id: winnerRadioAny
        text: "Any"
        value: -3
        checked: filter ? filter.winnerPlayerIndex === value : false
        height: dp(48)
      }
      AppRadio {
        id: winnerRadioMe
        text: "Me"
        value: 0
        checked: filter ? filter.winnerPlayerIndex === value : false
        height: dp(48)
      }
      AppRadio {
        id: winnerRadioOpponent
        text: "Opponent"
        value: 1
        checked: filter ? filter.winnerPlayerIndex === value : false
        height: dp(48)
      }
      AppRadio {
        id: winnerRadioEither
        text: "Either (no tie)"
        value: -1
        checked: filter ? filter.winnerPlayerIndex === value : false
        height: dp(48)
      }
      AppRadio {
        id: winnerRadioTie
        text: "No result"
        value: -2
        checked: filter ? filter.winnerPlayerIndex === value : false
        height: dp(48)
      }
    }
  }

  Item {
    width: parent.width
    height: 1

    Divider { }
  }

  SimpleSection {
    title: "Stage"
  }

  AppListItem {
    text: "Filter by specific stage"
    detailText: "Select a stage to limit all stats to that stage. Click again to unselect."

    backgroundColor: Theme.backgroundColor
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      toolTipText: "Reset stage filter"

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
    filter.startDateMs = -1
    filter.endDateMs = -1

    updateTexts()
  }

  function updateTexts() {
    textFieldStart.text = Qt.binding(() => dateText(filter.startDateMs))
    textFieldEnd.text = Qt.binding(() => dateText(filter.endDateMs))
  }

  function dateText(dateMs) {
     return dateMs < 0 ? "" : dataModel.formatDate(new Date(dateMs))
  }
}
