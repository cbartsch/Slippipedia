import QtQuick 2.0
import Felgo 4.0
import Qt.labs.settings 1.1

import Slippipedia 1.0

Item {
  id: gameFilterSettings

  property bool persistenceEnabled: false
  property string settingsCategory: ""

  property int gameEndType: -1
  property int lossType: 0
  property int winnerPlayerIndex: -3 // -3 = any. TODO: make constants for the special values
  property int userFlagMask: 0
  property int sessionSplitIntervalMs: sessionSplitIntervalMsDefault // split sessions after 15 minutes

  readonly property int sessionSplitIntervalMsDefault: 15 * 60 * 1000

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

  property RangeSettings endStocksWinner: RangeSettings {
    id: endStocksWinner

    onFromChanged: if(settingsLoader.item) settingsLoader.item.endStocksMin = from
    onToChanged:   if(settingsLoader.item) settingsLoader.item.endStocksMax = to

    onFilterChanged: gameFilterSettings.filterChanged()
  }

  property RangeSettings endStocksLoser: RangeSettings {
    id: endStocksLoser

    onFromChanged: if(settingsLoader.item) settingsLoader.item.endStocks2Min = from
    onToChanged:   if(settingsLoader.item) settingsLoader.item.endStocks2Max = to

    onFilterChanged: gameFilterSettings.filterChanged()
  }

  property var replayIds: []
  property var stageIds: []
  property var platforms: []
  property var gameModes: []

  signal filterChanged

  // due to settings being in a loader, can't use alias properties -> save on change:
  onWinnerPlayerIndexChanged:      filterChanged()
  onGameEndTypeChanged:            filterChanged()
  onLossTypeChanged:               filterChanged()
  onUserFlagMaskChanged:           filterChanged()
  onReplayIdsChanged:              filterChanged()
  onStageIdsChanged:               filterChanged()
  onPlatformsChanged:              filterChanged()
  onGameModesChanged:              filterChanged()
  onSessionSplitIntervalMsChanged: filterChanged()

  // match slippi constants
  readonly property var gameEndTypeTexts: ({
                                             [-1]: "Any",
                                             [SlippiReplay.Game]: "Game!",
                                             [SlippiReplay.Time]: "Time!",
                                             [SlippiReplay.NoContest]: "No contest (LRAS)",
                                             [SlippiReplay.Resolved]: "Resolved",
                                             [SlippiReplay.Unresolved]: "Unresolved"
                                           })


  readonly property var winnerTexts: ({
                                        [-3]: "Any",
                                        [-2]: "No result / tie",
                                        [-1]: "Either / no tie",
                                        [0]: "Me",
                                        [1]: "Opponent",
                                      })

  readonly property var lossTypeTexts: ({
                                        [0]: "last stock gone",
                                        [1]: "last stock + higher percent",
                                        [2]: "fewer stocks / higher percent",
                                        [3]: "LRAS at last stock",
                                        [4]: "any LRAS",
                                      })

  readonly property bool hasFilter: hasResultFilter || hasGameFilter

  readonly property bool hasResultFilter: hasWinnerFilter || hasDurationFilter
  readonly property bool hasGameFilter: hasDateFilter || hasReplayFilter || hasStageFilter ||
                                        hasUserFlagFilter || hasPlatformFilter || hasGameModeFilter
                                        // || hasSessionSplitInterval // not technically a filter

  readonly property bool hasDateFilter: date.hasFilter
  readonly property bool hasDurationFilter: duration.hasFilter
  readonly property bool hasReplayFilter: replayIds && replayIds.length > 0
  readonly property bool hasStageFilter: stageIds && stageIds.length > 0
  readonly property bool hasPlatformFilter: platforms && platforms.length > 0
  readonly property bool hasGameModeFilter: gameModes && gameModes.length > 0

  readonly property bool hasWinnerFilter: winnerPlayerIndex > -3 || gameEndType > -1 ||
                                          endStocksWinner.hasFilter || endStocksLoser.hasFilter
  readonly property bool hasSessionSplitInterval: sessionSplitIntervalMs != sessionSplitIntervalMsDefault
  readonly property bool hasUserFlagFilter: userFlagMask > 0

  readonly property string displayText: {
    var rText = null
    if(replayIds.length > 0) {
      rText = "Specific replay(s): " + replayIds.map(id => "#" + id).join(", ")
    }

    var sText = null
    if(stageIds.length > 0) {
      sText = "Stages: " + stageIds.map(id => MeleeData.stageMap[id].name).join(", ")
    }

    var etText = gameEndType === -1 ? "" : qsTr("Game end type: %1").arg(gameEndTypeTexts[gameEndType])

    var wText = qsTr("Winner: %1 (Loss if %2)")
    .arg(winnerTexts[winnerPlayerIndex])
    .arg(lossTypeTexts[lossType])

    var sdText = date.from >= 0 ? dataModel.formatDate(new Date(date.from)) : ""
    var edText = date.to >= 0 ? dataModel.formatDate(new Date(date.to)) : ""

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

    var stockText = endStocksWinner.displayText ? "Stocks left (winner): " + endStocksWinner.displayText : ""
    var stockText2 = endStocksLoser.displayText ? "Stocks left (winner): " + endStocksLoser.displayText : ""

    var gameModeText = gameModes && gameModes.length > 0 ? "Game modes: " + gameModes.map(dataModel.gameModeName).join(", ") : ""
    var platformText = platforms && platforms.length > 0 ? "Platforms: " + platforms.map(dataModel.platformText).join(", ") : ""

    return [
          rText, sText, etText, wText, dText, durText, stockText, gameModeText, platformText
        ].filter(_ => _).join("\n") || ""
  }

  Loader {
    id: settingsLoader

    active: persistenceEnabled
    onLoaded: item.apply()

    Connections {
      target: settingsLoader.item ? gameFilterSettings : null

      // due to this being in a loader, can't use alias properties -> save on change:
      onWinnerPlayerIndexChanged:      settingsLoader.item.winnerPlayerIndex = winnerPlayerIndex
      onLossTypeChanged:               settingsLoader.item.lossType = lossType
      onGameEndTypeChanged:            settingsLoader.item.gameEndType = gameEndType
      onUserFlagMaskChanged:           settingsLoader.item.userFlagMask = userFlagMask
      onReplayIdsChanged:              settingsLoader.item.replayIds = replayIds
      onStageIdsChanged:               settingsLoader.item.stageIds = stageIds
      onPlatformsChanged:              settingsLoader.item.platforms = platforms
      onGameModesChanged:              settingsLoader.item.gameModes = gameModes
      onSessionSplitIntervalMsChanged: settingsLoader.item.sessionSplitIntervalMs = sessionSplitIntervalMs
    }

    sourceComponent: Settings {
      id: settings

      category: gameFilterSettings.settingsCategory

      // -3 = any, -2 = tie, -1 = either (no tie), 0 = me, 1 = opponent
      property int winnerPlayerIndex: gameFilterSettings.winnerPlayerIndex

      // 0 = last stock gone, 1 = last stock + higher percent, 2 = fewer stocks / higher percent
      // 3 = last stock + LRAS , 4 = LRAS
      property int lossType: gameFilterSettings.lossType

      // match SlippiReplay enum
      property int gameEndType: gameFilterSettings.gameEndType

      // bitwise match Replay.userFlag
      property int userFlagMask: gameFilterSettings.userFlagMask

      // split sessions against the same opponent after:
      property int sessionSplitIntervalMs: gameFilterSettings.sessionSplitIntervalMs

      // match Replay.id
      property var replayIds: gameFilterSettings.replayIds

      // match Replay.stageId
      property var stageIds: gameFilterSettings.stageIds

      // match Replay.platform
      property var platforms: gameFilterSettings.platforms

      // match Replay.gameMode
      property var gameModes: gameFilterSettings.gameModes

      // start and end date as Date.getTime() ms values
      property double startDateMs: gameFilterSettings.date.from
      property double endDateMs: gameFilterSettings.date.to

      // min and max game duration in frames
      property int minFrames: gameFilterSettings.duration.from
      property int maxFrames: gameFilterSettings.duration.to

      // stocks left at end of game (by player with more stocks left)
      property int endStocksMin: gameFilterSettings.endStocksWinner.from
      property int endStocksMax: gameFilterSettings.endStocksWinner.to

      // stocks left at end of game (by player with fewer stocks left)
      property int endStocks2Min: gameFilterSettings.endStocksLoser.from
      property int endStocks2Max: gameFilterSettings.endStocksLoser.to

      function apply() {
        // due to this being in a loader, can't use alias properties -> apply on load:

        gameFilterSettings.date.from = startDateMs
        gameFilterSettings.date.to = endDateMs

        gameFilterSettings.duration.from = minFrames
        gameFilterSettings.duration.to = maxFrames

        gameFilterSettings.endStocksWinner.from = endStocksMin
        gameFilterSettings.endStocksWinner.to = endStocksMax
        gameFilterSettings.endStocksLoser.from = endStocks2Min
        gameFilterSettings.endStocksLoser.to = endStocks2Max

        gameFilterSettings.winnerPlayerIndex = winnerPlayerIndex
        gameFilterSettings.lossType = lossType
        gameFilterSettings.gameEndType = gameEndType
        gameFilterSettings.userFlagMask = userFlagMask
        gameFilterSettings.sessionSplitIntervalMs = sessionSplitIntervalMs
        gameFilterSettings.replayIds = replayIds.map(id => ~~id) // settings stores as list of string, convert to int
        gameFilterSettings.stageIds =  stageIds.map(id => ~~id)
        gameFilterSettings.gameModes = gameModes.map(id => ~~id)
        gameFilterSettings.platforms = platforms
      }
    }
  }

  function reset() {
    duration.reset()
    date.reset()

    replayIds = []
    stageIds = []
    platforms = []
    gameModes = []

    resetWinnerFilter()

    userFlagMask = 0
    sessionSplitIntervalMs = sessionSplitIntervalMsDefault
  }

  function resetWinnerFilter() {
    endStocksWinner.reset()
    endStocksLoser.reset()

    winnerPlayerIndex = -3
    gameEndType = -1
  }

  function copyFrom(other) {
    setReplayIds(other.replayIds)
    setStage(other.stageIds)
    setPlatforms(other.platforms)
    setGameModes(other.gameModes)

    duration.copyFrom(other.duration)
    date.copyFrom(other.date)
    endStocksWinner.copyFrom(other.endStocksWinner)
    endStocksLoser.copyFrom(other.endStocksLoser)

    winnerPlayerIndex = other.winnerPlayerIndex
    lossType = other.lossType
    gameEndType = other.gameEndType
    userFlagMask = other.userFlagMask
    sessionSplitIntervalMs = other.sessionSplitIntervalMs
  }

  function setReplayIds(replayIds) {
    gameFilterSettings.replayIds = replayIds
  }

  function addReplayIds(replayId) {
    gameFilterSettings.replayIds = replayIds.concat(replayId)
  }

  function removeReplayId(replayId) {
    var list = replayIds
    list.splice(list.indexOf(replayId), 1)
    gameFilterSettings.replayIds = list
  }

  function removeAllReplayIds() {
    gameFilterSettings.replayIds = []
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

  function setPlatforms(platforms) {
    gameFilterSettings.platforms = platforms
  }

  function addPlatform(platform) {
    gameFilterSettings.platforms = platforms.concat(platform)
  }

  function removePlatform(platform) {
    var list = platforms
    list.splice(list.indexOf(platform), 1)
    gameFilterSettings.platforms = list
  }

  function removeAllPlatforms() {
    gameFilterSettings.platforms = []
  }

  function setGameModes(gameModes) {
    gameFilterSettings.gameModes = gameModes
  }

  function addGameMode(gameMode) {
    gameFilterSettings.gameModes = gameModes.concat(gameMode)
  }

  function removeGameMode(gameMode) {
    var list = gameModes
    list.splice(list.indexOf(gameMode), 1)
    gameFilterSettings.gameModes = list
  }

  function removeAllGameModes() {
    gameFilterSettings.gameModes = []
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

  // set date range for all days in a specific year
  function setYear(year) {
    date.from = new Date(year, 0).getTime()
    date.to = new Date(year + 1, 0).getTime()
  }

  // set date range for all days in a specific month of current year
  function setMonth(month) {
    var current = new Date()

    date.from = new Date(current.getFullYear(), month).getTime()
    date.to = new Date(current.getFullYear(), month + 1).getTime()
  }

  // DB filtering functions
  function getGameFilterCondition() {
    var winnerCondition = ""
    if(winnerPlayerIndex === -2) {
      // check for tie
      winnerCondition = getGameNotEndedCondition()
    }
    else if(winnerPlayerIndex === -1) {
      // check for either player wins (no tie)
      winnerCondition = getGameEndedCondition()
    }
    else if(winnerPlayerIndex === 0) {
      // p = matched player, p2 = matched opponent
      winnerCondition = getWinnerCondition("p", "p2")
    }
    else if(winnerPlayerIndex === 1) {
      winnerCondition = getWinnerCondition("p2", "p")
    }

    var replayCondition = ""
    if(replayIds && replayIds.length > 0) {
      replayCondition = "r.id in " + dataModel.globalDataBase.makeSqlWildcards(replayIds)
    }

    var stageCondition = ""
    if(stageIds && stageIds.length > 0) {
      stageCondition = "r.stageId in " + dataModel.globalDataBase.makeSqlWildcards(stageIds)
    }

    var platformCondition = ""
    if(platforms && platforms.length > 0) {
      platformCondition = "r.platform in " + dataModel.globalDataBase.makeSqlWildcards(platforms)
    }

    var gameModeCondition = ""
    if(gameModes && gameModes.length > 0) {
      gameModeCondition = "r.gameMode in " + dataModel.globalDataBase.makeSqlWildcards(gameModes)
    }

    var dateCondition = date.getFilterCondition("r.date")
    var durationCondition = duration.getFilterCondition("r.duration")
    var endStocksCondition = endStocksWinner.getFilterCondition("max(p.s_endStocks, p2.s_endStocks)")
    var endStocks2Condition = endStocksLoser.getFilterCondition("min(p.s_endStocks, p2.s_endStocks)")

    var endTypeCondition = gameEndType === -1 ? "" : "r.endType = ?"
    var userFlagCondition = userFlagMask === 0 ? "" : "(r.userFlag & ?) > 0"

    var condition = [
          replayCondition, winnerCondition, stageCondition,
          dateCondition, durationCondition,
          endStocksCondition, endStocks2Condition,
          endTypeCondition, userFlagCondition,
          platformCondition, gameModeCondition
        ]
    .map(c => ("(" + (c || true) + ")" ))
    .join(" and ")

    return "(" + condition + ")"
  }

  function getGameFilterParams() {
    var isoFormat = "yyyy-MM-ddTHH:mm:ss.zzz"

    var replayIdParams = replayIds && replayIds.length > 0 ? replayIds : []
    var stageIdParams = stageIds && stageIds.length > 0 ? stageIds : []

    var dateParams = date.getFilterParams(v => new Date(v).toLocaleString(Qt.locale(), isoFormat))
    var durationParams = duration.getFilterParams()
    var endStocksParams = endStocksWinner.getFilterParams()
    var endStocks2Params = endStocksLoser.getFilterParams()
    var endTypeParams = gameEndType === -1 ? [] : [gameEndType]
    var userFlagParams = userFlagMask === 0 ? [] : [userFlagMask]
    var platformParams = platforms && platforms.length > 0 ? platforms : []
    var gameModeParams = gameModes && gameModes.length > 0 ? gameModes : []

    return replayIdParams
    .concat(stageIdParams)
    .concat(dateParams)
    .concat(durationParams)
    .concat(endStocksParams)
    .concat(endStocks2Params)
    .concat(endTypeParams)
    .concat(userFlagParams)
    .concat(platformParams)
    .concat(gameModeParams)
  }

  // note: the winnerPort is always set to the player who had fewer stocks or more percent
  // -> can use it for option 2 directly
  function getGameEndedCondition() {
    switch(lossType) {
    case 0: return "r.winnerPort >= 0 and (p.s_endStocks = 0 or p2.s_endStocks = 0)"
    case 1: return "r.winnerPort >= 0 and (p.s_endStocks <= 1 or p2.s_endStocks <= 1)"
    case 2: return "r.winnerPort >= 0 and r.lrasPort < 0"
    case 3: return "r.winnerPort >= 0 and (r.lrasPort < 0 or (p.s_endStocks <= 1 or p2.s_endStocks <= 1))"
    case 4: return "r.winnerPort >= 0"
    }
  }

  function getGameNotEndedCondition() {
    switch(lossType) {
    case 0: return "r.winnerPort < 0 or (p.s_endStocks > 0 and p2.s_endStocks > 0)"
    case 1: return "r.winnerPort < 0 or (p.s_endStocks > 1 and p2.s_endStocks > 1)"
    case 2: return "r.winnerPort < 0 or r.lrasPort >= 0"
    case 3: return "r.winnerPort < 0 or (r.lrasPort >= 0 and (p.s_endStocks > 1 and p2.s_endStocks > 1))"
    case 4: return "r.winnerPort < 0"
    }
  }

  function getWinnerConditionWildcard() {
    switch(lossType) {
    case 0: return "r.winnerPort = %1.port and %2.s_endStocks = 0"
    case 1: return "r.winnerPort = %1.port and %2.s_endStocks <= 1"
    case 2: return "r.winnerPort = %1.port and r.lrasPort < 0"
    case 3: return "(r.winnerPort = %1.port and %2.s_endStocks = 0) or (r.lrasPort = %2.port and %2.s_endStocks <= 1)"
    case 4: return "(r.winnerPort = %1.port and %2.s_endStocks = 0) or (r.lrasPort = %2.port)"
    }
  }

  function getWinnerCondition(playerCol = "p", opponentCol = "p2") {
    return qsTr(getWinnerConditionWildcard()).arg(playerCol).arg(opponentCol)
  }
}
