import QtQuick 2.0
import QtQuick.Controls 2.12 as QQ
import Felgo 3.0

import "../../model/filter"
import "../../model/stats"

import "../controls"
import "../grids"
import "../listitems"
import "../visual"

Column {
  id: gameFilterOptions

  property GameFilterSettings filter: null
  property ReplayStats stats: null

  SimpleSection {
    title: "Game Duration"
  }

  CheckableListItem {
    text: "Filter by game duration"
    detailText: "Input a minimum and/or maximum game duration to match replays."

    checked: filter.hasDurationFilter
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      toolTipText: "Reset duration filter"

      visible: filter.hasDurationFilter
      anchors.verticalCenter: parent.verticalCenter

      onClicked: {
        filter.minFrames = -1
        filter.maxFrames = -1
      }
    }
  }

  TextInputField {
    labelText: "Game longer than (in seconds):"
    placeholderText: "Enter duration..."

    labelWidth: sp(250)
    showOptions: false

    text: filter.minFrames >= 0 ? filter.minFrames / 60 : ""

    onTextChanged: filter.minFrames = text ? text * 60 : -1
  }

  TextInputField {
    labelText: "Game shorter than (in seconds):"
    placeholderText: "Enter duration..."

    labelWidth: sp(250)
    showOptions: false

    text: filter.maxFrames >= 0 ? filter.maxFrames / 60 : ""

    onTextChanged: filter.maxFrames = text ? text * 60 : -1
  }

  Item {
    width: parent.width
    height: dp(1)

    Divider { }
  }

  SimpleSection {
    title: "Winner"
  }

  CheckableListItem {
    text: "Filter by game result"
    detailText: "Filter by won, lost, tied games or games with any result."

    backgroundColor: filter.hasWinnerFilter ? Qt.darker(Theme.tintColor, 3) : Theme.backgroundColor
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      toolTipText: "Reset result filter"
      visible: filter.hasWinnerFilter
      anchors.verticalCenter: parent.verticalCenter

      onClicked: filter.winnerPlayerIndex = -3
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
}
