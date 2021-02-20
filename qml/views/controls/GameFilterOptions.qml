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
    enabled: false
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
    title: "Date matching"
  }

  AppListItem {
    text: "Filter by replay date"
    detailText: "Select a date range to match replays in."

    backgroundColor: Theme.backgroundColor
    enabled: false
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

      AppButton {
        text: "Reset"
        flat: true
        iconLeft: IconType.trash

        onClicked: {
          setDateRange(null, null)
        }
      }

      AppButton {
        text: "Today"
        flat: true

        onClicked: {
          var start = new Date()
          start.setHours(0)
          start.setMinutes(0)

          var end = new Date()
          end.setTime(start.getTime() + 1000 * 60 * 60 * 24)

          setDateRange(start, end)
        }
      }

      AppButton {
        text: "Last week"
        flat: true

        onClicked: {
          var end = new Date()

          var start = new Date()
          start.setTime(end.getTime() - 1000 * 60 * 60 * 24 * 7)

          setDateRange(start, end)
        }
      }

      AppButton {
        text: "Last month"
        flat: true

        onClicked: {
          var end = new Date()

          var start = new Date()
          start.setTime(end.getTime())

          if(start.getMonth() === 0) {
            start.setFullYear(start.getFullYear() - 1)
            start.setMonth(11)
          }
          else {
            start.setMonth(start.getMonth() - 1)
          }

          setDateRange(start, end)
        }
      }

      AppButton {
        text: "Last year"
        flat: true

        onClicked: {
          var end = new Date()

          var start = new Date()
          start.setTime(end.getTime())
          start.setFullYear(start.getFullYear() - 1)

          setDateRange(start, end)
        }
      }
    }
  }

  TextInputField {
    id: textFieldStart
    labelText: "Start date:"
    placeholderText: qsTr("DD/MM/YYYY hh:mm")
    showOptions: false

    text: !filter || filter.startDateMs < 0 ? "" : dataModel.formatDate(new Date(filter.startDateMs))

    onTextChanged: {
      text = text // break binding

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

      filter.startDateMs = date.getTime()
    }
  }

  TextInputField {
    id: textFieldEnd
    labelText: "End date:"
    placeholderText: qsTr("DD/MM/YYYY hh:mm")
    showOptions: false

    text: !filter || filter.endDateMs < 0 ? "" : dataModel.formatDate(new Date(filter.endDateMs))

    onTextChanged: {
      text = text // break binding

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

      filter.endDateMs = date.getTime()
    }
  }

  function setDateRange(start, end) {
    console.log("date range", start, end)

    filter.startDateMs = start ? start.getTime() : -1
    textFieldStart.text = dataModel.formatDate(start)

    filter.endDateMs = end ? end.getTime() : -1
    textFieldEnd.text = dataModel.formatDate(end)
  }
}
