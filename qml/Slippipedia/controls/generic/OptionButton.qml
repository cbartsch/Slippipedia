import QtQuick 2.0
import QtQuick.Controls 2.0
import Felgo 4.0
import Slippipedia 1.0

AppButton {
  id: optionButton
  flat: true
  horizontalPadding: dp(Theme.contentPadding) / 2

  property alias mouseArea: ripple
  property string toolTipText: ""

  CustomToolTip {
    shown: toolTipText && hovered
    text: toolTipText
  }

  Rectangle {
    anchors.fill: parent
    color: ripple.pressed ? Theme.secondaryBackgroundColor : Theme.controlBackgroundColor
    z: -1
  }

  RippleMouseArea {
    id: ripple
    anchors.fill: parent
    hoverEffectEnabled: true
    backgroundColor: Theme.listItem.selectedBackgroundColor
    fillColor: backgroundColor
    opacity: 0.5
    cursorShape: Qt.PointingHandCursor
    onClicked: optionButton.clicked()
  }
}
