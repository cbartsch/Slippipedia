import QtQuick 2.0
import QtQuick.Controls 2.12 as QQ
import Felgo 4.0

import Slippipedia 1.0

Column {
  id: gameFilterOptions

  property ReplayStats stats: null
  readonly property PunishFilterSettings filter: stats ? stats.dataBase.filterSettings.punishFilter : null

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

  Item {
    width: parent.width
    height: killDirectionFlow.height

    Flow {
      id: killDirectionFlow
      width: parent.width
      spacing: dp(1)

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

        Rectangle {
          readonly property int killDirection: index

          height: dp(48)
          width: directionCheckBox.width + dp(Theme.contentPadding) * 2
          color: Theme.controlBackgroundColor

          AppCheckBox {
            id: directionCheckBox
            text: modelData
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: dp(Theme.contentPadding)

            checked: filter ? filter.killDirections.indexOf(killDirection) >= 0 : false
          }

          RippleMouseArea {
            anchors.fill: parent
            hoverEffectEnabled: true
            backgroundColor: Theme.listItem.selectedBackgroundColor
            fillColor: backgroundColor
            opacity: 0.5
            onClicked: {
              if(!directionCheckBox.checked) {
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
    title: "Moves / damage"
  }

  CustomListItem {
    text: "Filter by attacks and damage"
    detailText: "Select number of moves and damage for matching punishes."

    checked: filter ? filter.hasNumMovesFilter || filter.hasDamageFilter : false
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      toolTipText: "Reset moves/damage filter"
      visible: filter ? filter.hasNumMovesFilter || filter.hasDamageFilter : false
      anchors.verticalCenter: parent.verticalCenter

      onClicked: {
        filter.numMoves.reset()
        filter.damage.reset()
      }
    }
  }

  RangeOptions {
    label.text: "Number of moves:"
    labelWidth: dp(150)

    range: filter && filter.numMoves
  }

  RangeOptions {
    label.text: "Damage:"
    labelWidth: dp(150)

    range: filter && filter.damage
  }

  SimpleSection {
    title: "Percent"
  }

  CustomListItem {
    text: "Filter by player percent"
    detailText: "Select player's percent range at start and/or end of punish."

    checked: filter ? filter.hasStartPercentFilter || filter.hasEndPercentFilter : false
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      toolTipText: "Reset player percent filter"
      visible: filter ? filter.hasStartPercentFilter || filter.hasEndPercentFilter : false
      anchors.verticalCenter: parent.verticalCenter

      onClicked: {
        filter.startPercent.reset()
        filter.endPercent.reset()
      }
    }
  }

  RangeOptions {
    label.text: "At start of punish:"
    labelWidth: dp(150)

    range: filter && filter.startPercent
  }

  RangeOptions {
    label.text: "At end of punish:"
    labelWidth: dp(150)

    range: filter && filter.endPercent
  }

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

      onClicked: filter.removeAllOpeningMoves()
    }
  }

  Item {
    width: parent.width
    height: openingMoveFlow.height

    Flow {
      id: openingMoveFlow
      width: parent.width
      spacing: dp(1)

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

        Rectangle {
          readonly property int moveId: MeleeData.moveIdsShort[moveName]
          readonly property string moveName: modelData
          readonly property string moveNameFull: MeleeData.moveNames[moveId]

          height: dp(48)
          width: moveCheckBox.width + dp(Theme.contentPadding) * 2

          color: Theme.controlBackgroundColor

          AppCheckBox {
            id: moveCheckBox
            text: moveName
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: dp(Theme.contentPadding)

            checked: filter ? filter.openingMoveIds.indexOf(moveId) >= 0 : false

            CustomToolTip {
              text: moveNameFull
              shown: mouseArea.containsMouse
            }
          }

          RippleMouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEffectEnabled: true
            backgroundColor: Theme.listItem.selectedBackgroundColor
            fillColor: backgroundColor
            opacity: 0.5
            onClicked: {
              if(!moveCheckBox.checked) {
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

  Item {
    width: parent.width
    height: lastMoveFlow.height

    Flow {
      id: lastMoveFlow
      width: parent.width
      spacing: dp(1)

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

        Rectangle {
          readonly property int moveId: MeleeData.moveIdsShort[moveName]
          readonly property string moveName: modelData
          readonly property string moveNameFull: MeleeData.moveNames[moveId]

          height: dp(48)
          width: lmoveCheckBox.width + dp(Theme.contentPadding) * 2
          color: Theme.controlBackgroundColor

          AppCheckBox {
            id: lmoveCheckBox
            text: moveName
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: dp(Theme.contentPadding)

            checked: filter ? filter.lastMoveIds.indexOf(moveId) >= 0 : false

            CustomToolTip {
              text: moveNameFull
              shown: mouseArea.containsMouse
            }
          }

          RippleMouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEffectEnabled: true
            backgroundColor: Theme.listItem.selectedBackgroundColor
            fillColor: backgroundColor
            opacity: 0.5
            onClicked: {
              if(!lmoveCheckBox.checked) {
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
