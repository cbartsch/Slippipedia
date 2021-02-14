import Felgo 3.0

import QtQuick 2.0
import QtQuick.Controls 2.12

import "../controls"
import "../model"

BasePage {
  title: qsTr("Filtering")

  Column {
    id: header
    width: parent.width

    SimpleSection {
      title: "Filtering"
    }

    AppListItem {
      text: qsTr("Matched replays: %1/%2 (%3)")
      .arg(dataModel.totalReplaysFiltered)
      .arg(dataModel.totalReplays)
      .arg(dataModel.formatPercentage(dataModel.totalReplaysFiltered / dataModel.totalReplays))

      detailText: qsTr("Matching: %1").arg(dataModel.filter.displayText)

      backgroundColor: Theme.backgroundColor
      mouseArea.enabled: false

      rightItem: AppToolButton {
        iconType: IconType.trash
        onClicked: dataModel.resetFilters()
        toolTipText: "Reset all filters"
      }
    }
  }

  AppFlickable {
    anchors.fill: parent
    anchors.topMargin: header.height
    contentHeight: content.height

    Column {
      id: content
      width: parent.width

      SimpleSection {
        title: "Player matching"
      }

      AppListItem {
        text: "Enter Slippi code and/or tag"
        detailText: "Replays are matched based on either connect code, in-game tag or both."

        backgroundColor: Theme.backgroundColor
        enabled: false
      }

      TextInputField {
        labelText: "Slippi code:"
        placeholderText: "Enter Slippi code..."

        text: dataModel.filter.slippiCode.filterText
        matchCaseSensitive: dataModel.filter.slippiCode.matchCase
        matchPartialText: dataModel.filter.slippiCode.matchPartial

        onTextChanged: dataModel.filter.slippiCode.filterText = text
        onMatchCaseSensitiveChanged: dataModel.filter.slippiCode.matchCase = matchCaseSensitive
        onMatchPartialTextChanged: dataModel.filter.slippiCode.matchPartial = matchPartialText
      }

      TextInputField {
        labelText: "Slippi name:"
        placeholderText: "Enter Slippi name..."

        text: dataModel.filter.slippiName.filterText
        matchCaseSensitive: dataModel.filter.slippiName.matchCase
        matchPartialText: dataModel.filter.slippiName.matchPartial

        onTextChanged: dataModel.filter.slippiName.filterText = text
        onMatchCaseSensitiveChanged: dataModel.filter.slippiName.matchCase = matchCaseSensitive
        onMatchPartialTextChanged: dataModel.filter.slippiName.matchPartial = matchPartialText
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

            onCheckedButtonChanged: dataModel.filter.filterCodeAndName = radioMatchAnd.checked
          }

          AppRadio {
            id: radioMatchOr
            text: "Match either code or tag"
            checked: !dataModel.filter.filterCodeAndName
            height: dp(48)
          }

          Item {
            // space
            width: dp(Theme.contentPadding)
            height: 1
          }

          AppRadio {
            id: radioMatchAnd
            checked: dataModel.filter.filterCodeAndName
            text: "Match both code and tag"
            height: dp(48)
          }
        }

        Divider { }
      }

      //    SimpleSection {
      //      title: "Date matching"
      //    }

      //    AppListItem {
      //      text: "Filter by replay date"
      //      detailText: "Select a date range to match replays in."

      //      backgroundColor: Theme.backgroundColor
      //      enabled: false
      //    }

      //    AppListItem {
      //      text: "Start date: "

      //      onSelected: nativeUtils.displayDatePicker()
      //    }

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

        charIds: dataModel.filter.charIds
        onCharSelected: {
          if(isSelected) {
            // char is selected -> unselect
            dataModel.filter.removeCharFilter(charId)
          }
          else {
            dataModel.filter.addCharFilter(charId)
          }
        }
      }

      SimpleSection {
        title: "Stage matching"
      }

      AppListItem {
        text: "Filter by specific stage"
        detailText: "Select a stage to limit all stats to that stage. Click again to unselect."

        backgroundColor: Theme.backgroundColor
        enabled: false
      }

      StageGrid {
        width: parent.width

        hideStagesWithNoReplays: false
        sortByCount: false
        showIcon: true
        showData: false
        showOtherItem: false

        stageIds: dataModel.filter.stageIds
        onStageSelected:{
          if(isSelected) {
            // char is selected -> unselect
            dataModel.filter.removeStageFilter(stageId)
          }
          else {
            dataModel.filter.addStageFilter(stageId)
          }
        }
      }
    }
  }

}
