import Felgo 3.0

import QtQuick 2.0
import QtQuick.Controls 2.12

import "../controls"
import "../model"

BasePage {
  title: qsTr("Filtering")

  SimpleSection {
    id: titleSection
    title: "Filtering"
  }

  AppListItem {
    id: matchListItem
    anchors.top: titleSection.bottom

    text: qsTr("Matched replays: %1/%2 (%3)")
    .arg(dataModel.totalReplaysFiltered)
    .arg(dataModel.totalReplays)
    .arg(dataModel.formatPercentage(dataModel.totalReplaysFiltered / dataModel.totalReplays))

    detailText: qsTr("Matching: %1").arg(dataModel.filterDisplayText)

    backgroundColor: Theme.backgroundColor
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      onClicked: dataModel.resetFilters()
      toolTipText: "Reset all filters"
    }
  }

  AppFlickable {
    width: parent.width
    anchors.top: matchListItem.bottom
    anchors.bottom: parent.bottom
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

        text: dataModel.filterSlippiCode.filterText
        matchCaseSensitive: dataModel.filterSlippiCode.matchCase
        matchPartialText: dataModel.filterSlippiCode.matchPartial

        onTextChanged: dataModel.filterSlippiCode.filterText = text
        onMatchCaseSensitiveChanged: dataModel.filterSlippiCode.matchCase = matchCaseSensitive
        onMatchPartialTextChanged: dataModel.filterSlippiCode.matchPartial = matchPartialText
      }

      TextInputField {
        labelText: "Slippi name:"
        placeholderText: "Enter Slippi name..."

        text: dataModel.filterSlippiName.filterText
        matchCaseSensitive: dataModel.filterSlippiName.matchCase
        matchPartialText: dataModel.filterSlippiName.matchPartial

        onTextChanged: dataModel.filterSlippiName.filterText = text
        onMatchCaseSensitiveChanged: dataModel.filterSlippiName.matchCase = matchCaseSensitive
        onMatchPartialTextChanged: dataModel.filterSlippiName.matchPartial = matchPartialText
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

            onCheckedButtonChanged: dataModel.filterCodeAndName = radioMatchAnd.checked
          }

          AppRadio {
            id: radioMatchOr
            text: "Match either code or tag"
            checked: !dataModel.filterCodeAndName
            height: dp(48)
          }

          Item {
            // space
            width: dp(Theme.contentPadding)
            height: 1
          }

          AppRadio {
            id: radioMatchAnd
            checked: dataModel.filterCodeAndName
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

        charIds: dataModel.filterCharIds
        onCharSelected: {
          if(isSelected) {
            // char is selected -> unselect
            dataModel.removeCharFilter(charId)
          }
          else {
            dataModel.addCharFilter(charId)
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

        stageIds: dataModel.filterStageIds
        onStageSelected:{
          if(isSelected) {
            // char is selected -> unselect
            dataModel.removeStageFilter(stageId)
          }
          else {
            dataModel.addStageFilter(stageId)
          }
        }
      }
    }
  }

}
