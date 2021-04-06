import QtQuick 2.0
import QtGraphicalEffects 1.0
import Felgo 3.0

import Slippipedia 1.0

Row {
  id: stockIcons

  property int charId: 0
  property int skinId: 0

  property int numStocks: 0
  property int stockCount: 4 // game stock count

  Repeater {
    model: stockCount

    Item {
      anchors.verticalCenter: parent.verticalCenter
      width: dp(20)
      height: dp(20)

      StockIcon {
        id: icon
        anchors.fill: parent
        charId: stockIcons.charId
        skinId: stockIcons.skinId
        opacity: numStocks > index ? 1 : 0.25
      }
    }
  }
}
