import QtQuick 2.0
import Felgo 3.0

Item {
  id: filterSettings

  property bool persistenceEnabled: false
  property bool showPunishFilter: false

  readonly property string displayText: {
    var pText = playerFilter.displayText
    pText = pText ? "Me: " + pText : ""

    var oText = opponentFilter.displayText
    oText = oText ? "Opponent: " + oText : ""

    var gText = gameFilter.displayText

    var puText = punishFilter.displayText
    puText = puText ? "Punish: " + puText : ""

    return [pText, oText, gText, showPunishFilter ? puText : ""].filter(_ => _).join("\n") || "(nothing)"
  }

  signal filterChanged

  property GameFilterSettings gameFilter: GameFilterSettings {
    settingsCategory: "stage-filter"
    persistenceEnabled: filterSettings.persistenceEnabled
    onFilterChanged: filterSettings.filterChanged()
  }

  property PlayerFilterSettings playerFilter: PlayerFilterSettings {
    settingsCategory: "player-filter"
    persistenceEnabled: filterSettings.persistenceEnabled
    onFilterChanged: filterSettings.filterChanged()
  }

  property PlayerFilterSettings opponentFilter: PlayerFilterSettings {
    settingsCategory: "player-filter-opponent"
    persistenceEnabled: filterSettings.persistenceEnabled
    onFilterChanged: filterSettings.filterChanged()
  }

  property PunishFilterSettings punishFilter: PunishFilterSettings {
    settingsCategory: "punish-filter"
    persistenceEnabled: filterSettings.persistenceEnabled
    onFilterChanged: filterSettings.filterChanged()
  }

  function reset() {
    playerFilter.reset()
    opponentFilter.reset()
    gameFilter.reset()
    punishFilter.reset()
  }

  function copyFrom(other) {
    playerFilter.copyFrom(other.playerFilter)
    opponentFilter.copyFrom(other.opponentFilter)
    gameFilter.copyFrom(other.gameFilter)
    punishFilter.copyFrom(other.punishFilter)
  }

  function setFromData(data) {
    if("sourceFilter" in data) {
      // copy all filters from specified source filter
      copyFrom(data.sourceFilter)
    }
    else {
      // copy all filters from global filter
      copyFrom(dataModel.filterSettings)
    }

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

    if(data.yearMonth) {
      var date = Date.fromLocaleDateString(Qt.locale(), data.yearMonth, "yyyy-MM")
      gameFilter.startDateMs = date.getTime()

      date.setMonth(date.getMonth() + 1)
      gameFilter.endDateMs = date.getTime()
    }

    if("code1" in data) playerFilter.slippiCode.filterText = data.code1
    if("name1" in data) playerFilter.slippiName.filterText = data.name1
    if(data.code1 && data.name1) playerFilter.filterCodeAndName = true

    if("code2" in data) opponentFilter.slippiCode.filterText = data.code2
    if("name2" in data) opponentFilter.slippiName.filterText = data.name2
    if(data.code2 && data.name2) opponentFilter.filterCodeAndName = true

    if(data.exact) {
      playerFilter.slippiName.matchCase = true
      playerFilter.slippiName.matchPartial = false
      opponentFilter.slippiName.matchCase = true
      opponentFilter.slippiName.matchPartial = false
    }

    if(data.startMs) gameFilter.startDateMs = data.startMs
    if(data.endMs)   gameFilter.endDateMs = data.endMs

    // TODO apply punish filter from data
  }
}
