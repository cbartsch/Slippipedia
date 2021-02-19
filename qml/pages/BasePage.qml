import Felgo 3.0

import QtQuick 2.0

import "../views/controls"
import "../views/visual"
import "../model/stats"

FlickablePage {
  id: basePage

  signal selected

  property ReplayStats stats: null

  property alias filterModal: filterModal

  rightBarItem: LoadingIcon { }

  FilterModal {
    id: filterModal
    stats: basePage.stats
    page: basePage
  }

  function showFilteringPage() {
    filterModal.open()
  }
}
