import QtQuick 2.0
import Felgo 3.0

import Slippipedia 1.0

Column {
  property FilterSettings filter: null

  property bool showPunishFilter: false

  readonly property bool hasFilter: filter && (
                                      filter.playerFilter.hasFilter ||
                                      filter.opponentFilter.hasFilter ||
                                      filter.gameFilter.hasFilter ||
                                      (showPunishFilter ? filter.punishFilter.hasFilter : false)
                                      )

  AppText {
    text: hasFilter ? "Matching:" : "No filter configured."
    color: Theme.secondaryTextColor
  }

  PlayerFilterDescription {
    playerFilter: filter && filter.playerFilter || null
    headingText: "Me:"
  }

  PlayerFilterDescription {
    playerFilter: filter && filter.opponentFilter || null
    headingText: "Opponent:"
  }

  AppText {
    text: filter && filter.gameFilter.displayText || ""
    color: Theme.secondaryTextColor
  }

  AppText {
    visible: showPunishFilter && filter.punishFilter.hasFilter
    text: filter && "Punish: " + filter.punishFilter.displayText || ""
    color: Theme.secondaryTextColor
  }
}
