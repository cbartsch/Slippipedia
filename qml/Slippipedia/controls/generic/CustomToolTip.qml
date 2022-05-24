import QtQuick 2.0
import QtQuick.Controls 2.0

import Felgo 4.0

ToolTip {
  id: toolTip

  padding: dp(Theme.contentPadding)

  background: Rectangle {
    color: Theme.backgroundColor
    radius: dp(Theme.contentPadding)
    border.color: Theme.secondaryBackgroundColor
    border.width: dp(2)
  }



  contentItem: AppText {
    text: toolTip.text
  }
}
