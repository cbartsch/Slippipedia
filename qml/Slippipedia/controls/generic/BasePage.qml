import Felgo 3.0

import QtQuick 2.0

import Slippipedia 1.0

FlickablePage {
  id: basePage

  signal selected

  property ReplayStats stats: null

  property alias filterModal: filterModal

  rightBarItem: LoadingIcon { }

  onAppeared: logPage(title)
  onSelected: logPage(title)

  Binding {
    target: stats ? stats.dataBase.filterSettings : null
    property: "showPunishFilter"
    value: filterModal.showPunishOptions
  }

  FilterModal {
    id: filterModal
    stats: basePage.stats
    page: basePage

    onOpened: logPage("Filtering")
    onClosed: logPage(basePage.title)
  }

  function showFilteringPage() {
    filterModal.open()
  }
}
