import QtQuick 2.0
import Felgo 3.0

import Slippipedia 1.0

Item {
  id: replayStats

  property DataBase dataBase

  readonly property bool isLoading: refreshTimer.running

  // Replay summary data
  property var summaryData: null

  // Detailed stats data
  property var statsData: null
  property var statsDataOpponent: null

  // public accessors for player stats
  property alias statsPlayer: statsPlayer
  property alias statsOpponent: statsOpponent

  property int totalReplays: dataModel.totalReplays

  // public accessors for summary data
  property int totalReplaysFiltered: summaryData && summaryData.count || 0
  property int totalReplaysFilteredWithResult: summaryData && summaryData.gameEndedCount || 0
  property int totalReplaysFilteredWon: summaryData && summaryData.winCount || 0
  property int totalReplaysFilteredWithTie: totalReplaysFiltered - totalReplaysFilteredWithResult

  readonly property real averageGameDuration: summaryData && summaryData.avgDuration || 0
  readonly property real totalGameDuration: averageGameDuration * totalReplaysFiltered
  readonly property real totalGameDurationMinutes: averageGameDuration * totalReplaysFiltered / 60 / 60

  readonly property real tieRate: totalReplaysFilteredWithTie / totalReplaysFiltered
  readonly property real winRate: totalReplaysFilteredWon / totalReplaysFilteredWithResult

  readonly property bool hasOpenings: !!statsPlayer.openingMoves

  Connections {
    target: dataBase ? dataBase.filterSettings : null

    onFilterChanged: refreshSummary()
  }

  PlayerStats {
    id: statsPlayer

    statsData: replayStats.statsData
    dataBase: replayStats.dataBase
    isOpponent: false
  }

  PlayerStats {
    id: statsOpponent

    statsData: replayStats.statsDataOpponent
    dataBase: replayStats.dataBase
    isOpponent: true
  }

  property real otherStageAmount: 0

  property var stageDataMap: ({})
  readonly property var stageData: Object.values(stageDataMap)

  readonly property var stageDataAnalytics: stageData ? Object.values(stageData).map(
                                                         item => {
                                                           item.winRate = item.gamesFinished === 0
                                                             ? 0 : (item.gamesWon / item.gamesFinished)
                                                           return item
                                                         })
                                                     : []

  property var timeData: ({})

  readonly property var timeDataAnalytics: timeData ? Object.values(timeData).map(
                                                         item => {
                                                           item.winRate = item.gamesFinished === 0
                                                             ? 0 : (item.gamesWon / item.gamesFinished)
                                                           return item
                                                         })
                                                     : []

  readonly property var stageDataSss: MeleeData.stageData
  .filter(s => s.id > 0)
  .map((s, index) => {
    var sd = stageDataMap[s.id]

    return {
      id: s.id,
      count: sd ? sd.count : 0,
      name: s.name,
      shortName: s.shortName
    }
  })

  Component.onCompleted: {
    refresh()
  }

  function refreshSummary() {
    summaryData = dataBase.getReplaySummary(false)
  }

  // compute all data - no bindings as this can be slow
  // instead call after a delay so the UI is more responsive
  // (bg thread would be better!)
  function refresh(numPlayerTags = 0, refreshOpenings = false) {
    refreshTimer.numPlayerTags = numPlayerTags || 1
    refreshTimer.refreshOpenings = refreshOpenings
    refreshTimer.start()
  }

  Timer {
    id: refreshTimer

    property int numPlayerTags
    property bool refreshOpenings: false

    running: false
    repeat: false
    interval: 500 // let UI animations finish before loading
    onTriggered: {
      if(refreshOpenings) {
        statsPlayer.refreshOpenings()
        statsOpponent.refreshOpenings()
      }
      else {
        statsPlayer.clearOpenings()
        statsOpponent.clearOpenings()
      }

      doRefresh(numPlayerTags)
    }
  }

  function doRefresh(numPlayerTags) {
    refreshSummary()

    timeData = dataBase.getTimeStats()

    statsData = dataBase.getReplayStats(false)
    statsDataOpponent = dataBase.getReplayStats(true)

    stageDataMap = dataBase.getStageStats()
    otherStageAmount = dataBase.getOtherStageAmount()

    statsPlayer.refresh(numPlayerTags)
    statsOpponent.refresh(numPlayerTags)
  }
}
