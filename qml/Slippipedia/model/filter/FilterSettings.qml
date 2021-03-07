import QtQuick 2.0
import Felgo 3.0

Item {
  id: filterSettings

  property bool persistenceEnabled: false

  readonly property string displayText: {
    var pText = playerFilter.displayText
    pText = pText ? "Me: " + pText : ""

    var oText = opponentFilter.displayText
    oText = oText ? "Opponent: " + oText : ""

    var gText = gameFilter.displayText

    return [pText, oText, gText].filter(_ => _).join("\n") || "(nothing)"
  }

  property GameFilterSettings gameFilter: GameFilterSettings {
    settingsCategory: "stage-filter"
    persistenceEnabled: filterSettings.persistenceEnabled
  }

  property PlayerFilterSettings playerFilter: PlayerFilterSettings {
    settingsCategory: "player-filter"
    persistenceEnabled: filterSettings.persistenceEnabled
  }


  property PlayerFilterSettings opponentFilter: PlayerFilterSettings {
    settingsCategory: "player-filter-opponent"
    persistenceEnabled: filterSettings.persistenceEnabled
  }

  function reset() {
    playerFilter.reset()
    opponentFilter.reset()
    gameFilter.reset()
  }

  function copyFrom(other) {
    playerFilter.copyFrom(other.playerFilter)
    opponentFilter.copyFrom(other.opponentFilter)
    gameFilter.copyFrom(other.gameFilter)
  }
}
