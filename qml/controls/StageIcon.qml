import QtQuick 2.13

import Felgo 3.0

import "../model"

SingleSpriteFromSpriteSheet {
  property int stageId: 0
  // dreamland has a smaller icon with different coordinates
  readonly property bool isSmallIcon: stageId === 28

  readonly property int cssId: stageId > 0
                               ? MeleeData.stageMap[stageId].sssIndex
                               : -1

  visible: cssId >= 0
  source: "../../assets/img/sss_icon_sheet.png"

  frameX:      isSmallIcon ? 1   : 2 + 65 * (cssId % 9)
  frameY:      isSmallIcon ? 172 : 2 + 57 * Math.floor(cssId / 9)
  frameWidth:  isSmallIcon ? 48  : 62
  frameHeight: isSmallIcon ? 48  : 54
}
