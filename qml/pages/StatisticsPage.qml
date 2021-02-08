import Felgo 3.0

import QtQuick 2.0

BasePage {
  title: qsTr("Replay statistics")

  flickable.contentHeight: content.height

  readonly property var stageData: [
    { id: 32, name: "Final Destination" },
    { id: 31, name: "Battlefield" },
    { id: 3, name: "Pokémon Stadium" },
    { id: 28, name: "Dreamland" },
    { id: 2, name: "Fountain of Dreams" },
    { id: 8, name: "Yoshi's Story" },
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
      title: "Stages"
    }

    Repeater {
      model: stageData

      AppListItem {
        enabled: false
        text: qsTr("%1 (%2)")
        .arg(modelData.name)
        .arg(dataModel.formatPercentage(dataModel.totalReplays > 0
        ? dataModel.getStageAmount(modelData.id) / dataModel.totalReplays
        : 0))
      }
    }

    AppListItem {
      enabled: false
      text: qsTr("Other (%2)")
      .arg(dataModel.formatPercentage(dataModel.totalReplays > 0
      ? dataModel.getOtherStageAmount(stageData.map(obj => obj.id)) / dataModel.totalReplays
      : 0))
    }

    SimpleSection {
      title: "Top player tags"
    }

    Repeater {
      model: dataModel.getTopWinnerTags(10)

      AppListItem {
        enabled: false
        text: qsTr("%1 (%2)").arg(modelData.tag).arg(modelData.count)
      }
    }
  }
}
