import QtQuick 2.15

import Felgo 4.0

import Slippipedia 1.0

Item {
  id: stageIcon

  property int stageId: 0
  // dreamland has a smaller icon with different coordinates
  readonly property bool isSmallIcon: stageId === 28

  readonly property int cssId: stageId && stageId > 0
                               && (MeleeData.stageMap[stageId] || {}).sssIndex
                               || -1


  implicitWidth: sprite.implicitWidth
  implicitHeight: sprite.implicitHeight

  Image {
    id: sprite

    visible: cssId >= 0

 //   anchors.centerIn: parent

    source: "../../../../assets/img/sss_icon_sheet.png"

    sourceClipRect: Qt.rect(isSmallIcon ? 1   : 2 + 65 * (cssId % 9),
                            isSmallIcon ? 172 : 2 + 57 * Math.floor(cssId / 9),
                            isSmallIcon ? 48  : 62,
                            isSmallIcon ? 48  : 54)

    anchors.fill: parent
    layer.enabled: true
  }
}
