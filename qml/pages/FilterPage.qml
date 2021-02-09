import Felgo 3.0

import QtQuick 2.0

BasePage {
  title: qsTr("Filtering")

  flickable.contentHeight: content.height

  Column {
    id: content
    width: parent.width

    SimpleSection {
      title: "Filtering"
    }

    AppListItem {
      text: qsTr("Matched replays: %1/%2 (%3)")
        .arg(dataModel.totalReplaysFiltered)
        .arg(dataModel.totalReplays)
        .arg(dataModel.formatPercentage(dataModel.totalReplaysFiltered / dataModel.totalReplays))

      detailText: qsTr("Matching: %1").arg(dataModel.filterDisplayText)

      backgroundColor: Theme.backgroundColor
      enabled: false
    }

    SimpleSection {
      title: "Player matching"
    }

    AppListItem {
      text: "Enter your Slippi code and/or tag"
      detailText: "Replays are matched based on either your connect code, your in-game tag or both."

      backgroundColor: Theme.backgroundColor
      enabled: false
    }

    Rectangle {
      anchors.left: parent.left
      anchors.right: parent.right
      height: dp(48)
      color: Theme.controlBackgroundColor

      AppTextInput {
        anchors.fill: parent
        anchors.leftMargin: dp(Theme.contentPadding)
        anchors.rightMargin: dp(Theme.contentPadding)
        color: Theme.textColor

        text: dataModel.slippiCode
        placeholderText: "Enter your Slippi code..."

        onTextChanged: dataModel.slippiCode = text
        onAccepted: dataModel.slippiCode = text
      }

      Rectangle {
        width: parent.width
        height: dp(1)
        anchors.bottom: parent.bottom
        color: Theme.dividerColor
      }
    }


    Rectangle {
      anchors.left: parent.left
      anchors.right: parent.right
      height: dp(48)
      color: Theme.controlBackgroundColor

      AppTextInput {
        anchors.fill: parent
        anchors.leftMargin: dp(Theme.contentPadding)
        anchors.rightMargin: dp(Theme.contentPadding)
        color: Theme.textColor

        text: dataModel.slippiName
        placeholderText: "Enter your Slippi name..."

        onTextChanged: dataModel.slippiName = text
        onAccepted: dataModel.slippiName = text
      }

      Rectangle {
        width: parent.width
        height: dp(1)
        anchors.bottom: parent.bottom
        color: Theme.dividerColor
      }
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
      title: "Stage matching"
    }

    AppListItem {
      text: "Filter by specific stage"
      detailText: "Select a stage to limit all stats to that stage. Click again to unselect."

      backgroundColor: Theme.backgroundColor
      enabled: false
    }

    Grid {
      columns: 3
      width: parent.width

      Repeater {
        model: dataModel.stageData

        Rectangle {
          readonly property bool isSelected: dataModel.stageId === modelData.id

          width: parent.width / 3
          height: dp(72)
          color: isSelected ? Theme.selectedBackgroundColor : Theme.controlBackgroundColor

          RippleMouseArea {
            anchors.fill: parent
            onClicked: dataModel.stageId = isSelected ? 0 : modelData.id

            Column {
              width: parent.width
              anchors.verticalCenter: parent.verticalCenter

              AppText {
                enabled: false
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: sp(20)
                text: modelData.shortName
              }

              AppText {
                enabled: false
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("%2 games\n(%3)")
                .arg(dataModel.getStageAmount(modelData.id))
                .arg(dataModel.formatPercentage(dataModel.getStageAmount(modelData.id) / dataModel.totalReplays))
              }
            }
          }
        }
      }
    }

    Rectangle {
      readonly property bool isSelected: dataModel.stageId < 0

      width: parent.width
      height: dp(48)
      color: isSelected ? Theme.selectedBackgroundColor : Theme.controlBackgroundColor

      RippleMouseArea {
        anchors.fill: parent

        onClicked: dataModel.stageId = parent.isSelected ? 0 : -1

        AppText {
          anchors.fill: parent
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
          text: qsTr("Other (%2)")
          .arg(dataModel.formatPercentage(dataModel.totalReplays > 0
          ? dataModel.getOtherStageAmount() / dataModel.totalReplays
          : 0))
        }
      }
    }
  }
}
