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
        .arg(dataModel.totalReplaysByPlayer)
        .arg(dataModel.totalReplays)
        .arg(dataModel.formatPercentage(dataModel.totalReplaysByPlayer / dataModel.totalReplays))

      detailText: qsTr("Matching %1")
      .arg(dataModel.slippiCode && dataModel.slippiName
      ? qsTr("%1/%2").arg(dataModel.slippiCode).arg(dataModel.slippiName)
      : (dataModel.slippiCode || dataModel.slippiName || "(nothing)"))

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
        anchors.leftMargin: Theme.contentPadding
        anchors.rightMargin: Theme.contentPadding
        color: Theme.textColor

        text: dataModel.slippiCode
        placeholderText: "Enter your Slippi code..."

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
        anchors.leftMargin: Theme.contentPadding
        anchors.rightMargin: Theme.contentPadding
        color: Theme.textColor

        text: dataModel.slippiName
        placeholderText: "Enter your Slippi name..."

        onAccepted: dataModel.slippiName = text
      }

      Rectangle {
        width: parent.width
        height: dp(1)
        anchors.bottom: parent.bottom
        color: Theme.dividerColor
      }
    }
  }
}
