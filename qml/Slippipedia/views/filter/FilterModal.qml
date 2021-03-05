import QtQuick 2.0
import Felgo 3.0

import Slippipedia 1.0

AppModal {
  id: filterModal

  property Page page: null
  property ReplayStats stats: null

  pushBackContent: page.navigationStack
  modalHeight: pushBackContent.height * 0.85
  fullscreen: false
  closeOnBackgroundClick: true

  NavigationStack {
    FilterPage {
      stats: filterModal.stats
      height: modal.modalHeight

      leftBarItem: IconButtonBarItem {
        icon: IconType.angleleft
        onClicked: filterModal.close()
      }
    }
  }
}
