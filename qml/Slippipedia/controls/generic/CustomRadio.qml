import QtQuick 2.0
import Felgo 3.0

AppRadio {
  id: customRadio

  leftPadding: dp(Theme.contentPadding)
  rightPadding: dp(Theme.contentPadding)

  Rectangle {
    anchors.fill: parent
    color: Theme.controlBackgroundColor
    z: -1
  }

  RippleMouseArea {
    anchors.fill: parent
    hoverEffectEnabled: true
    backgroundColor: Theme.listItem.selectedBackgroundColor
    fillColor: backgroundColor
    opacity: 0.5
    onClicked: customRadio.checked = !customRadio.checked
    z: -1
  }
}
