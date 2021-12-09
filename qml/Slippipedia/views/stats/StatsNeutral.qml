import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.15
import Felgo 3.0

import Slippipedia 1.0

Column {
  spacing: dp(Theme.contentPadding) / 2

  readonly property var emptyModel: ({ openingMoves: [] })

  AppListItem {
    text: "Stats from all matched games"
    detailText: "Neutral openings by first move per punish."
    enabled: false
    backgroundColor: Theme.backgroundColor
  }

  Grid {
    anchors.left: parent.left
    anchors.right: parent.right

    columns: width > dp(1100) ? 2 : 1

    NeutralColumn {
      title: "My openings"
      model: stats.statsPlayer.openingMoves || emptyModel
      width: parent.width / parent.columns
    }

    NeutralColumn {
      title: "Opponent's openings"
      model: stats.statsOpponent.openingMoves || emptyModel
      width: parent.width / parent.columns
    }
  }

  component NeutralRow: RowLayout {
    property string text1: ""
    property string text2: ""
    property string text3: ""
    property string text4: ""
    property string text5: ""
    property string text6: ""
    property string text7: ""
    property string toolTipText1: ""
    property string toolTipText2: ""
    property string toolTipText3: ""
    property string toolTipText4: ""
    property string toolTipText5: ""
    property string toolTipText6: ""
    property string toolTipText7: ""
    property color textColor: Theme.textColor
    property color amountColor: Theme.textColor

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: dp(Theme.contentPadding)

    AppToolText {
      color: textColor
      Layout.preferredWidth: dp(30)
      text: text1
      toolTipText: toolTipText1
    }

    AppToolText {
      color: textColor
      Layout.fillWidth: true
      text: text2
      toolTipText: toolTipText2
    }

    AppToolText {
      color: amountColor
      Layout.preferredWidth: dp(80)
      horizontalAlignment: Text.AlignRight
      text: text3
      toolTipText: toolTipText3
    }

    AppToolText {
      color: amountColor
      Layout.preferredWidth: dp(80)
      horizontalAlignment: Text.AlignRight
      text: text4
      toolTipText: toolTipText4
    }

    AppToolText {
      color: amountColor
      Layout.preferredWidth: dp(80)
      horizontalAlignment: Text.AlignRight
      text: text5
      toolTipText: toolTipText5
    }

    AppToolText {
      color: amountColor
      Layout.preferredWidth: dp(80)
      horizontalAlignment: Text.AlignRight
      text: text6
      toolTipText: toolTipText6
    }

    AppToolText {
      color: amountColor
      Layout.preferredWidth: dp(80)
      horizontalAlignment: Text.AlignRight
      text: text7
      toolTipText: toolTipText7
    }
  }

  component NeutralColumn: Column {
    id: neutralColumn
    property var model: emptyModel
    property string title: ""

    readonly property real totalOpenings: model.totalCount || 0
    readonly property real mostOpenings: model.openingMoves[0] && model.openingMoves[0].count || 0

    spacing: dp(Theme.contentPadding) / 2

    SimpleSection {
      title: neutralColumn.title
    }

    NeutralRow {
      text3: "Amount"
      toolTipText3: "Total punishes opened with this move"
      text4: "%"
      toolTipText4: "Percentage of punishes opened with this move"
      text5: "Avg. damage"
      toolTipText5: "Average damage per punish opened with this move"
      text6: "Avg. # moves"
      toolTipText6: "Average number of moves per punish opened with this move"
      text7: "% killed"
      toolTipText7: "Percentage of punishes opened with this move that lead to a kill"
      textColor: Theme.textColor
      amountColor: Theme.secondaryTextColor
    }

    NeutralRow {
      text2: "Total openings:"
      text3: qsTr("%1").arg(totalOpenings)
      text4: ""
      text5: qsTr("%1").arg(dataModel.formatNumber(model.avgDamage))
      text6: qsTr("%1").arg(dataModel.formatNumber(model.avgNumMoves))
      text7: qsTr("%1").arg(dataModel.formatPercentage(model.killRate))
    }

    Repeater {
      // skip grab related attacks (pummel, throws), they are grouped under the grab item
      model: neutralColumn.model.openingMoves.filter(_ => !_.isGrab)

      NeutralRow {
        readonly property bool useShortName: width < dp(600)

        readonly property real relativeAmount: modelData.count / totalOpenings
        readonly property real relativeToMost: modelData.count / mostOpenings
        readonly property real shade: 1//relativeToMost * 0.4 + 0.6

        text1: qsTr("%1").arg(index + 1)
        text2: (useShortName ? modelData.moveNameShort : modelData.moveName) || ""
        toolTipText2: useShortName ? modelData.moveName : ""
        text3: qsTr("%1").arg(modelData.count)
        text4: qsTr("%1").arg(dataModel.formatPercentage(relativeAmount))
        text5: qsTr("%1").arg(dataModel.formatNumber(modelData.avgDamage))
        text6: qsTr("%1").arg(dataModel.formatNumber(modelData.avgNumMoves))
        text7: qsTr("%1").arg(dataModel.formatPercentage(modelData.killRate))
        amountColor: Qt.hsla(0, 0, shade, 1)
      }
    }
  }

  Item {
    width: parent.width
    height: dp(Theme.contentPadding)
  }
}
