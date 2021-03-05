import QtQuick 2.0
import Felgo 3.0

import "../visual"

NavigationStack {
  id: stack

  splitView: useSplitMode
  leftColumnWidth:  depth > 1 ? splitPaneWidth : width

  navigationBar.backButtonVisible: splitView || depth > 1

  Behavior on leftColumnWidth {
    UiAnimation { }
  }
}
