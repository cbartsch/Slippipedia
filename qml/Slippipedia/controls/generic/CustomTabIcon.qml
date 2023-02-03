import QtQuick 2.0
import Felgo 4.0

Item {
  anchors.fill: parent

  property string badgeValue: ""
  property bool selected: false
  property alias iconType: icon.iconType

  AppIcon {
    id: icon
    iconType: IconType.database
    size: parent.height
    anchors.centerIn: parent
    color: selected ? Theme.navigationTabBar.titleColor : Theme.navigationTabBar.titleOffColor
  }

  Rectangle {
    anchors.left: parent.right
    anchors.top: parent.top
    anchors.topMargin: -height / 4
    anchors.leftMargin: dp(4)
    visible: !!badgeValue
    color: Theme.secondaryBackgroundColor
    width: row.width + dp(8)
    height: dp(20)
    radius: height / 2

    Row {
      id: row
      anchors.centerIn: parent
      spacing: dp(4)

      AppIcon {
        iconType: IconType.plus
        anchors.verticalCenter: parent.verticalCenter
        size: dp(12)
        color: Theme.tintColor
      }

      AppText {
        text: badgeValue
        color: Theme.tintColor
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: sp(12)
      }
    }
  }
}
