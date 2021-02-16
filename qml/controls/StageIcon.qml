import QtQuick 2.13

import Felgo 3.0

import "../model"

Item {
  id: stageIcon

  property int stageId: 0
  // dreamland has a smaller icon with different coordinates
  readonly property bool isSmallIcon: stageId === 28

  readonly property int cssId: stageId && stageId > 0
                               && (MeleeData.stageMap[stageId] || {}).sssIndex
                               || -1


  implicitWidth: sprite.width
  implicitHeight: sprite.height

  SingleSpriteFromSpriteSheet {
    id: sprite

    visible: cssId >= 0

 //   anchors.centerIn: parent

    source: "../../assets/img/sss_icon_sheet.png"

    frameX:      isSmallIcon ? 1   : 2 + 65 * (cssId % 9)
    frameY:      isSmallIcon ? 172 : 2 + 57 * Math.floor(cssId / 9)
    frameWidth:  isSmallIcon ? 48  : 62
    frameHeight: isSmallIcon ? 48  : 54

    transform: Scale {
      xScale: stageIcon.width / sprite.width
      yScale: stageIcon.height / sprite.height
    }
  }
}
