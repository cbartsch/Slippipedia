import QtQuick 2.15

import Felgo 4.0

import Slippipedia 1.0

Item {
  property int charId: 0
  readonly property int cssId: charId >= 0 && charId < MeleeData.charCssIndices.length
                               ? MeleeData.charCssIndices[charId]
                               : -1

  visible: cssId >= 0

  implicitWidth: sprite.implicitWidth
  implicitHeight: sprite.implicitHeight

  Image {
    id: sprite

    scale: parent.width / width
    transformOrigin: Item.TopLeft

    source: "../../../../assets/img/css_icon_sheet.png"

    sourceClipRect: Qt.rect(0 + 69 * (cssId % 9),
                            1 + 61 * Math.floor(cssId / 9),
                            66,
                            56)

    anchors.fill: parent
    layer.enabled: true
  }
}
