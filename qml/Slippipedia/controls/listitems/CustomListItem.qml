import QtQuick 2.0
import Felgo 4.0
import Slippipedia 1.0

AppListItem {
  id: customListItem

  property bool checked: false
  property bool hasExternalLink: false

  backgroundColor: checked ? Qt.darker(Theme.tintColor, 3) : Theme.backgroundColor

  Behavior on backgroundColor { UiAnimation {} }

  rightItem: Item {
    height: customListItem.height
    width: height
    visible: hasExternalLink

    opacity: customListItem.mouseArea.containsMouse ? 1 : 0

    Behavior on opacity { UiAnimation { } }

    AppIcon {
      iconType: IconType.externallink
      anchors.verticalCenter: parent.verticalCenter
      anchors.right: parent.right
      anchors.margins: dp(Theme.contentPadding)
      size: parent.height * 1/4
    }
  }
}
