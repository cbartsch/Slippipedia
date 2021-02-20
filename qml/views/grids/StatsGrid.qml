import QtQuick 2.0
import QtQuick.Layouts 1.12
import Felgo 3.0

Column {
  id: statsGrid

  property alias title: title.title

  property var rowData: []
  property var statsList: []

  readonly property int numDataColumns: statsList.length
  readonly property real colWidthTitle: dp(220)
  readonly property real colWidthData: (headerRow.width - colWidthTitle - dp(Theme.contentPadding)) / numDataColumns

  spacing: dp(Theme.contentPadding) / 2

  SimpleSection {
    id: title
    title: "Tech skill stats"
  }

  RowLayout {
    id: headerRow
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: dp(Theme.contentPadding)

    AppText {
      text: "Stat"
      color: Theme.secondaryTextColor
      Layout.preferredWidth: colWidthTitle
    }

    AppText {
      Layout.minimumWidth: colWidthData
      horizontalAlignment: Text.AlignRight
      text: dataModel.playerFilter.hasPlayerFilter ? "Me" : "Player"
      color: Theme.secondaryTextColor
    }

    AppText {
      Layout.minimumWidth: colWidthData
      horizontalAlignment: Text.AlignRight
      text: "Opponent"
      color: Theme.secondaryTextColor
      visible: dataModel.playerFilter.hasPlayerFilter
    }
  }

  Repeater {
    model: rowData

    RowLayout {
      readonly property var rowModel: modelData

      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: dp(Theme.contentPadding)

      AppText {
        Layout.preferredWidth: colWidthTitle
        text: rowModel.header
      }

      Repeater {
        model: dataModel.playerFilter.hasPlayerFilter ? statsList : statsList.slice(0, 1)

        AppText {
          readonly property var stats: modelData
          readonly property var value: stats[rowModel.property]
          readonly property var displayText: {
            switch(rowModel.type) {
            case "percentage": return dataModel.formatPercentage(value)
            case "decimal": return value.toFixed(2)
            default: return dataModel.formatNumber(value)
            }
          }

          Layout.minimumWidth: colWidthData
          horizontalAlignment: Text.AlignRight
          text: displayText
        }
      }
    }
  }
}
