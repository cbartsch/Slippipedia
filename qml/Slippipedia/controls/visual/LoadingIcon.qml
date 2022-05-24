import QtQuick 2.0
import Felgo 4.0

IconButtonBarItem {
  icon: IconType.spinner
  visible: dataModel.isProcessing
  enabled: false

  RotationAnimation on rotation {
    from: 0
    to: 360
    loops: Animation.Infinite
    running: true
    duration: 2000
  }

  AppText {
    anchors.centerIn: parent
    text: qsTr("%1%").arg(Math.round(100 * dataModel.numFilesProcessed / dataModel.numFilesProcessing))
    rotation: -parent.rotation
    font.pixelSize: sp(12)
    style: Text.Outline
    styleColor: Theme.backgroundColor
    opacity: 0.8
  }
}
