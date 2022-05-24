import QtQuick 2.0
import QtQuick.Controls 2.12
import Felgo 3.0

import Slippipedia 1.0

Column {
  property bool me: true
  readonly property string meText: me ? "your" : "opponent's"

  property ReplayStats stats: null
  readonly property PlayerFilterSettings filter: stats ? stats.dataBase.filterSettings[
                                                           me ? "playerFilter" : "opponentFilter"
                                                         ]
                                                       : null

  SimpleSection {
    title: me ? "Player" : "Opponent"
  }

  CustomListItem {
    text: qsTr("Filter by %1 Slippi code and/or tag").arg(meText)
    detailText: (me ? "Add player filter to show win rate and oppponent stats. " : "") +
                "Replays are matched based on either connect code, in-game tag or both."


    checked: filter ? filter.hasPlayerFilter : false
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      toolTipText: "Reset player filter"

      visible: filter ? filter.hasPlayerFilter : false
      anchors.verticalCenter: parent.verticalCenter

      onClicked: filter.resetPlayerFilter()
    }
  }

  TextInputField {
    labelText: "Slippi code:"
    placeholderText: qsTr("Enter %1 Slippi code...").arg(meText)

    text:               filter ? filter.slippiCode.filterText : ""
    matchCaseSensitive: filter ? filter.slippiCode.matchCase : false
    matchPartialText:   filter ? filter.slippiCode.matchPartial : false

    onTextChanged:               if(filter) filter.slippiCode.filterText = text
    onMatchCaseSensitiveChanged: if(filter) filter.slippiCode.matchCase = matchCaseSensitive
    onMatchPartialTextChanged:   if(filter) filter.slippiCode.matchPartial = matchPartialText
  }

  TextInputField {
    labelText: "Slippi name:"
    placeholderText: qsTr("Enter %1 Slippi name...").arg(meText)

    text:               filter ? filter.slippiName.filterText : ""
    matchCaseSensitive: filter ? filter.slippiName.matchCase : false
    matchPartialText:   filter ? filter.slippiName.matchPartial : false

    onTextChanged:               if(filter) filter.slippiName.filterText = text
    onMatchCaseSensitiveChanged: if(filter) filter.slippiName.matchCase = matchCaseSensitive
    onMatchPartialTextChanged:   if(filter) filter.slippiName.matchPartial = matchPartialText
  }

  Item {
    width: parent.width
    height: radioRow.height

    Flow {
      id: radioRow
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: dp(Theme.contentPadding)
      spacing: dp(1)

      AppText {
        width: dp(120)
        height: dp(48)
        verticalAlignment: Text.AlignVCenter
        text: "Match mode:"
      }

      ButtonGroup {
        id: rbgMatchType
        buttons: [radioMatchAnd, radioMatchOr]

        onCheckedButtonChanged: filter.filterCodeAndName = radioMatchAnd.checked
      }

      CustomRadio {
        id: radioMatchOr
        text: "Match either code or tag"
        checked: filter ? !filter.filterCodeAndName : false
        height: dp(48)
        padding: dp(Theme.contentPadding)
      }

      CustomRadio {
        id: radioMatchAnd
        checked: filter ? filter.filterCodeAndName : false
        text: "Match both code and tag"
        height: dp(48)
        padding: dp(Theme.contentPadding)
      }
    }

    Divider { }
  }

  Item {
    width: parent.width
    height: radioRowPort.height

    Flow {
      id: radioRowPort
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: dp(Theme.contentPadding)
      spacing: dp(1)

      AppText {
        width: dp(120)
        height: dp(48)
        verticalAlignment: Text.AlignVCenter
        text: "Controller port:"
      }

      ButtonGroup {
        id: rbgPort

        onCheckedButtonChanged: filter.port = checkedButton.value
      }

      CustomRadio {
        id: radioPortAny
        text: "Any port"
        checked: filter ? filter.port === -1 : false
        height: dp(48)
        padding: dp(Theme.contentPadding)
        ButtonGroup.group: rbgPort

        readonly property int value: -1
      }

      Repeater {
        model: 4

        CustomRadio {
          id: radioPort
          text: "Port " + (index + 1)
          checked: filter ? filter.port === index : false
          height: dp(48)
          padding: dp(Theme.contentPadding)
          ButtonGroup.group: rbgPort

          readonly property int value: index
        }
      }

    }

    Divider { }
  }


  SimpleSection {
    title: "Character"
  }

  CustomListItem {
    text: "Filter by specific characters"
    detailText: "Find replays using selected characters. Click again to unselect."

    checked: filter ? filter.hasCharFilter : false
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      toolTipText: "Reset character filter"

      visible: filter ? filter.hasCharFilter : false
      anchors.verticalCenter: parent.verticalCenter

      onClicked: filter.removeAllCharFilters()
    }
  }

  CharacterGrid {
    width: parent.width

    sourceModel: stats ? stats.statsPlayer.charDataCss : []
    stats: filterPage.stats

    charIds: filter ? filter.charIds : []
    onCharSelected: (charId, isSelected) => {
      if(isSelected) {
        // char is selected -> unselect
        filter.removeCharFilter(charId)
      }
      else {
        filter.addCharFilter(charId)
      }
    }
  }
}
