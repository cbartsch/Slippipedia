import QtQuick 2.0
import QtQuick.Controls 2.12
import Felgo 3.0

AppRadio {
  id: customRadio

  property string toolTipText: ""

  leftPadding: dp(Theme.contentPadding)
  rightPadding: dp(Theme.contentPadding)

  ToolTip.visible: toolTipText && (hovered || mouseArea.containsMouse)
  ToolTip.text: toolTipText

  Rectangle {
    anchors.fill: parent
    color: Theme.controlBackgroundColor
    z: -1
  }

  RippleMouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEffectEnabled: true
    backgroundColor: Theme.listItem.selectedBackgroundColor
    fillColor: backgroundColor
    opacity: 0.5
    onClicked: customRadio.checked = !customRadio.checked
    z: -1
  }
}
