import QtQuick 2.0
import Felgo 3.0
import Slippipedia 1.0

AppListItem {
  property bool checked: false

  backgroundColor: checked ? Qt.darker(Theme.tintColor, 3) : Theme.backgroundColor

  Behavior on backgroundColor { UiAnimation {} }
}
