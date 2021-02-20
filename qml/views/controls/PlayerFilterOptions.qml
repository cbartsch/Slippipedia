import QtQuick 2.0
import QtQuick.Controls 2.12
import Felgo 3.0

import "../../model/filter"
import "../grids"
import "../visual"

Column {
  property bool me: true
  readonly property string meText: me ? "your" : "opponent's"

  property PlayerFilterSettings filter: null

  SimpleSection {
    title: "Player"
  }

  Item {
    width: 1
    height: dp(Theme.contentPadding)
  }

  AppListItem {
    text: qsTr("Enter %1 Slippi code and/or tag").arg(meText)
    detailText: "Replays are matched based on either connect code, in-game tag or both."

    backgroundColor: Theme.backgroundColor
    enabled: false
  }

  TextInputField {
    labelText: "Slippi code:"
    placeholderText: qsTr("Enter %1 Slippi code...").arg(meText)

    text: filter.slippiCode.filterText
    matchCaseSensitive: filter.slippiCode.matchCase
    matchPartialText: filter.slippiCode.matchPartial

    onTextChanged: filter.slippiCode.filterText = text
    onMatchCaseSensitiveChanged: filter.slippiCode.matchCase = matchCaseSensitive
    onMatchPartialTextChanged: filter.slippiCode.matchPartial = matchPartialText
  }

  TextInputField {
    labelText: "Slippi name:"
    placeholderText: qsTr("Enter %1 Slippi name...").arg(meText)

    text: filter.slippiName.filterText
    matchCaseSensitive: filter.slippiName.matchCase
    matchPartialText: filter.slippiName.matchPartial

    onTextChanged: filter.slippiName.filterText = text
    onMatchCaseSensitiveChanged: filter.slippiName.matchCase = matchCaseSensitive
    onMatchPartialTextChanged: filter.slippiName.matchPartial = matchPartialText
  }

  Rectangle {
    width: parent.width
    height: radioRow.height
    color: Theme.controlBackgroundColor

    Flow {
      id: radioRow
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: dp(Theme.contentPadding)

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

      AppRadio {
        id: radioMatchOr
        text: "Match either code or tag"
        checked: !filter.filterCodeAndName
        height: dp(48)
      }

      Item {
        // space
        width: dp(Theme.contentPadding)
        height: 1
      }

      AppRadio {
        id: radioMatchAnd
        checked: filter.filterCodeAndName
        text: "Match both code and tag"
        height: dp(48)
      }
    }

    Divider { }
  }

  SimpleSection {
    title: "Character matching"
  }

  AppListItem {
    text: "Filter by specific characters"
    detailText: "Find replays using selected characters. Click again to unselect."

    backgroundColor: Theme.backgroundColor
    enabled: false
  }

  CharacterGrid {
    width: parent.width

    sourceModel: stats ? stats.statsPlayer.charDataCss : []
    stats: filterPage.stats

    charIds: filter.charIds
    onCharSelected: {
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
