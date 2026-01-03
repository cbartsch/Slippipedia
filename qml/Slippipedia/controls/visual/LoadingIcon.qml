import QtQuick 2.0
import Felgo 4.0

IconButtonBarItem {
  iconType: IconType.spinner
  visible: dataModel.hasProgress
  enabled: false
  mouseArea.hoverEnabled: false

  property alias textItem: textItem

  RotationAnimation on rotation {
    from: 0
    to: 360
    loops: Animation.Infinite
    running: true
    duration: 2000
  }

  AppText {
    id: textItem
    anchors.centerIn: parent
    text: qsTr("%1%").arg(Math.round(100 * dataModel.totalProgress))
    rotation: -parent.rotation
    font.pixelSize: sp(12)
    style: Text.Outline
    styleColor: Theme.backgroundColor
    opacity: 0.8
  }
}
