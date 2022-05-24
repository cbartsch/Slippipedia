import QtQuick 2.0
import QtQuick.Controls 2.12 as QQ
import Felgo 4.0

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
    label.text: "Game duration (mm:ss):"
    labelWidth: dp(200)

    range: filter && filter.duration

    textFunc: v => dataModel.formatTimeMs(v / 60 * 1000)
    valueFunc: v => {
                 var t = dataModel.parseTime(v)
                 return t && t >= 0 ? t / 1000 * 60 : undefined
               }
    validationText: qsTr("Enter time in format \"%1\"").arg("mm:ss")
  }

  SimpleSection {
    title: "Result"
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
      onClicked: filter.resetWinnerFilter()
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
        toolTipText: "Filter by games with any result"
        value: -3
        checked: filter ? filter.winnerPlayerIndex === value : false
        height: dp(48)
      }
      CustomRadio {
        id: winnerRadioMe
        text: "Won"
        toolTipText: "Filter by games won by matched player"
        value: 0
        checked: filter ? filter.winnerPlayerIndex === value : false
        height: dp(48)
      }
      CustomRadio {
        id: winnerRadioOpponent
        text: "Lost"
        toolTipText: "Filter by games not won by matched player"
        value: 1
        checked: filter ? filter.winnerPlayerIndex === value : false
        height: dp(48)
      }
      CustomRadio {
        id: winnerRadioEither
        text: "Either (no tie)"
        toolTipText: "Filter by games won by either player"
        value: -1
        checked: filter ? filter.winnerPlayerIndex === value : false
        height: dp(48)
      }
      CustomRadio {
        id: winnerRadioTie
        text: "No result / tie"
        toolTipText: "Filter by games with no winner/loser"
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
    height: endTypeRadioRow.height

    Flow {
      id: endTypeRadioRow
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: dp(Theme.contentPadding)
      spacing: dp(1)

      AppText {
        width: dp(120)
        height: dp(48)
        verticalAlignment: Text.AlignVCenter
        text: "Game end type:"
      }

      QQ.ButtonGroup {
        id: rbgEndType
        buttons: [radioEndAny, radioEndGame, radioEndTime,
                  radioEndNoContest, radioEndResolved, radioEndUnresolved]

        onCheckedButtonChanged: {
          for(var i = 0; i < buttons.length; i++) {
            if(buttons[i].checked) {
              filter.gameEndType = buttons[i].endType
              break
            }
          }
        }
      }

      CustomRadio {
        id: radioEndAny
        readonly property int endType: -1

        text: "Any"
        toolTipText: "Filter by any game ending type"
        checked: filter ? filter.gameEndType === endType : false
        height: dp(48)
        padding: dp(Theme.contentPadding)
      }

      CustomRadio {
        id: radioEndGame
        readonly property int endType: SlippiReplay.Game

        text: "Game!"
        toolTipText: "Filter by games with normal ending (last stock gone)"
        checked: filter ? filter.gameEndType === endType : false
        height: dp(48)
        padding: dp(Theme.contentPadding)
      }

      CustomRadio {
        id: radioEndTime
        readonly property int endType: SlippiReplay.Time

        text: "Time!"
        toolTipText: "Filter by games with timeout"
        checked: filter ? filter.gameEndType === endType : false
        height: dp(48)
        padding: dp(Theme.contentPadding)
      }

      CustomRadio {
        id: radioEndNoContest
        readonly property int endType: SlippiReplay.NoContest

        text: "No Contest"
        toolTipText: "Filter by games with no result (LRAS)"
        checked: filter ? filter.gameEndType === endType : false
        height: dp(48)
        padding: dp(Theme.contentPadding)
      }

      CustomRadio {
        id: radioEndResolved
        readonly property int endType: SlippiReplay.Resolved

        text: "Resolved"
        toolTipText: "Filter by resolved games (only used by replays made with Slippi 0.1)"
        checked: filter ? filter.gameEndType === endType : false
        height: dp(48)
        padding: dp(Theme.contentPadding)
      }

      CustomRadio {
        id: radioEndUnresolved
        readonly property int endType: SlippiReplay.Unresolved

        text: "Unresolved"
        toolTipText: "Filter by unresolved games (any other outcome e.g. game crash/disconnect)"
        checked: filter ? filter.gameEndType === endType : false
        height: dp(48)
        padding: dp(Theme.contentPadding)
      }
    }

    Divider { }
  }

  RangeOptions {
    label.text: "Stocks left (winner):"
    labelWidth: dp(200)

    range: filter && filter.endStocksWinner
  }

  RangeOptions {
    label.text: "Stocks left (loser):"
    labelWidth: dp(200)

    range: filter && filter.endStocksLoser
  }

  SimpleSection {
    title: "Win/loss determination options"
  }

  CustomListItem {
    text: "Set game loss type"
    detailText: "Change how to determine a game's winner/loser. Losing your last stock always counts as losing a game. This setting affects the filters and the statistics."

    backgroundColor: filter && filter.lossType > 0 ? Qt.darker(Theme.tintColor, 3) : Theme.backgroundColor
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      toolTipText: "Reset to default"
      visible: filter ? filter.lossType > 0 : false
      anchors.verticalCenter: parent.verticalCenter
      onClicked: filter.lossType = 0
    }
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
        buttons: [radioLossNoStock, radioLossLastStock, radioLossPercent,
                  radioLossLastLras, radioLossLras]

        onCheckedButtonChanged: {
          for(var i = 0; i < buttons.length; i++) {
            if(buttons[i].checked) {
              filter.lossType = i
              break
            }
          }
        }
      }

      CustomRadio {
        id: radioLossNoStock
        text: "No stocks left"
        toolTipText: "Game counts as lost only if the last stock is gone (normal game ending without LRAS)"
        checked: filter ? filter.lossType === 0 : false
        height: dp(48)
        padding: dp(Theme.contentPadding)
      }

      CustomRadio {
        id: radioLossLastLras
        text: "Last stock + LRAS"
        toolTipText: "Game counts as lost for the player who lost their last stock or ended the game with LRAS on their last stock (if any)"
        checked: filter ? filter.lossType === 3 : false
        height: dp(48)
        padding: dp(Theme.contentPadding)
      }

      CustomRadio {
        id: radioLossLras
        text: "Any LRAS"
        toolTipText: "Game counts as lost for the player who lost their last stock or ended the game with LRAS (if any)"
        checked: filter ? filter.lossType === 4 : false
        height: dp(48)
        padding: dp(Theme.contentPadding)
      }

      CustomRadio {
        id: radioLossLastStock
        text: "Last stock + higher percent"
        toolTipText: "Game counts as lost for the player at last stock and higher percent (if any)"
        checked: filter ? filter.lossType === 1 : false
        height: dp(48)
        padding: dp(Theme.contentPadding)
      }

      CustomRadio {
        id: radioLossPercent
        text: "Fewer stocks / higher percent"
        toolTipText: "Game always counts as lost for the player with fewer stocks or same number of stocks and higher percent"
        checked: filter ? filter.lossType === 2 : false
        height: dp(48)
        padding: dp(Theme.contentPadding)
      }
    }

    Divider { }
  }
}
