import QtQuick 2.0
import Felgo 3.0
import Qt.labs.settings 1.1

import Slippipedia 1.0

Item {
  id: gameFilterSettings

  property bool persistenceEnabled: false
  property string settingsCategory: ""

  property int winnerPlayerIndex: -3 // -3 = any. TODO: make constants for the special values

  // duration from-to in frames
  property RangeSettings duration: RangeSettings {
    id: duration

    onFromChanged: if(settingsLoader.item) settingsLoader.item.minFrames = from
    onToChanged:   if(settingsLoader.item) settingsLoader.item.maxFrames = to

    onFilterChanged: gameFilterSettings.filterChanged()
  }

  // date from-to in ms
  property RangeSettings date: RangeSettings {
    id: date

    onFromChanged: if(settingsLoader.item) settingsLoader.item.startDateMs = from
    onToChanged:   if(settingsLoader.item) settingsLoader.item.endDateMs = to

    onFilterChanged: gameFilterSettings.filterChanged()
  }

  // date from-to in ms
  property RangeSettings endStocks: RangeSettings {
    id: endStocks

    onFromChanged: if(settingsLoader.item) settingsLoader.item.endStocksMin = from
    onToChanged:   if(settingsLoader.item) settingsLoader.item.endStocksMax = to

    onFilterChanged: gameFilterSettings.filterChanged()
  }

  property var stageIds: []

  signal filterChanged

  // due to this being in a loader, can't use alias properties -> save on change:
  onWinnerPlayerIndexChanged: filterChanged()
  onStageIdsChanged:          filterChanged()

  readonly property var winnerTexts: ({
                                        [-3]: "Any",
                                        [-2]: "No result",
                                        [-1]: "Either (no tie)",
                                        [0]: "Me",
                                        [1]: "Opponent",
                                      })

  readonly property bool hasFilter: hasResultFilter || hasGameFilter

  readonly property bool hasResultFilter: hasWinnerFilter || hasDurationFilter
  readonly property bool hasGameFilter: hasDateFilter || hasStageFilter

  readonly property bool hasDateFilter: date.hasFilter
  readonly property bool hasDurationFilter: duration.hasFilter
  readonly property bool hasStageFilter: stageIds && stageIds.length > 0
  readonly property bool hasWinnerFilter: winnerPlayerIndex > -3 || endStocks.hasFilter

  readonly property string displayText: {
    var sText = null
    if(stageIds.length > 0) {
      sText = "Stages: " + stageIds.map(id => MeleeData.stageMap[id].name).join(", ")
    }

    var wText = winnerPlayerIndex == -3
        ? "" : ("Winner: " + winnerTexts[winnerPlayerIndex])

    var sdText = date.from >= 0 ? new Date(date.from).toLocaleString(Qt.locale(), "dd/MM/yyyy hh:mm") : ""
    var edText = date.to >= 0 ? new Date(date.to).toLocaleString(Qt.locale(), "dd/MM/yyyy hh:mm") : ""

    var dText = sdText && edText
        ? sdText + " to " + edText
        : sdText
          ? "After " + sdText
          : edText
            ? "Before " + edText
            : ""

    dText = dText ? "Date: " + dText : ""

    var minText = duration.from >= 0 ? dataModel.formatTime(duration.from) : ""
    var maxText = duration.to >= 0 ? dataModel.formatTime(duration.to) : ""

    var durText = minText && maxText
        ? qsTr("Between %1 and %2").arg(minText).arg(maxText)
        : minText ? "Longer than " + minText
                  : maxText ? "Shorter than " + maxText : ""
    durText = durText ? "Duration: " + durText : ""

    var stockText = endStocks.displayText ? "Stocks left (winner): " + endStocks.displayText : ""

    return [
          sText, wText, dText, durText, stockText
        ].filter(_ => _).join("\n") || ""
  }

  Loader {
    id: settingsLoader

    active: persistenceEnabled
    onLoaded: item.apply()

    Connections {
      target: settingsLoader.item ? gameFilterSettings : null

      // due to this being in a loader, can't use alias properties -> save on change:
      onWinnerPlayerIndexChanged: settingsLoader.item.winnerPlayerIndex = winnerPlayerIndex
      onStageIdsChanged:          settingsLoader.item.stageIds = stageIds
    }

    sourceComponent: Settings {
      id: settings

      category: gameFilterSettings.settingsCategory

      // -3 = any, -2 = tie, -1 = either (no tie), 0 = me, 1 = opponent
      property int winnerPlayerIndex: gameFilterSettings.winnerPlayerIndex

      property var stageIds: gameFilterSettings.stageIds

      // start and end date as Date.getTime() ms values
      property double startDateMs: gameFilterSettings.date.from
      property double endDateMs: gameFilterSettings.date.to

      // min and max game duration in frames
      property int minFrames: gameFilterSettings.duration.from
      property int maxFrames: gameFilterSettings.duration.to

      // stocks left at end of game (by player with more stocks left)
      property int endStocksMin: gameFilterSettings.endStocks.from
      property int endStocksMax: gameFilterSettings.endStocks.to

      function apply() {
        // due to this being in a loader, can't use alias properties -> apply on load:

        gameFilterSettings.date.from = startDateMs
        gameFilterSettings.date.to = endDateMs

        gameFilterSettings.duration.from = minFrames
        gameFilterSettings.duration.to = maxFrames

        gameFilterSettings.endStocks.from = endStocksMin
        gameFilterSettings.endStocks.to = endStocksMax

        gameFilterSettings.winnerPlayerIndex = winnerPlayerIndex
        gameFilterSettings.stageIds = stageIds.map(id => ~~id) // settings stores as list of string, convert to int
      }
    }
  }

  function reset() {
    duration.reset()
    date.reset()
    endStocks.reset()

    stageIds = []
    winnerPlayerIndex = -3
  }

  function copyFrom(other) {
    setStage(other.stageIds)

    duration.copyFrom(other.duration)
    date.copyFrom(other.date)
    endStocks.copyFrom(other.endStocks)

    winnerPlayerIndex = other.winnerPlayerIndex
  }

  function setStage(stageIds) {
    gameFilterSettings.stageIds = stageIds
  }

  function addStage(stageId) {
    gameFilterSettings.stageIds = stageIds.concat(stageId)
  }

  function removeStage(stageId) {
    var list = stageIds
    list.splice(list.indexOf(stageId), 1)
    gameFilterSettings.stageIds = list
  }

  function removeAllStages() {
    gameFilterSettings.stageIds = []
  }

  // set date range from now to numDays before now
  function setPastRange(numDays) {
    var ms = numDays * 24 * 60 * 60 * 1000

    var current = new Date()
    date.to = current.getTime()

    current.setTime(current.getTime() - ms)
    date.from = current.getTime()
  }

  // move date range by numDays forward
  function addDateRange(numDays) {
    var ms = numDays * 24 * 60 * 60 * 1000

    date.to += ms
    date.from += ms
  }

  // DB filtering functions
  function getGameFilterCondition() {
    var winnerCondition = ""
    if(winnerPlayerIndex === -2) {
      // check for tie
      winnerCondition = "r.winnerPort < 0"
    }
    else if(winnerPlayerIndex === -1) {
      // check for either player wins (no tie)
      winnerCondition = "r.winnerPort >= 0"
    }
    else if(winnerPlayerIndex === 0) {
      // p = matched player
      winnerCondition = "r.winnerPort = p.port"
    }
    else if(winnerPlayerIndex === 1) {
      // p2 = matched opponent
      winnerCondition = "r.winnerPort = p2.port"
    }

    var stageCondition = ""
    if(stageIds && stageIds.length > 0) {
      stageCondition = "r.stageId in " + dataModel.globalDataBase.makeSqlWildcards(stageIds)
    }

    var dateCondition = date.getFilterCondition("r.date")
    var durationCondition = duration.getFilterCondition("r.duration")
    var endStocksCondition = endStocks.getFilterCondition("max(p.s_endStocks, p2.s_endStocks)")

    var condition = [
          winnerCondition, stageCondition,
          dateCondition, durationCondition, endStocksCondition
        ]
    .map(c => (c || true))
    .join(" and ")

    return "(" + condition + ")"
  }

  function getGameFilterParams() {
    var isoFormat = "yyyy-MM-ddTHH:mm:ss.zzz"

    var stageIdParams = stageIds && stageIds.length > 0 ? stageIds : []

    var dateParams = date.getFilterParams(v => new Date(v).toLocaleString(Qt.locale(), isoFormat))
    var durationParams = duration.getFilterParams()
    var endStocksParams = endStocks.getFilterParams()

    return stageIdParams
    .concat(dateParams)
    .concat(durationParams)
    .concat(endStocksParams)
  }
}
