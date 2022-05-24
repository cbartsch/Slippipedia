import QtQuick 2.0
import Felgo 4.0

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

  Row {
    visible: filter && filter.gameFilter.hasUserFlagFilter || false
    spacing: dp(4)

    AppText {
      text: "Game flags:"
      color: Theme.secondaryTextColor
      anchors.bottom: parent.bottom
    }

    Repeater {
      model: filter
             && dataModel.userFlagNames.filter(
               (f, id) => dataModel.hasFlag(filter.gameFilter.userFlagMask, id + 1))
             || []

      Row {
        anchors.bottom: parent.bottom
        spacing: dp(4)
        height: flagText.height

        Icon {
          anchors.bottom: flagText.baseline
          anchors.bottomMargin: -dp(1)
          icon: dataModel.userFlagIcons[index]
          color: Theme.tintColor
          size: flagText.font.pixelSize * 0.8
        }
        AppText {
          id: flagText
          anchors.bottom: parent.bottom
          text: modelData
          color: Theme.secondaryTextColor
        }
      }
    }
  }

  AppText {
    visible: showPunishFilter && filter.punishFilter.hasFilter
    text: filter && "Punish: " + filter.punishFilter.displayText || ""
    color: Theme.secondaryTextColor
  }
}
