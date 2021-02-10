import QtQuick 2.0
import Felgo 3.0

Grid {
  id: characterGrid

  signal charSelected(int charId, bool isSelected)

  property int charId
  property bool highlightFilteredChar: true

  columns: Math.round(width / dp(200))
  anchors.left: parent.left
  anchors.right: parent.right


  Repeater {
    model: SortFilterProxyModel {
      filters: ExpressionFilter {
        expression: count > 0
      }

      sorters: [
        RoleSorter {
          roleName: "count"
          ascendingOrder: false
        }
      ]

      sourceModel: JsonListModel {
        source: dataModel.charData
        keyField: "id"
      }
    }

    Rectangle {
      id: charItem

      visible: id < 26 // ids 0-25 are the useabls characters
      width: parent.width / parent.columns
      height: dp(72)

      readonly property bool isSelected: highlightFilteredChar && charId === id

      color: !enabled
             ? Theme.backgroundColor
             : isSelected
               ? Theme.selectedBackgroundColor
               : Theme.controlBackgroundColor

      RippleMouseArea {
        anchors.fill: parent
        onClicked: charSelected(id, charItem.isSelected)

        Column {
          width: parent.width
          anchors.verticalCenter: parent.verticalCenter

          AppText {
            width: parent.width
            text: name
            maximumLineCount: 1
            elide: Text.ElideRight
            font.pixelSize: sp(20)
            horizontalAlignment: Text.AlignHCenter
          }

          AppText {
            width: parent.width
            text: qsTr("%1 games\n%2").arg(count).arg(dataModel.formatPercentage(count / dataModel.totalReplaysFiltered))
            maximumLineCount: 2
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
          }
        }
      }
    }
  }
}
