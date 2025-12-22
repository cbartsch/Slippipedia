import QtQuick
import Felgo

import Slippi 1.0
import Slippipedia 1.0

Item {
  id: quickFilterOptions

  readonly property GameFilterSettings filter: stats ? stats.dataBase.filterSettings.gameFilter : null

  signal quickFilterChanged

  Flow {
    anchors.fill: parent
    spacing: dp(Theme.contentPadding)

    OptionButton {
      id: currentYearButton

      property int currentYear: new Date().getFullYear()

      text: String(currentYear)
      toolTipText: "Filter for games in %1".arg(currentYear)
      onClicked: {
        quickFilterOptions.filter.setYear(currentYear)
        quickFilterOptions.quickFilterChanged()
      }
    }

    OptionButton {
      text: "Last 24h"
      toolTipText: "Filter for games in the last 24 hours"
      onClicked:  {
        quickFilterOptions.filter.setPastRange(1)
        quickFilterOptions.quickFilterChanged()
      }
    }

    OptionButton {
      text: "Ranked"
      toolTipText: "Filter for only Ranked games"
      onClicked: {
        quickFilterOptions.filter.setGameModes([SlippiReplay.Ranked])
        quickFilterOptions.quickFilterChanged()
      }
    }

    AppToolButton {
      iconType: IconType.trash
      toolTipText: "Clear quick filters"
      iconItem.color: Theme.tintColor
      width: currentYearButton.height
      height: currentYearButton.height
      radius: 0

      onClicked: {
        quickFilterOptions.filter.date.reset()
        quickFilterOptions.filter.removeAllGameModes()
        quickFilterOptions.quickFilterChanged()
      }
    }
  }
}
