import QtQuick 2.0
import Felgo 3.0

import "../model"

Grid {
  id: characterGrid

  signal charSelected(int charId, bool isSelected)

  property int charId
  property bool highlightFilteredChar: true
  property bool hideCharsWithNoReplays: false
  property bool sortByCssPosition: true

  property bool showIcon: true
  property bool showData: false

  columns: {
    if(showIcon) {
      return width > dp(750) ? 9 : width > dp(250) ? 3 : 1
    }
    else {
      return width / dp(200)
    }
  }
  anchors.left: parent.left
  anchors.right: parent.right

  property var md: MeleeData

  property Sorter countSorter: RoleSorter {
    roleName: "count"
    ascendingOrder: false
  }

  property Sorter cssSorter: ExpressionSorter {
    expression: {
      var cssIdLeft = md.charCssIndices[modelLeft.id]
      var cssIdRight = md.charCssIndices[modelRight.id]

      return cssIdRight < cssIdLeft
    }

    ascendingOrder: false
  }

  property Filter emptyFilter: ExpressionFilter {
    expression: count > 0
  }

  Repeater {
    id: repeater
    model: SortFilterProxyModel {
      filters: hideCharsWithNoReplays ? [emptyFilter] : []
      sorters: [sortByCssPosition ? cssSorter : countSorter]

      sourceModel: JsonListModel {
        source: dataModel.charDataCss
        keyField: "id"
        fields: ["id", "count", "name"]
      }
    }

    RippleMouseArea {
      id: charItem

      readonly property bool isSelected: highlightFilteredChar && charId === id
      readonly property bool hasChar: id >= 0 && id < 26 // ids 0-25 are the useable characters

      width: parent.width / parent.columns
      height: dp(72)
      enabled: hasChar
      visible: true
      onClicked: charSelected(id, isSelected)

      Rectangle {
        anchors.fill: parent

        color: !enabled
               ? Theme.backgroundColor
               : isSelected
                 ? Theme.selectedBackgroundColor
                 : Theme.controlBackgroundColor

        visible: hasChar
      }

      CharacterIcon {
        anchors.centerIn: parent
        scale: parent.height / height

        charId: id
        visible: showIcon && hasChar
      }

      Column {
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        visible: showData

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
