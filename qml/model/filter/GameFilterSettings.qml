import QtQuick 2.0
import Felgo 3.0
import Qt.labs.settings 1.1

import "../data"

Item {
  id: gameFilterSettings

  property alias settingsCategory: settings.category

  signal filterChanged

  property int winnerPlayerIndex: -3 // -3 = any. TODO: make constants for the special values

  property double startDateMs: -1
  property double endDateMs: -1

  property int minFrames: -1
  property int maxFrames: -1

  property int endStocks: -1

  readonly property var stageIds: settings.stageIds.map(id => ~~id)

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

  readonly property bool hasDateFilter: startDateMs >= 0 || endDateMs >= 0
  readonly property bool hasDurationFilter: minFrames >= 0 || maxFrames >= 0
  readonly property bool hasStageFilter: stageIds && stageIds.length > 0
  readonly property bool hasWinnerFilter: winnerPlayerIndex > -3 || endStocks >= 0

  onStageIdsChanged: filterChanged()

  readonly property string displayText: {
    var sText = null
    if(stageIds.length > 0) {
      sText = "Stages: " + stageIds.map(id => MeleeData.stageMap[id].name).join(", ")
    }

    var wText = winnerPlayerIndex == -3
        ? "" : ("Winner: " + winnerTexts[winnerPlayerIndex])

    var sdText = startDateMs > 0 ? new Date(startDateMs).toLocaleString(Qt.locale(), "dd/MM/yyyy hh:mm") : ""
    var edText = endDateMs > 0 ? new Date(endDateMs).toLocaleString(Qt.locale(), "dd/MM/yyyy hh:mm") : ""

    var dText = sdText && edText
        ? sdText + " to " + edText
        : sdText
          ? "After " + sdText
          : edText
            ? "Before " + edText
            : ""

    dText = dText ? "Date: " + dText : ""

    var minText = minFrames >= 0 ? dataModel.formatTime(minFrames) : ""
    var maxText = maxFrames >= 0 ? dataModel.formatTime(maxFrames) : ""

    var durText = minText && maxText
        ? qsTr("Between %1 and %2").arg(minText).arg(maxText)
        : minText ? "Longer than " + minText
                  : maxText ? "Shorter than " + maxText : ""
    durText = durText ? "Duration: " + durText : ""

    var stockText = endStocks < 0 ? "" : ("Stocks left: " + endStocks)

    return [
          sText, wText, dText, durText, stockText
        ].filter(_ => _).join("\n") || ""
  }

  Settings {
    id: settings

    // -3 = any, -2 = tie, -1 = either (no tie), 0 = me, 1 = opponent
    property alias winnerPlayerIndex: gameFilterSettings.winnerPlayerIndex
    property var stageIds: []

    // start and end date as Date.getTime() ms values
    property alias startDateMs: gameFilterSettings.startDateMs
    property alias endDateMs: gameFilterSettings.endDateMs

    // min and max game duration in frames
    property alias minFrames: gameFilterSettings.minFrames
    property alias maxFrames: gameFilterSettings.maxFrames

    // stocks left at end of game (by player with more stocks left)
    property alias endStocks: gameFilterSettings.endStocks
  }

  function reset() {
    settings.stageIds = []
    settings.winnerPlayerIndex = -3
    settings.startDateMs = -1
    settings.endDateMs = -1
    settings.minFrames = -1
    settings.maxFrames = -1
    settings.endStocks = -1
  }

  function setStage(stageId) {
    settings.stageIds = stageId
  }

  function addStage(stageId) {
    settings.stageIds = stageIds.concat(stageId)
  }

  function removeStage(stageId) {
    var list = stageIds
    list.splice(list.indexOf(stageId), 1)
    settings.stageIds = list
  }

  function removeAllStages() {
    settings.stageIds = []
  }

  // set date range from now to numDays before now
  function setPastRange(numDays) {
    var ms = numDays * 24 * 60 * 60 * 1000

    var date = new Date()
    endDateMs = date.getTime()

    date.setTime(date.getTime() - ms)
    startDateMs = date.getTime()
  }

  // move date range by numDays forward
  function addDateRange(numDays) {
    var ms = numDays * 24 * 60 * 60 * 1000

    startDateMs += ms
    endDateMs += ms
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

    var startDateCondition = startDateMs < 0 ? "" : "r.date >= ?"
    var endDateCondition = endDateMs < 0 ? "" : "r.date <= ?"
    var minFramesCondition = minFrames < 0 ? "" : "r.duration >= ?"
    var maxFramesCondition = maxFrames < 0 ? "" : "r.duration <= ?"
    var endStocksCondition = endStocks < 0 ? "" : "max(p.s_endStocks, p2.s_endStocks) >= ?"

    var condition = [
          winnerCondition, stageCondition,
          startDateCondition, endDateCondition,
          minFramesCondition, maxFramesCondition,
          endStocksCondition
        ]
    .map(c => (c || true))
    .join(" and ")

    return "(" + condition + ")"
  }

  function getGameFilterParams() {
    var isoFormat = "yyyy-MM-ddTHH:mm:ss.zzz"

    var stageIdParams = stageIds && stageIds.length > 0 ? stageIds : []
    var startDateParams = startDateMs < 0 ? [] : [new Date(startDateMs).toLocaleString(Qt.locale(), isoFormat)]
    var endDateParams = endDateMs < 0 ? [] : [new Date(endDateMs).toLocaleString(Qt.locale(), isoFormat)]
    var durationParams = [minFrames, maxFrames].filter(f => f > 0)
    var endStocksParams = endStocks < 0 ? [] : [endStocks]

    return stageIdParams
    .concat(startDateParams)
    .concat(endDateParams)
    .concat(durationParams)
    .concat(endStocksParams)
  }
}
