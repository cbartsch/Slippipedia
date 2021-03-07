import QtQuick 2.15

import Felgo 3.0

import Slippipedia 1.0

Item {
  id: stockIcon

  property int charId: 0
  property int skinId: 0
  readonly property point sheetPos: charId >= 0 && charId < MeleeData.stockIconPositions.length
                               ? MeleeData.stockIconPositions[charId]
                               : Qt.point(0, 0)
  readonly property point sheetDist: charId >= 0 && charId < MeleeData.stockIconDistance.length
                               ? MeleeData.stockIconDistance[charId]
                               : Qt.point(0, 0)

  visible: charId >= 0

  implicitWidth: sprite.implicitWidth
  implicitHeight: sprite.implicitHeight

  Image {
    id: sprite

    source: "../../../../assets/img/stock_icon_sheet.png"

    sourceClipRect: Qt.rect(sheetPos.x + skinId * sheetDist.x,
                            sheetPos.y + skinId * sheetDist.y,
                            24, 24)

    anchors.fill: parent

    // disable filtering for pixel art stock icons
    layer.enabled: true
    layer.smooth: false
  }
}
