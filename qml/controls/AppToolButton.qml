import QtQuick 2.0
import QtQuick.Controls 2.12
import Felgo 3.0

ToolButton {
  id: toolBtn

  property string iconType: ""
  property real size: dp(36)
  property string toolTipText

  flat: true

  checkable: true
  checked: true

  RippleMouseArea {
    anchors.fill: parent
    onPressed: mouse.accepted = false
  }

  hoverEnabled: true

  ToolTip.visible: toolTipText && hovered
  ToolTip.text: toolTipText

  contentItem: Item {
    anchors.fill: parent

    Icon {
      icon: toolBtn.iconType
      visible: !!icon
      anchors.centerIn: parent
    }

    AppText {
      text: toolBtn.text
      visible: !!text
      anchors.fill: parent
      verticalAlignment: Text.AlignVCenter
      horizontalAlignment: Text.AlignHCenter
      color: toolBtn.checked ? Theme.textColor : Theme.secondaryTextColor
      font.pixelSize: toolBtn.size * 0.6
    }
  }

  background: Rectangle {
    implicitWidth: toolBtn.size
    implicitHeight: toolBtn.size
    color: toolBtn.pressed
           ? Theme.selectedBackgroundColor
           : Theme.controlBackgroundColor
  }
}
