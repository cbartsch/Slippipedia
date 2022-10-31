import QtQuick 6
import Felgo 4

AppListView {
  id: listView

  Component.onCompleted: {
    for(var i = 0; i < children.length; i++) {
      var item = children[i]

      // this workaround interferes with other MouseArea's cursorShapes
      // -> set the contained MouseArea cursorShape to undefined instead
      if((item + "").indexOf("DesktopScrollHelper") >= 0) {
        item.item.cursorShape = undefined
      }
    }
  }
}
