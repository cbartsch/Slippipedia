import Felgo 3.0

import QtQuick 2.0

import "../controls"
import "../model"

FlickablePage {
  id: basePage

  signal selected

  property ReplayStats stats: null

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
