import Felgo

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Slippipedia

FlickablePage {
  id: basePage

  signal selected

  property ReplayStats stats: null

  property alias filterModal: filterModal

  // find attached StackLayout object where the page is contained in the Navigation to access tab index
  readonly property QtObject stackLayout: {
    for(var item = basePage; item.parent !== null; item = item.parent) {
      if(item.StackLayout.index >= 0) {
        return item.StackLayout
      }
    }
  }

  rightBarItem: LoadingIcon { }

  onAppeared: logPage(title)
  onSelected: logPage(title)

  FilterModal {
    id: filterModal
    stats: basePage.stats
    page: basePage

    onOpened: logPage("Filtering")
    onClosed: logPage(basePage.title)
  }

  function showFilteringPage(tabIndex) {
    if(typeof tabIndex === "number") {
      filterModal.showTab(tabIndex)
    }

    filterModal.open()
  }
}
