import Felgo 3.0

import QtQuick 2.0

BasePage {
  title: qsTr("Replay statistics")

  flickable.contentHeight: content.height

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

      backgroundColor: Theme.backgroundColor
      enabled: false
    }

    AppListItem {
      text: qsTr("Average game time: %1:%2 (%3 frames)")
        .arg(averageGameDurationMinutes)
        .arg(averageGameDurationSeconds)
        .arg(averageGameDuration.toFixed(0))

      backgroundColor: Theme.backgroundColor
      enabled: false
    }

    SimpleSection {
      title: "Player stats"
    }

    AppListItem {
      text: qsTr("Win rate: %1 (%2/%3)")
      .arg(dataModel.formatPercentage(dataModel.winRate))
      .arg(dataModel.totalReplaysFilteredWon).arg(dataModel.totalReplaysFilteredWithResult)

      backgroundColor: Theme.backgroundColor
      enabled: false
      visible: dataModel.hasSlippiCode
    }

    AppListItem {
      text: qsTr("Tie rate: %1 (%2/%3)")
      .arg(dataModel.formatPercentage(dataModel.tieRate))
      .arg(dataModel.totalReplaysFilteredWithTie).arg(dataModel.totalReplaysFiltered)

      backgroundColor: Theme.backgroundColor
      enabled: false
      visible: dataModel.hasSlippiCode
    }

    SimpleSection {
      title: "Top player tags"
    }

    Grid {
      columns: 3
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: dp(Theme.contentPadding)

      Repeater {
        model: dataModel.getTopPlayerTags(18)

        AppText {
          enabled: false
          width: parent.width / 3
          height: dp(48)
          text: qsTr("%1 (%2)").arg(modelData.tag).arg(modelData.count)
          maximumLineCount: 2
          elide: Text.ElideRight
        }
      }
    }
  }
}
