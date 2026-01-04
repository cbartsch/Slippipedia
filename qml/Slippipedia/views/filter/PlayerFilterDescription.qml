import QtQuick 2.0
import Felgo 4.0

import Slippipedia 1.0

Flow {
  property PlayerFilterSettings playerFilter: null

  property alias headingText: heading.text

  visible: playerFilter && playerFilter.hasFilter || false

  spacing: dp(2)

  AppText {
    id: heading
    color: Theme.secondaryTextColor
  }

  AppText {
    text: playerFilter && playerFilter.nameFilterText || ""
    color: Theme.secondaryTextColor
    width: Math.min(implicitWidth, parent.width)
    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
  }

  Item {
    // space
    width: dp(Theme.contentPadding) / 4
    height: 1
  }

  Repeater {
    // for zelda/sheik, insert both IDs to display both icons
    // because it's treated as 1 character for filtering
    model: playerFilter && playerFilter.charIds.reduce(
             (acc, id) => id === 18 || id === 19
             ? acc.concat([18, 19])
             : acc.concat(id),
             []) || []

    StockIcon {
      charId: modelData
    }
  }
}
