import QtQuick 6
import Felgo 4

AppListView {
  Component.onCompleted: {
    for(var i = 0; i < children.length; i++) {
      var item = children[i]

      // this workaround interfers with other MouseArea's cursorShapes - disable it (it is a Loader)
      if((item + "").indexOf("DesktopScrollHelper") >= 0) {
        item.active = false
      }
    }
  }
}
