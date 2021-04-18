import QtQuick 2.0
import QtQuick.Controls 2.12 as QQ
import Felgo 3.0

import Slippipedia 1.0

Column {
  id: gameFilterOptions

  property ReplayStats stats: null
  readonly property GameFilterSettings filter: stats ? stats.dataBase.filterSettings.gameFilter : null

  SimpleSection {
    title: "Game Duration"
  }

  CustomListItem {
    text: "Filter by game duration"
    detailText: "Input a minimum and/or maximum game duration to match replays."

    checked: filter ? filter.hasDurationFilter : false
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      toolTipText: "Reset duration filter"

      visible: filter ? filter.hasDurationFilter : false
      anchors.verticalCenter: parent.verticalCenter

      onClicked: filter.duration.reset()
    }
  }

  TextInputField {
    labelText: "Game longer than (in seconds):"
    placeholderText: "Enter duration..."

    labelWidth: sp(250)
    showOptions: false

    textInput.inputMethodHints: Qt.ImhDigitsOnly

    text: filter && filter.duration.from > 0 ? filter.duration.from / 60 : ""

    onTextChanged: filter.duration.from = text ? text * 60 : -1
  }

  TextInputField {
    labelText: "Game shorter than (in seconds):"
    placeholderText: "Enter duration..."

    labelWidth: sp(250)
    showOptions: false

    textInput.inputMethodHints: Qt.ImhDigitsOnly

    text: filter && filter.duration.to > 0 ? filter.duration.to / 60 : ""

    onTextChanged: filter.duration.to = text ? text * 60 : -1
  }

  SimpleSection {
    title: "Winner"
  }

  CustomListItem {
    text: "Filter by game result"
    detailText: "Filter by won, lost, tied games or games with any result."

    backgroundColor: filter && filter.hasWinnerFilter ? Qt.darker(Theme.tintColor, 3) : Theme.backgroundColor
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      toolTipText: "Reset result filter"
      visible: filter ? filter.hasWinnerFilter : false
      anchors.verticalCenter: parent.verticalCenter

      onClicked: {
        filter.winnerPlayerIndex = -3
        filter.endStocks.reset()
      }
    }
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
        text: "Won"
        value: 0
        checked: filter ? filter.winnerPlayerIndex === value : false
        height: dp(48)
      }
      AppRadio {
        id: winnerRadioOpponent
        text: "Lost"
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

  TextInputField {
    labelText: "Stocks left (winner):"
    placeholderText: "Enter number..."

    labelWidth: sp(180)
    showOptions: false

    textInput.inputMethodHints: Qt.ImhDigitsOnly

    text: filter && filter.endStocks.from > 0 ? filter.endStocks.from : ""

    onTextChanged: filter.endStocks.from = text ? text : 0
  }
}
