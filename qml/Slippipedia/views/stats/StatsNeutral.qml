import QtQuick 2.0
import QtQuick.Layouts 1.12
import Felgo 3.0

import Slippipedia 1.0

Column {
  spacing: dp(Theme.contentPadding) / 2

  AppListItem {
    text: "Stats from all matched games"
    detailText: "Neutral openings by first move per punish."
    enabled: false
    backgroundColor: Theme.backgroundColor
  }

  SimpleSection {
    title: "Opening moves"
  }

  Row {
    width: parent.width

    NeutralColumn {
      title: "My openings"
      model: stats.statsPlayer.openingMoves
    }

    NeutralColumn {
      title: "Opponent's openings"
      model: stats.statsOpponent.openingMoves
    }
  }

  component NeutralRow: RowLayout {
    property string text1: ""
    property string text2: ""
    property string text3: ""
    property string text4: ""
    property color textColor: Theme.textColor
    property color amountColor: Theme.textColor

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: dp(Theme.contentPadding)

    AppText {
      color: textColor
      Layout.preferredWidth: dp(30)
      text: text1
    }

    AppText {
      color: textColor
      Layout.preferredWidth: dp(180)
      text: text2
    }

    AppText {
      color: amountColor
      Layout.preferredWidth: dp(100)
      text: text3
    }

    AppText {
      color: amountColor
      Layout.fillWidth: true
      text: text4
    }
  }

  component NeutralColumn: Column {
    id: neutralColumn
    property var model: ({ })
    property string title: ""

    readonly property real totalOpenings: model.totalCount
    readonly property real mostOpenings: model.openingMoves[0] ? model.openingMoves[0].count : 0

    width: parent.width / 2
    spacing: dp(Theme.contentPadding) / 2

    NeutralRow {
      text2: neutralColumn.title
      text3: "Amount"
      text4: "Percentage"
      textColor: Theme.textColor
      amountColor: Theme.secondaryTextColor
    }

    NeutralRow {
      text2: "Total openings:"
      text3: qsTr("%1").arg(totalOpenings)
    }

    Repeater {
      model: neutralColumn.model.openingMoves

      NeutralRow {
        readonly property real relativeAmount: modelData.count / totalOpenings
        readonly property real relativeToMost: modelData.count / mostOpenings
        readonly property real shade: relativeToMost * 0.4 + 0.6

        text1: qsTr("%1").arg(index + 1)
        text2: qsTr("%1").arg(modelData.moveName)
        text3: qsTr("%1").arg(modelData.count)
        text4: qsTr("%1").arg(dataModel.formatPercentage(relativeAmount))
        amountColor: Qt.hsla(0, 0, shade, 1)
      }
    }
  }

  Item {
    width: parent.width
    height: dp(Theme.contentPadding)
  }
}
