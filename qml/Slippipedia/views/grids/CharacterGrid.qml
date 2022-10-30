import QtQuick 2.0
import Felgo 4.0

import Slippipedia 1.0

Grid {
  id: characterGrid

  property ReplayStats stats: null

  signal charSelected(int charId, bool isSelected)

  property var charIds: []
  property bool highlightFilteredChar: true
  property bool hideCharsWithNoReplays: false
  property bool sortByCssPosition: true

  property bool showIcon: true
  property bool showData: false
  property bool enableEmpty: true

  property alias sourceModel: jsonModel.source

  readonly property int maxCount: sourceModel ? sourceModel
                                                .map(item => item.count)
                                                .reduce((a, v) => Math.max(a, v), 0)
                                              : 1

  property string toolTipText: ""

  columns: {
    if(showIcon) {
      return 9
      //return width > dp(750) ? 9 : width > dp(250) ? 3 : 1
    }
    else {
      return width / dp(200)
    }
  }
  anchors.left: parent.left
  anchors.right: parent.right

  property Sorter countSorter: RoleSorter {
    roleName: "count"
    ascendingOrder: false
  }

  property Sorter cssSorter: ExpressionSorter {
    expression: {
      var cssIdLeft = MeleeData.charCssIndices[modelLeft.id]
      var cssIdRight = MeleeData.charCssIndices[modelRight.id]

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
        id: jsonModel
        keyField: "id"
        fields: ["id", "count", "name"]
      }
    }

    RippleMouseArea {
      id: charItem

      readonly property bool isSelected: highlightFilteredChar && charIds.indexOf(id) >= 0 // TODO probably use faster lookup
      readonly property bool hasChar: id >= 0 && id < 26 // ids 0-25 are the useable characters

      width: parent.width / parent.columns
      height: showIcon ? charIcon.height : dp(72)
      enabled: hasChar && (enableEmpty || count > 0)
      visible: true
      onClicked: charSelected(id, isSelected)

      hoverEffectEnabled: true
      backgroundColor: Theme.listItem.selectedBackgroundColor
      fillColor: backgroundColor

      CustomToolTip {
        shown: !!toolTipText && charItem.containsMouse
        text: toolTipText ? qsTr(toolTipText).arg(model.count).arg(model.name) : ""
      }

      Rectangle {
        anchors.fill: parent

        z: -1
        color: !charItem.enabled
               ? Theme.backgroundColor
               : isSelected
                 ? Qt.darker(Theme.selectedBackgroundColor, 1.5)
                 : Theme.controlBackgroundColor

        visible: hasChar
      }

      CharacterIcon {
        id: charIcon
        anchors.centerIn: parent
        scale: parent.height / height

        charId: id
        visible: showIcon && hasChar

        opacity: showData
                 ? count === 0 ? 0.1 : (Math.pow(count / maxCount, 0.5) * 0.7 + 0.3)
                 : (!isSelected && charIds.length > 0 ? 0.5 : 1)

        width: Math.min(implicitWidth * 1.5, characterGrid.width / characterGrid.columns)
        height: implicitHeight * width / implicitWidth

        Behavior on opacity { UiAnimation {} }
      }

      Column {
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -height * 0.18
        visible: showData && hasChar && count > 0

        AppText {
          width: parent.width
          text: dataModel.formatPercentage(count / stats.totalReplaysFiltered, 1)
          maximumLineCount: 1
          elide: Text.ElideRight
          horizontalAlignment: Text.AlignHCenter
          style: Text.Outline
          styleColor: Theme.backgroundColor
          font.pixelSize: Math.min(charItem.height * 0.3, width * 0.23)
          font.bold: true

          color: Qt.rgba(1, 1, 1, charIcon.opacity * 0.8 + 0.2)
        }

        AppText {
          width: parent.width
          text: qsTr("%1 game%2").arg(count).arg(count === 1 ? "" : "s")
          maximumLineCount: 1
          elide: Text.ElideRight
          horizontalAlignment: Text.AlignHCenter
          style: Text.Outline
          styleColor: Theme.backgroundColor
          font.pixelSize: Math.min(charItem.height * 0.2, width * 0.17)

          color: Qt.rgba(1, 1, 1, charIcon.opacity * 0.8 + 0.2)
        }
      }
    }
  }
}
