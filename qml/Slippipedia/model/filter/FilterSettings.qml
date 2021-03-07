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

  function setFromData(data) {
    // copy all filters from global filter
    copyFrom(dataModel.filterSettings)

    // set desired filters:
    if(data.charId) {
      playerFilter.setCharFilter(data.charId >= 0 ? [data.charId] : [])
    }

    if(data.opponentCharId) {
      opponentFilter.setCharFilter(data.opponentCharId >= 0 ? [data.opponentCharId] : [])
    }

    if(data.stageId) {
      gameFilter.setStage(data.stageId >= 0 ? [data.stageId] : [])
    }

    if(data.time) {
      var date = Date.fromLocaleDateString(Qt.locale(), data.time, "yyyy-MM")
      gameFilter.startDateMs = date.getTime()

      date.setMonth(date.getMonth() + 1)
      gameFilter.endDateMs = date.getTime()
    }

    if(data.code1) playerFilter.slippiCode.filterText = data.code1
    if(data.name1) playerFilter.slippiName.filterText = data.name1
    if(data.code1 && data.name1) playerFilter.filterCodeAndName = true

    if(data.code2) opponentFilter.slippiCode.filterText = data.code2
    if(data.name2) opponentFilter.slippiName.filterText = data.name2
    if(data.code2 && data.name2) opponentFilter.filterCodeAndName = true

    if(data.startMs) gameFilter.startDateMs = data.startMs
    if(data.endMs)   gameFilter.endDateMs = data.endMs
  }
}
