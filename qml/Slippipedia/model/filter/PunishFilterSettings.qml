import QtQuick 2.0
import Felgo 4.0
import Qt.labs.settings 1.1

import Slippipedia 1.0

Item {
  id: punishFilterSettings

  property bool persistenceEnabled: false
  property string settingsCategory: ""

  property bool didKill: true

  property var killDirections: []
  property var openingMoveIds: []
  property var lastMoveIds: []

  property RangeSettings numMoves: RangeSettings {
    id: numMoves

    onFromChanged: if(settingsLoader.item) settingsLoader.item.minMoves = from
    onToChanged:   if(settingsLoader.item) settingsLoader.item.maxMoves = to

    onFilterChanged: punishFilterSettings.filterChanged()
  }

  property RangeSettings damage: RangeSettings {
    id: damage

    from: 50

    onFromChanged: if(settingsLoader.item) settingsLoader.item.minDamage = from
    onToChanged:   if(settingsLoader.item) settingsLoader.item.maxDamage = to

    onFilterChanged: punishFilterSettings.filterChanged()
  }

  property RangeSettings startPercent: RangeSettings {
    id: startPercent

    onFromChanged: if(settingsLoader.item) settingsLoader.item.minStartPercent = from
    onToChanged:   if(settingsLoader.item) settingsLoader.item.maxStartPercent = to

    onFilterChanged: punishFilterSettings.filterChanged()
  }

  property RangeSettings endPercent: RangeSettings {
    id: endPercent

    onFromChanged: if(settingsLoader.item) settingsLoader.item.minEndPercent = from
    onToChanged:   if(settingsLoader.item) settingsLoader.item.maxEndPercent = to

    onFilterChanged: punishFilterSettings.filterChanged()
  }

  signal filterChanged

  // due to this being in a loader, can't use alias properties -> save on change:
  onDidKillChanged:        filterChanged()
  onKillDirectionsChanged: filterChanged()
  onOpeningMoveIdsChanged: filterChanged()
  onLastMoveIdsChanged:    filterChanged()

  readonly property bool hasFilter: hasNumMovesFilter || hasDamageFilter ||
                                    hasStartPercentFilter || hasEndPercentFilter ||
                                    hasDidKillFilter || hasKillDirectionFilter ||
                                    hasOpeningMoveFilter || hasLastMoveFilter

  readonly property bool hasNumMovesFilter: numMoves.hasFilter
  readonly property bool hasDamageFilter: damage.hasFilter
  readonly property bool hasStartPercentFilter: startPercent.hasFilter
  readonly property bool hasEndPercentFilter: endPercent.hasFilter

  readonly property bool hasDidKillFilter: didKill

  readonly property bool hasKillDirectionFilter: killDirections.length > 0
  readonly property bool hasOpeningMoveFilter: openingMoveIds.length > 0
  readonly property bool hasLastMoveFilter: lastMoveIds.length > 0

  readonly property string displayText: {
    var movesText = numMoves.hasFilter ? numMoves.displayText + " moves" : ""
    var damageText = damage.hasFilter ? damage.displayText + "%" : ""
    var startPercentText = startPercent.hasFilter ? "Started at: " + startPercent.displayText + "%" : ""
    var endPercentText = endPercent.hasFilter ? "Ended at: " + endPercent.displayText + "%" : ""

    var didKillText = didKill ? "Opponent was killed" : ""

    var killDirectionsText = killDirections.length == 0
        ? "" : ("Kill direction: " + killDirections.map(d => MeleeData.killDirectionNames[d]).join(", "))

    var openingMovesText = openingMoveIds.length == 0
        ? "" : ("Opening: " + openingMoveIds.map(d => MeleeData.moveNames[d]).join(", "))

    var lastMovesText = lastMoveIds.length == 0
        ? "" : ("Last move: " + lastMoveIds.map(d => MeleeData.moveNames[d]).join(", "))

    return [
          movesText, damageText, startPercentText, endPercentText,
          didKillText,
          killDirectionsText, openingMovesText, lastMovesText
        ].filter(_ => _).join(", ") || ""
  }

  Loader {
    id: settingsLoader

    active: persistenceEnabled
    onLoaded: item.apply()

    Connections {
      target: settingsLoader.item ? punishFilterSettings : null

      // due to this being in a loader, can't use alias properties -> save on change:
      onDidKillChanged:        settingsLoader.item.didKill = didKill
      onKillDirectionsChanged: settingsLoader.item.killDirections = killDirections
      onOpeningMoveIdsChanged: settingsLoader.item.openingMoveIds = openingMoveIds
      onLastMoveIdsChanged:    settingsLoader.item.lastMoveIds = lastMoveIds
    }

    sourceComponent: Settings {
      id: settings

      category: punishFilterSettings.settingsCategory

      property int minMoves: punishFilterSettings.numMoves.from
      property int maxMoves: punishFilterSettings.numMoves.to

      property real minDamage: punishFilterSettings.damage.from
      property real maxDamage: punishFilterSettings.damage.to

      property int minStartPercent: punishFilterSettings.startPercent.from
      property int maxStartPercent: punishFilterSettings.startPercent.to

      property real minEndPercent: punishFilterSettings.endPercent.from
      property real maxEndPercent: punishFilterSettings.endPercent.to

      property bool didKill: punishFilterSettings.didKill
      property var killDirections: punishFilterSettings.killDirections
      property var openingMoveIds: punishFilterSettings.openingMoveIds
      property var lastMoveIds: punishFilterSettings.lastMoveIds

      function apply() {
        // due to this being in a loader, can't use alias properties -> apply on load:
        punishFilterSettings.numMoves.from = minMoves
        punishFilterSettings.numMoves.to = maxMoves

        punishFilterSettings.damage.from = minDamage
        punishFilterSettings.damage.to = maxDamage

        punishFilterSettings.startPercent.from = minStartPercent
        punishFilterSettings.startPercent.to = maxStartPercent

        punishFilterSettings.endPercent.from = minEndPercent
        punishFilterSettings.endPercent.to = maxEndPercent

        punishFilterSettings.didKill = didKill

        punishFilterSettings.killDirections = killDirections.map(id => ~~id) // settings stores as list of string, convert to int
        punishFilterSettings.openingMoveIds = openingMoveIds.map(id => ~~id)
        punishFilterSettings.lastMoveIds = lastMoveIds.map(id => ~~id)
      }
    }
  }

  function reset() {
    numMoves.reset()
    damage.reset()
    startPercent.reset()
    endPercent.reset()

    didKill = false

    killDirections = []
    openingMoveIds = []
    lastMoveIds = []
  }

  function copyFrom(other) {
    numMoves.copyFrom(other.numMoves)
    damage.copyFrom(other.damage)
    startPercent.copyFrom(other.startPercent)
    endPercent.copyFrom(other.endPercent)

    didKill = other.didKill

    killDirections = other.killDirections
    openingMoveIds = other.openingMoveIds
    lastMoveIds = other.lastMoveIds
  }

  function setKillDirection(killDirections) {
    punishFilterSettings.killDirections = killDirections
  }

  function addKillDirection(killDirection) {
    if(killDirections.indexOf(killDirection) < 0) {
      killDirections = killDirections.concat(killDirection)
    }
  }

  function removeKillDirection(killDirection) {
    var list = killDirections
    list.splice(list.indexOf(killDirection), 1)
    killDirections = list
  }

  function removeAllKillDirections() {
    killDirections = []
  }

  function setOpeningMove(openingMoveIds) {
    punishFilterSettings.openingMoveIds = openingMoveIds
  }

  function addOpeningMove(moveId) {
    if(openingMoveIds.indexOf(moveId) < 0) {
      openingMoveIds = openingMoveIds.concat(moveId)
    }
  }

  function removeOpeningMove(moveId) {
    var list = openingMoveIds
    list.splice(list.indexOf(moveId), 1)
    openingMoveIds = list
  }

  function removeAllOpeningMoves() {
    openingMoveIds = []
  }

  function setLastMove(lastMoveIds) {
    punishFilterSettings.lastMoveIds = lastMoveIds
  }

  function addLastMove(moveId) {
    if(lastMoveIds.indexOf(moveId) < 0) {
      lastMoveIds = lastMoveIds.concat(moveId)
    }
  }

  function removeLastMove(moveId) {
    var list = lastMoveIds
    list.splice(list.indexOf(moveId), 1)
    lastMoveIds = list
  }

  function removeAllLastMoves() {
    lastMoveIds = []
  }

  // DB filtering functions
  function getPunishFilterCondition() {
    var numMovesCondition = numMoves.getFilterCondition("pu.numMoves")
    var damageCondition = damage.getFilterCondition("pu.damage")
    var startPercentCondition = startPercent.getFilterCondition("pu.startPercent")
    var endPercentCondition = endPercent.getFilterCondition("pu.endPercent")

    var didKillCondition = hasDidKillFilter ? "pu.didKill = 1" : ""

    var killDirectionCondition = hasKillDirectionFilter
        ? "pu.killDirection in " +
          dataModel.globalDataBase.makeSqlWildcards(killDirections)
        : ""

    var openingMovesCondition = hasOpeningMoveFilter
        ? "pu.openingMoveId in " +
          dataModel.globalDataBase.makeSqlWildcards(openingMoveIds)
        : ""

    var lastMovesCondition = hasLastMoveFilter
        ? "pu.lastMoveId in " +
          dataModel.globalDataBase.makeSqlWildcards(lastMoveIds)
        : ""

    var condition = [
          numMovesCondition, damageCondition,
          startPercentCondition, endPercentCondition,
          didKillCondition,
          killDirectionCondition,
          openingMovesCondition,
          lastMovesCondition
        ]
    .map(c => (c || true))
    .join(" and ")

    return "(" + condition + ")"
  }

  function getPunishFilterParams() {
    var numMovesParams = numMoves.getFilterParams()
    var damageParams = damage.getFilterParams()
    var startPercentParams = startPercent.getFilterParams()
    var endPercentParams = endPercent.getFilterParams()

    var killDirectionParams = hasKillDirectionFilter ? killDirections : []
    var openingMoveParams = hasOpeningMoveFilter ? openingMoveIds : []
    var lastMoveParams = hasLastMoveFilter ? lastMoveIds : []

    return numMovesParams
    .concat(damageParams)
    .concat(startPercentParams)
    .concat(endPercentParams)
    .concat(killDirectionParams)
    .concat(openingMoveParams)
    .concat(lastMoveParams)
  }
}
