import QtQuick 2.0
import QtQuick.Controls 2.12 as QQ
import Felgo 3.0

import Slippipedia 1.0

Column {
  id: gameFilterOptions

  property ReplayStats stats: null
  readonly property GameFilterSettings filter: stats ? stats.dataBase.filterSettings.gameFilter : null

  readonly property var dateFormats: [
    "dd/MM/yyyy hh:mm", "dd/MM/yyyy",
    "dd.MM.yyyy hh:mm", "dd.MM.yyyy",
  ]

  SimpleSection {
    title: "Date range"
  }

  CustomListItem {
    text: "Filter by replay date"
    detailText: "Select a date range to match replays in."

    checked: filter ? filter.hasDateFilter : false
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      toolTipText: "Reset stage filter"
      visible: filter ? filter.hasDateFilter : false
      anchors.verticalCenter: parent.verticalCenter

      onClicked: clearDateRange()
    }
  }

  Item {
    width: parent.width
    height: dateOptionsRow.height

    Flow {
      id: dateOptionsRow
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: spacing
      spacing: dp(Theme.contentPadding)

      DateRangeRow {
        numDays: 1
        onSetPastRange: gameFilterOptions.setPastRange(numDays)
        onAddDateRange: gameFilterOptions.addDateRange(numDays)
      }

      DateRangeRow {
        numDays: 7
        onSetPastRange: gameFilterOptions.setPastRange(numDays)
        onAddDateRange: gameFilterOptions.addDateRange(numDays)
      }

      DateRangeRow {
        numDays: 30
        onSetPastRange: gameFilterOptions.setPastRange(numDays)
        onAddDateRange: gameFilterOptions.addDateRange(numDays)
      }

      DateRangeRow {
        numDays: 365
        onSetPastRange: gameFilterOptions.setPastRange(numDays)
        onAddDateRange: gameFilterOptions.addDateRange(numDays)
      }
    }
  }

  RangeOptions {
    id: dateOptions

    label.text: "Date:"
    labelWidth: dp(100)

    range: filter && filter.date

    textFunc: dateText
    valueFunc: dateValue
    validationText: qsTr("Enter date in format \"%1\"").arg(dateFormats[0])
  }

  SimpleSection {
    title: "Stage"
  }

  CustomListItem {
    text: "Filter by specific stage"
    detailText: "Select a stage to limit all stats to that stage. Click again to unselect."

    checked: filter ? filter.hasStageFilter : false
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      toolTipText: "Reset stage filter"
      visible: filter ? filter.hasStageFilter : false
      anchors.verticalCenter: parent.verticalCenter

      onClicked: filter.removeAllStages()
    }
  }

  StageGrid {
    width: parent.width

    sourceModel: stats && stats.stageDataSss || []
    stats: gameFilterOptions.stats

    hideStagesWithNoReplays: false
    sortByCount: false
    showIcon: true
    showData: false
    showOtherItem: false

    stageIds: filter ? filter.stageIds : []
    onStageSelected: {
      if(isSelected) {
        // char is selected -> unselect
        filter.removeStage(stageId)
      }
      else {
        filter.addStage(stageId)
      }
    }
  }

  SimpleSection {
    title: "Game properties"
  }

  CustomListItem {
    text: "Game flags"
    detailText: "Match only games with specific user flags."

    checked: filter ? filter.hasUserFlagFilter : false
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.trash
      toolTipText: "Remove game flag filter"
      visible: filter ? filter.hasUserFlagFilter : false
      anchors.verticalCenter: parent.verticalCenter

      onClicked: filter.userFlagMask = 0
    }
  }

  Item {
    width: parent.width
    height: userFlagFlow.height

    Flow {
      id: userFlagFlow
      width: parent.width
      spacing: dp(1)

      Item {
        height: dp(48)
        width: userFlagText.width + dp(Theme.contentPadding) * 2

        AppText {
          id: userFlagText
          text: "Game flags:"
          anchors.centerIn: parent
        }
      }

      Repeater {
        model: dataModel.userFlagNames

        Rectangle {
          readonly property int flagId: index + 1
          readonly property string flagName: modelData

          height: dp(48)
          width: flagCheckBox.width + dp(Theme.contentPadding) * 3 + flagIcon.width

          color: Theme.controlBackgroundColor

          AppCheckBox {
            id: flagCheckBox
            text: flagName
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: dp(Theme.contentPadding)

            checked: filter ? dataModel.hasFlag(filter.userFlagMask, flagId) : false
          }

          Icon {
            id: flagIcon
            anchors.right: parent.right
            anchors.rightMargin: dp(Theme.contentPadding)
            anchors.verticalCenter: parent.verticalCenter
            icon: IconType.star
            color: flagCheckBox.checked ? Theme.tintColor : Theme.textColor

            Behavior on color { UiAnimation { } }
          }

          RippleMouseArea {
            anchors.fill: parent
            hoverEffectEnabled: true
            backgroundColor: Theme.listItem.selectedBackgroundColor
            fillColor: backgroundColor
            opacity: 0.5

            onClicked: filter.userFlagMask = dataModel.setFlag(filter.userFlagMask, flagId, !flagCheckBox.checked)
          }
        }
      }
    }
  }

  SimpleSection {
    title: "Other options"
  }

  CustomListItem {
    text: "Session split interval"
    detailText: "Split sessions against the same opponent after certain amount of time."

    // not technically a filter, so do not show it as "enabled"
    checked: false // filter ? filter.hasSessionSplitInterval : false
    mouseArea.enabled: false

    rightItem: AppToolButton {
      iconType: IconType.refresh
      toolTipText: qsTr("Reset session split interval to default (%1)")
                   .arg(dataModel.formatTimeMs(filter ? filter.sessionSplitIntervalMsDefault : 0))
      visible: filter ? filter.hasSessionSplitInterval : false
      anchors.verticalCenter: parent.verticalCenter

      onClicked: filter.sessionSplitIntervalMs = filter.sessionSplitIntervalMsDefault
    }
  }

  TextInputField {
    labelText: "Interval (hh:mm:ss)"
    labelWidth: dp(240)
    showOptions: false

    text: filter && filter.sessionSplitIntervalMs > 0 ? dataModel.formatTimeMs(filter.sessionSplitIntervalMs, false) : ""
    placeholderText: "Never split sessions"

    readonly property var value: text ? dataModel.parseTime(text) : null

    validationError: value >= 0
    validationText: qsTr("Enter time in format \"%1\"").arg("mm:ss")

    onTextChanged: {
      if(!filter) {
        return
      }

      if(text.length === 0) {
        filter.sessionSplitIntervalMs = 0
        return
      }

      if(value >= 0) {
        filter.sessionSplitIntervalMs = value
      }
    }
  }

  function setPastRange(numDays) {
    filter.setPastRange(numDays)

    updateTexts()
  }

  function addDateRange(numDays) {
    filter.addDateRange(numDays)

    updateTexts()
  }

  function clearDateRange() {
    filter.date.reset()

    updateTexts()
  }

  function updateTexts() {
    dateOptions.inputFrom.text = Qt.binding(() => dateText(filter.date.from))
    dateOptions.inputTo.text = Qt.binding(() => dateText(filter.date.to))
  }

  function dateText(dateMs) {
     return dateMs < 0 ? "" : dataModel.formatDate(new Date(dateMs))
  }

  function dateValue(text, input) {
    if(text === "") {
      return -1
    }

    var date
    for(var i = 0; i < dateFormats.length && !isDateValid(date); i++) {
      date = Date.fromLocaleString(Qt.locale(), text, dateFormats[i])
    }

    if(!isDateValid(date)) {
      // text entered but no valid date - do not change value
      return undefined
    }

    input.text = text // break binding to not re-format the date

    return date.getTime()
  }
}
