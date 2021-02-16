import QtQuick 2.13

import Felgo 3.0

import "../model"

SingleSpriteFromSpriteSheet {
  property int charId: 0
  property int skinId: 0
  readonly property point sheetPos: charId >= 0 && charId < MeleeData.stockIconPositions.length
                               ? MeleeData.stockIconPositions[charId]
                               : Qt.point(0, 0)
  readonly property point sheetDist: charId >= 0 && charId < MeleeData.stockIconDistance.length
                               ? MeleeData.stockIconDistance[charId]
                               : Qt.point(0, 0)

  visible: charId >= 0
  source: "../../assets/img/stock_icon_sheet.png"

  frameX: sheetPos.x + skinId * sheetDist.x
  frameY: sheetPos.y + skinId * sheetDist.y
  frameWidth: 24
  frameHeight: 24
}
