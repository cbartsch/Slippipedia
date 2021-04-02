import QtQuick 2.0
import Felgo 3.0
import Qt.labs.settings 1.1

import Slippipedia 1.0

Item {
  id: punishFilterSettings

  property bool persistenceEnabled: false
  property string settingsCategory: ""

  property int minMoves: 3
  property real minDamage: 60
  property bool didKill: false

  property var killDirections: []

  signal filterChanged

  // due to this being in a loader, can't use alias properties -> save on change:
  onMinMovesChanged:       filterChanged()
  onMinDamageChanged:      filterChanged()
  onDidKillChanged:        filterChanged()
  onKillDirectionsChanged: filterChanged()


  readonly property bool hasFilter: hasNumMovesFilter || hasDamageFilter ||
                                    hasDidKillFilter || hasKillDirectionFilter

  readonly property bool hasNumMovesFilter: minMoves > 1
  readonly property bool hasDamageFilter: minDamage > 0
  readonly property bool hasDidKillFilter: didKill
  readonly property bool hasKillDirectionFilter: killDirections.length > 0

  readonly property string displayText: {
    var movesText = minMoves > 1 ? qsTr("%1+ moves").arg(minMoves) : ""
    var damageText = minDamage > 0 ? qsTr("%1+%").arg(minDamage) : ""
    var didKillText = didKill ? "Opponent was killed" : ""

    var killDirectionsText = killDirections.length == 0
        ? "" : ("Kill direction: " + killDirections.map(d => MeleeData.killDirectionNames[d]).join(", "))

    return [
          movesText, damageText, didKillText, killDirectionsText
        ].filter(_ => _).join(", ") || ""
  }

  Loader {
    id: settingsLoader

    active: persistenceEnabled
    onLoaded: item.apply()

    Connections {
      target: settingsLoader.item ? punishFilterSettings : null

      // due to this being in a loader, can't use alias properties -> save on change:
      onMinMovesChanged:      settingsLoader.item.minMoves = minMoves
      onMinDamageChanged:     settingsLoader.item.minDamage = minDamage
      onDidKillChanged:       settingsLoader.item.didKill = didKill
      onKillDirectionsChanged: settingsLoader.item.killDirections = killDirections
    }

    sourceComponent: Settings {
      id: settings

      category: punishFilterSettings.settingsCategory

      property int minMoves: punishFilterSettings.minMoves
      property real minDamage: punishFilterSettings.minDamage
      property bool didKill: punishFilterSettings.didKill
      property var killDirections: punishFilterSettings.killDirections

      function apply() {
        // due to this being in a loader, can't use alias properties -> apply on load:
        punishFilterSettings.minMoves = minMoves
        punishFilterSettings.minDamage = minDamage
        punishFilterSettings.didKill = didKill
        punishFilterSettings.killDirections = killDirections.map(id => ~~id) // settings stores as list of string, convert to int
      }
    }
  }

  function reset() {
    minMoves = 1
    minDamage = 0
    didKill = false
    killDirection = -1
  }

  function copyFrom(other) {
    minMoves = other.minMoves
    minDamage = other.minDamage
    didKill = other.didKill
    killDirection = other.killDirection
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

  // DB filtering functions
  function getPunishFilterCondition() {
    console.log("get punish filter condition", hasNumMovesFilter, minMoves)

    var minMovesCondition = hasNumMovesFilter ? "pu.numMoves >= ?" : ""
    var minDamageCondition = hasDamageFilter ? "pu.damage >= ?" : ""
    var didKillCondition = hasDidKillFilter ? "pu.didKill = 1" : ""

    var killDirectionCondition = hasKillDirectionFilter
        ? "pu.killDirection in " +
          dataModel.globalDataBase.makeSqlWildcards(killDirections)
        : ""

    var condition = [
          minMovesCondition,
          minDamageCondition,
          didKillCondition,
          killDirectionCondition
        ]
    .map(c => (c || true))
    .join(" and ")

    return "(" + condition + ")"
  }

  function getPunishFilterParams() {
    var minMovesParams = hasNumMovesFilter ? [minMoves] : []
    var minDamageParams = hasDamageFilter ? [minDamage] : []
    var killDirectionParams = hasKillDirectionFilter ? killDirections : []

    return minMovesParams
    .concat(minDamageParams)
    .concat(killDirectionParams)
  }
}
