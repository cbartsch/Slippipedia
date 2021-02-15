import QtQuick 2.0
import Felgo 3.0

IconButtonBarItem {
  icon: IconType.refresh
  visible: dataModel.isProcessing

  RotationAnimation on rotation {
    from: 0
    to: 360
    loops: Animation.Infinite
    running: true
    duration: 2000
  }
}
