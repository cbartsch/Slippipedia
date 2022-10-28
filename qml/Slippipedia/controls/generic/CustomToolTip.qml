import QtQuick 2.0
import QtQuick.Controls 2.0

import Felgo 4.0
import Slippipedia 1.0

ToolTip {
  id: toolTip

  property bool shown: false

  onShownChanged: if(shown) open(); else close()

  padding: dp(Theme.contentPadding)

  background: Rectangle {
    color: Theme.backgroundColor
    radius: dp(Theme.contentPadding)
    border.color: Theme.secondaryBackgroundColor
    border.width: dp(2)
  }

  contentItem: AppText {
    text: toolTip.text
    wrapMode: Text.NoWrap
  }

  enter: Transition {
    UiAnimation { property: "opacity"; from: 0; to: 1 }
  }

  exit: Transition {
    UiAnimation { property: "opacity"; from: 1; to: 0 }
  }

}
