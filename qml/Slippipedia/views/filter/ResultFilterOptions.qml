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

  RangeOptions {
    label.text: "Game duration (in seconds):"
    labelWidth: dp(200)

    range: filter && filter.duration

    textFunc: v => v / 60
    valueFunc: v => v * 60
  }

  SimpleSection {
    title: "Winner"
  }

  CustomListItem {
    text: "Filter by game result"
    detailText: "Filter by won, lost, tied games or games with any result. Set when to count a game as lost."

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

  Item {
    width: parent.width
    height: winnerRadioRow.height

    Flow {
      id: winnerRadioRow
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: dp(Theme.contentPadding)
      spacing: dp(1)

      AppText {
        width: dp(120)
        height: dp(48)
        verticalAlignment: Text.AlignVCenter
        text: "Game result:"
      }

      QQ.ButtonGroup {
        id: rbgWinner
        buttons: [winnerRadioAny, winnerRadioTie, winnerRadioEither, winnerRadioMe, winnerRadioOpponent]

        onCheckedButtonChanged: filter.winnerPlayerIndex = checkedButton.value
      }

      CustomRadio {
        id: winnerRadioAny
        text: "Any"
        value: -3
        checked: filter ? filter.winnerPlayerIndex === value : false
        height: dp(48)
      }
      CustomRadio {
        id: winnerRadioMe
        text: "Won"
        value: 0
        checked: filter ? filter.winnerPlayerIndex === value : false
        height: dp(48)
      }
      CustomRadio {
        id: winnerRadioOpponent
        text: "Lost"
        value: 1
        checked: filter ? filter.winnerPlayerIndex === value : false
        height: dp(48)
      }
      CustomRadio {
        id: winnerRadioEither
        text: "Either (no tie)"
        value: -1
        checked: filter ? filter.winnerPlayerIndex === value : false
        height: dp(48)
      }
      CustomRadio {
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

  Item {
    width: parent.width
    height: lossTypeRadioRow.height

    Flow {
      id: lossTypeRadioRow
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: dp(Theme.contentPadding)
      spacing: dp(1)

      AppText {
        width: dp(120)
        height: dp(48)
        verticalAlignment: Text.AlignVCenter
        text: "Count loss if:"
      }

      QQ.ButtonGroup {
        id: rbgLossType
        buttons: [radioLossNoStock, radioLossLastStock, radioLossPercent]

        onCheckedButtonChanged: filter.lossType = radioLossNoStock.checked ? 0 : radioLossLastStock.checked ? 1 : 2
      }

      CustomRadio {
        id: radioLossNoStock
        text: "No stocks left"
        checked: filter ? filter.lossType === 0 : false
        height: dp(48)
        padding: dp(Theme.contentPadding)
      }

      CustomRadio {
        id: radioLossLastStock
        text: "Last stock + higher percent"
        checked: filter ? filter.lossType === 1 : false
        height: dp(48)
        padding: dp(Theme.contentPadding)
      }

      CustomRadio {
        id: radioLossPercent
        text: "Fewer stocks / higher percent"
        checked: filter ? filter.lossType === 2 : false
        height: dp(48)
        padding: dp(Theme.contentPadding)
      }
    }

    Divider { }
  }

  RangeOptions {
    label.text: "Stocks left (winner):"
    labelWidth: dp(200)

    range: filter && filter.endStocks
  }
}
