import QtQuick
import Felgo

import Slippi 1.0
import Slippipedia 1.0

Item {
  id: quickFilterOptions

  readonly property GameFilterSettings gameFilter: stats ? stats.dataBase.filterSettings.gameFilter : null
  readonly property PunishFilterSettings punishFilter: stats ? stats.dataBase.filterSettings.punishFilter : null

  property bool showPunishOptions: false

  signal quickFilterChanged

  Flow {
    id: content
    anchors.fill: parent
    spacing: dp(Theme.contentPadding)

    OptionButton {
      text: "Ranked"
      toolTipText: checked
                   ? "Reset Ranked filter"
                   : "Filter for only Ranked games"

      checked: gameFilter && gameFilter.hasGameModes([SlippiReplay.Ranked])

      onClicked: {
        gameFilter.setGameModes(checked ? [] : [SlippiReplay.Ranked])
        quickFilterOptions.quickFilterChanged()
      }
    }

    OptionButton {
      id: currentYearButton

      property int currentYear: new Date().getFullYear()

      text: String(currentYear)
      toolTipText: checked
                   ? "Reset year filter"
                   : "Filter for games in %1".arg(currentYear)

      checked: gameFilter && gameFilter.isYear(currentYear)

      visible: !showPunishOptions

      onClicked: {
        if(checked) {
          gameFilter.date.reset()
        }
        else {
          gameFilter.setYear(currentYear)
        }

        quickFilterOptions.quickFilterChanged()
      }
    }

    OptionButton {
      text: "Last 24h"
      toolTipText:  checked
                    ? "Reset day filter"
                    : "Filter for games in the last 24 hours"

      checked: gameFilter && gameFilter.isPastRange(1)

      visible: !showPunishOptions

      onClicked:  {
        if(checked) {
          gameFilter.date.reset()
        }
        else {
          gameFilter.setPastRange(1)
        }

        quickFilterOptions.quickFilterChanged()
      }
    }

    OptionButton {
      text: "50+ Damage"
      toolTipText: checked
                   ? "Reset Damage filter"
                   : "Filter for punishes that dealt 50 damage or more"

      visible: showPunishOptions

      checked: punishFilter && punishFilter.damage.from === 50 && punishFilter.damage.to === -1

      onClicked: {
        if(checked) {
          punishFilter.damage.from = -1
        }
        else {
          punishFilter.damage.from = 50
        }
        punishFilter.damage.to = -1
        quickFilterOptions.quickFilterChanged()
      }
    }

    OptionButton {
      text: "Killed"
      toolTipText: checked
                   ? "Reset Killed filter"
                   : "Filter for punishes that took a stock"

      visible: showPunishOptions

      checked: punishFilter && punishFilter.didKill

      onClicked: {
        punishFilter.didKill = !checked
        quickFilterOptions.quickFilterChanged()
      }
    }
  }
}
