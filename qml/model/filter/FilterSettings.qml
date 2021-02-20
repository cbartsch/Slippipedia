import QtQuick 2.0
import Felgo 3.0

Item {
  id: filterSettings

  signal filterChanged

  readonly property string displayText: {
    console.log("get display text", filterSettings, gameFilter.startDateMs)

    var pText = playerFilter.displayText
    pText = pText ? "Me: " + pText : ""

    var oText = opponentFilter.displayText
    oText = oText ? "Opponent: " + oText : ""

    var gText = gameFilter.displayText

    return [pText, oText, gText].filter(_ => _).join("\n") || "(nothing)"
  }

  onDisplayTextChanged: console.log("filter display text is", filterSettings, displayText)


  property GameFilterSettings gameFilter:  GameFilterSettings {

    settingsCategory: "stage-filter"

    onFilterChanged: filterSettings.filterChanged()
  }

  property PlayerFilterSettings playerFilter: PlayerFilterSettings {
    settingsCategory: "player-filter"

    onFilterChanged: filterSettings.filterChanged()
  }


  property PlayerFilterSettings opponentFilter: PlayerFilterSettings {
    settingsCategory: "player-filter-opponent"

    onFilterChanged: filterSettings.filterChanged()
  }
}
