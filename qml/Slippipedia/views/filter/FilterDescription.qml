import QtQuick 2.0
import Felgo 3.0

import Slippipedia 1.0

Column {
  property FilterSettings filter: null

  property bool showPunishFilter: false

  readonly property bool hasFilter: filter.playerFilter.hasFilter ||
                                    filter.opponentFilter.hasFilter ||
                                    filter.gameFilter.hasFilter ||
                                    (showPunishFilter ? filter.punishFilter.hasFilter : false)

  AppText {
    text: hasFilter ? "Matching:" : "No filter configured."
    color: Theme.secondaryTextColor
  }

  PlayerFilterDescription {
    playerFilter: filter.playerFilter
    headingText: "Me:"
  }

  PlayerFilterDescription {
    playerFilter: filter.opponentFilter
    headingText: "Opponent:"
  }

  AppText {
    text: filter.gameFilter.displayText
    color: Theme.secondaryTextColor
  }

  AppText {
    visible: showPunishFilter && filter.punishFilter.hasFilter
    text: "Punish: " + filter.punishFilter.displayText
    color: Theme.secondaryTextColor
  }
}
