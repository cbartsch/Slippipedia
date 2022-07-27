import QtQuick 2.0
import Qt5Compat.GraphicalEffects 6.0
import Felgo 4.0

AppTabButton {
  id: tabButton

  Rectangle {
    id: rect

    clip: true
    color: "transparent"
    anchors.fill: parent
    anchors.topMargin: dp(Theme.navigationBar.defaultBarItemPadding) / 2
    anchors.bottomMargin: dp(Theme.navigationBar.defaultBarItemPadding) / 2
    anchors.leftMargin: index === 0 ? dp(Theme.navigationBar.defaultBarItemPadding) : 0
    anchors.rightMargin: index === tabButton.control.count - 1 ? dp(Theme.navigationBar.defaultBarItemPadding) : 0

    radius: dp(7)

    RippleMouseArea {
      id: mouseArea
      anchors.fill: rect
      z: -1

      onPressed: mouse => mouse.accepted = false

      hoverEffectEnabled: true
      backgroundColor: Theme.listItem.selectedBackgroundColor
      fillColor: backgroundColor
      opacity: 0.5
    }
  }

}
