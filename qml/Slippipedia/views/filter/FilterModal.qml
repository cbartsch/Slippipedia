import QtQuick 2.0
import Felgo 4.0

import Slippipedia 1.0

AppModal {
  id: filterModal

  property AppPage page: null
  property ReplayStats stats: null

  property bool showPunishOptions: false

  pushBackContent: page.navigationStack
  modalHeight: pushBackContent.height * 0.85
  fullscreen: false
  closeOnBackgroundClick: true

  NavigationStack {
    FilterPage {
      id: filterPage

      stats: filterModal.stats
      height: filterModal.modalHeight

      showPunishOptions: filterModal.showPunishOptions

      leftBarItem: IconButtonBarItem {
        iconType: IconType.angleleft
        onClicked: filterModal.close()
      }

      // put a mouse area "behind" the page, to prevent hover effects for items underneath the modal (tooltips would show up)
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        z: -1
      }
    }
  }

  function showTab(index) {
    filterPage.showTab(index)
  }
}
