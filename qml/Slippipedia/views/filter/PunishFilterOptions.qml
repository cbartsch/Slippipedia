import QtQuick 2.0
import QtQuick.Controls 2.12 as QQ
import Felgo 3.0

import Slippipedia 1.0

Column {
  id: gameFilterOptions

  property ReplayStats stats: null
  readonly property PunishFilterSettings filter: stats ? stats.dataBase.filterSettings.punishFilter : null

  SimpleSection {
    title: "Moves / damage"
  }

  CustomListItem {
    text: "Filter by attacks and damage"
    detailText: "Select a minimum number of moves and damage for matching punishes."

    checked: filter ? filter.hasNumMovesFilter || filter.hasDamageFilter : false
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      toolTipText: "Reset moves/damage filter"
      visible: filter ? filter.hasNumMovesFilter || filter.hasDamageFilter : false
      anchors.verticalCenter: parent.verticalCenter

      onClicked: {
        filter.minMoves = 1
        filter.minDamage = 0
      }
    }
  }

  TextInputField {
    labelText: "Least number of moves:"
    placeholderText: "Enter number..."

    labelWidth: sp(250)
    showOptions: false

    textInput.inputMethodHints: Qt.ImhDigitsOnly

    text: filter && filter.hasNumMovesFilter && filter.minMoves || ""

    onTextChanged: if(filter) filter.minMoves = text || 1
  }

  TextInputField {
    labelText: "More damage than:"
    placeholderText: "Enter number..."

    labelWidth: sp(250)
    showOptions: false

    textInput.inputMethodHints: Qt.ImhDigitsOnly

    text: filter && filter.minDamage || ""

    onTextChanged: if(filter) filter.minDamage = text || 0
  }

  SimpleSection {
    title: "Kill"
  }

  CustomListItem {
    text: "Filter by kill properties"
    detailText: "Select properties of how the opponend was killed to match punishes."

    checked: filter ? filter.hasDidKillFilter || filter.hasKillDirectionFilter : false
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      toolTipText: "Reset moves/damage filter"
      visible: filter ? filter.hasDidKillFilter || filter.hasKillDirectionFilter : false
      anchors.verticalCenter: parent.verticalCenter

      onClicked: {
        filter.didKill = false
        filter.removeAllKillDirections()
        didKillCheckBox.checked = false
      }
    }
  }

  AppListItem {
    leftItem: AppCheckBox {
      id: didKillCheckBox
      anchors.verticalCenter: parent.verticalCenter

      checked: filter && filter.didKill || false

      onCheckedChanged: if(filter) filter.didKill = checked
    }

    text: "Punish did kill"

    onSelected: didKillCheckBox.checked = !didKillCheckBox.checked
  }

  Rectangle {
    width: parent.width
    height: killDirectionFlow.height
    color: Theme.controlBackgroundColor

    Flow {
      id: killDirectionFlow
      width: parent.width

      Item {
        height: dp(48)
        width: directionText.width + dp(Theme.contentPadding) * 2

        AppText {
          id: directionText
          text: "Kill direction:"
          anchors.centerIn: parent
        }
      }

      Repeater {
        model: MeleeData.killDirectionNamesUsed

        Item {
          readonly property int killDirection: index

          height: dp(48)
          width: directionCheckBox.width + dp(Theme.contentPadding) * 2

          RippleMouseArea {
            anchors.fill: parent
            hoverEffectEnabled: true
            backgroundColor: Theme.listItem.selectedBackgroundColor
            fillColor: backgroundColor
            opacity: 0.5
            onClicked: directionCheckBox.checked = !directionCheckBox.checked
          }

          AppCheckBox {
            id: directionCheckBox
            text: modelData
            anchors.centerIn: parent
            checked: filter ? filter.killDirections.indexOf(killDirection) >= 0 : false

            onCheckedChanged: {
              if(checked) {
                filter.addKillDirection(killDirection)
              }
              else {
                filter.removeKillDirection(killDirection)
              }
            }
          }
        }
      }
    }
  }

  Divider { anchors.bottom: undefined }

  SimpleSection {
    title: "Opening"
  }

  CustomListItem {
    text: "Filter by opening"
    detailText: "Select properties of how the punish was started."

    checked: filter ? filter.hasOpeningMoveFilter : false
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      toolTipText: "Reset opening filter"
      visible: filter ? filter.hasOpeningMoveFilter : false
      anchors.verticalCenter: parent.verticalCenter

      onClicked: {
        filter.removeAllOpeningMoves()
      }
    }
  }

  Rectangle {
    width: parent.width
    height: openingMoveFlow.height
    color: Theme.controlBackgroundColor

    Flow {
      id: openingMoveFlow
      width: parent.width

      Item {
        height: dp(48)
        width: openingText.width + dp(Theme.contentPadding) * 2

        AppText {
          id: openingText
          text: "Opening move:"
          anchors.centerIn: parent
        }
      }

      Repeater {
        model: MeleeData.moveNamesShortUsed

        Item {
          readonly property int moveId: MeleeData.moveIdsShort[moveName]
          readonly property string moveName: modelData

          height: dp(48)
          width: moveCheckBox.width + dp(Theme.contentPadding) * 2

          RippleMouseArea {
            anchors.fill: parent
            hoverEffectEnabled: true
            backgroundColor: Theme.listItem.selectedBackgroundColor
            fillColor: backgroundColor
            opacity: 0.5
            onClicked: moveCheckBox.checked = !moveCheckBox.checked
          }

          AppCheckBox {
            id: moveCheckBox
            text: moveName
            anchors.centerIn: parent
            checked: filter ? filter.openingMoveIds.indexOf(moveId) >= 0 : false

            onCheckedChanged: {
              if(checked) {
                filter.addOpeningMove(moveId)
              }
              else {
                filter.removeOpeningMove(moveId)
              }
            }
          }
        }
      }
    }
  }

  Divider { anchors.bottom: undefined }

  SimpleSection {
    title: "Last move"
  }

  CustomListItem {
    text: "Filter by last move"
    detailText: "Select properties of how the punish ended."

    checked: filter ? filter.hasLastMoveFilter : false
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      toolTipText: "Reset last move filter"
      visible: filter ? filter.hasLastMoveFilter : false
      anchors.verticalCenter: parent.verticalCenter

      onClicked: {
        filter.removeAllLastMoves()
      }
    }
  }

  Rectangle {
    width: parent.width
    height: lastMoveFlow.height
    color: Theme.controlBackgroundColor

    Flow {
      id: lastMoveFlow
      width: parent.width

      Item {
        height: dp(48)
        width: lastText.width + dp(Theme.contentPadding) * 2

        AppText {
          id: lastText
          text: "Last move:"
          anchors.centerIn: parent
        }
      }

      Repeater {
        model: MeleeData.moveNamesShortUsed

        Item {
          readonly property int moveId: MeleeData.moveIdsShort[moveName]
          readonly property string moveName: modelData

          height: dp(48)
          width: moveCheckBox.width + dp(Theme.contentPadding) * 2

          RippleMouseArea {
            anchors.fill: parent
            hoverEffectEnabled: true
            backgroundColor: Theme.listItem.selectedBackgroundColor
            fillColor: backgroundColor
            opacity: 0.5
            onClicked: moveCheckBox.checked = !moveCheckBox.checked
          }

          AppCheckBox {
            id: moveCheckBox
            text: moveName
            anchors.centerIn: parent
            checked: filter ? filter.lastMoveIds.indexOf(moveId) >= 0 : false

            onCheckedChanged: {
              if(checked) {
                filter.addLastMove(moveId)
              }
              else {
                filter.removeLastMove(moveId)
              }
            }
          }
        }
      }
    }
  }

  Divider { anchors.bottom: undefined }
}
