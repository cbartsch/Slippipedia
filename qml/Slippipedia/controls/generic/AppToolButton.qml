import QtQuick 2.0
import QtQuick.Controls 2.12
import Felgo 4.0

import Slippipedia 1.0

ToolButton {
  id: toolBtn

  property string iconType: ""
  property alias iconItem: iconItem
  property real size: dp(36)
  property string toolTipText

  property alias mouseArea: mouseArea

  flat: true

  RippleMouseArea {
    id: mouseArea

    anchors.fill: parent
    onPressed: mouse => mouse.accepted = false

    hoverEffectEnabled: true
    backgroundColor: Theme.listItem.selectedBackgroundColor
    fillColor: backgroundColor
    opacity: 0.5
  }

  hoverEnabled: true

  CustomToolTip {
    visible: toolTipText && hovered
    text: toolTipText
  }

  contentItem: Item {
    anchors.fill: parent

    Icon {
      id: iconItem
      icon: toolBtn.iconType
      visible: !!icon
      anchors.centerIn: parent
      color: toolBtn.checked ? Theme.tintColor : Theme.textColor

      Behavior on color { UiAnimation { } }
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
