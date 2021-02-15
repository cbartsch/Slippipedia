import QtQuick 2.13

import Felgo 3.0

import "../model"

Item {
  property int charId: 0
  readonly property int cssId: charId >= 0 && charId < MeleeData.charCssIndices.length
                               ? MeleeData.charCssIndices[charId]
                               : -1

  visible: cssId >= 0

  implicitWidth: sprite.width
  implicitHeight: sprite.height

  SingleSpriteFromSpriteSheet {
    id: sprite

    scale: parent.width / width
    transformOrigin: Item.TopLeft

    source: "../../assets/img/css_icon_sheet.png"

    frameX: 0 + 69 * (cssId % 9)
    frameY: 1 + 61 * Math.floor(cssId / 9)
    frameWidth: 66
    frameHeight: 56
  }
}
