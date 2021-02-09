import Felgo 3.0

import QtQuick 2.0

BasePage {
  title: qsTr("Replay statistics")

  flickable.contentHeight: content.height

  readonly property var stageData: [
    { id: 32, name: "Final Destination", shortName: "FD" },
    { id: 31, name: "Battlefield", shortName: "BF" },
    { id: 3, name: "Pokémon Stadium", shortName: "PS" },
    { id: 28, name: "Dreamland", shortName: "DL" },
    { id: 2, name: "Fountain of Dreams", shortName: "FoD" },
    { id: 8, name: "Yoshi's Story", shortName: "YS" },
  ]

  readonly property real averageGameDuration: dataModel.getAverageGameDuration(dataModel.dbUpdater)
  readonly property int averageGameDurationMinutes: averageGameDuration / 60 / 60
  readonly property int averageGameDurationSeconds: averageGameDuration / 60 % 60

  Column {
    id: content
    width: parent.width

    SimpleSection {
      title: "Replay statistics"
    }

    AppListItem {
      text: qsTr("%1 total replays stored.").arg(dataModel.totalReplays)
      enabled: false
    }

    AppListItem {
      text: qsTr("Average game time: %1:%2 (%3 frames)")
        .arg(averageGameDurationMinutes)
        .arg(averageGameDurationSeconds)
        .arg(averageGameDuration.toFixed(0))
      enabled: false
    }

    SimpleSection {
      title: "Player stats"
    }

    AppListItem {
      text: "Enter your Slippi code to see player stats"
      onSelected: showFilteringPage()
      visible: !dataModel.hasSlippiCodea
    }

    AppListItem {
      text: qsTr("Win rate: %1 (%2/%3)")
      .arg(dataModel.formatPercentage(dataModel.totalReplaysWonByPlayer/dataModel.totalReplaysByPlayerWithResult))
      .arg(dataModel.totalReplaysWonByPlayer).arg(dataModel.totalReplaysByPlayerWithResult)
      enabled: false
      visible: dataModel.hasSlippiCode
    }

    AppListItem {
      text: qsTr("Tie rate: %1 (%2/%3)")
      .arg(dataModel.formatPercentage(dataModel.totalReplaysByPlayerWithTie/dataModel.totalReplaysByPlayer))
      .arg(dataModel.totalReplaysByPlayerWithTie).arg(dataModel.totalReplaysByPlayer)
      enabled: false
      visible: dataModel.hasSlippiCode
    }

    SimpleSection {
      title: "Stage stats"
    }

    Grid {
      columns: 3
      width: parent.width

      Repeater {
        model: stageData

        Rectangle {
          width: parent.width / 3
          height: dp(60)
          color: Theme.controlBackgroundColor

          AppText {
            enabled: false
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("%1\n(%2)")
            .arg(modelData.shortName)
            .arg(dataModel.formatPercentage(dataModel.getStageAmount(modelData.id) / dataModel.totalReplays))
          }
        }
      }
    }

    Rectangle {
      width: parent.width
      height: dp(32)
      color: Theme.controlBackgroundColor

      AppText {
        enabled: false
        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("Other (%2)")
        .arg(dataModel.formatPercentage(dataModel.totalReplays > 0
        ? dataModel.getOtherStageAmount(stageData.map(obj => obj.id)) / dataModel.totalReplays
        : 0))
      }
    }

    SimpleSection {
      title: "Top player tags"
    }

    Repeater {
      model: dataModel.getTopPlayerTags(10)

      AppListItem {
        enabled: false
        text: qsTr("%1 (%2)").arg(modelData.tag).arg(modelData.count)
      }
    }
  }
}
