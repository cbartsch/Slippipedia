import QtQuick 2.0
import Felgo 3.0

import Slippipedia 1.0

NavigationStack {
  id: stack

  splitView: depth > 1 && useSplitMode
  leftColumnWidth: splitPaneWidth

  navigationBar.backButtonVisible: splitView || depth > 1
}
