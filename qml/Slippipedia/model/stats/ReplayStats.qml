import QtQuick 2.0
import Felgo 3.0

import Slippipedia 1.0

Item {
  id: replayStats

  property DataBase dataBase

  // Replay summary data - always update:
  readonly property var summaryData: dataBase.getReplaySummary(false, dbUpdater)

  // Detailed stats data - update in refresh()
  property var statsData
  property var statsDataOpponent

  // public accessors for player stats
  property alias statsPlayer: statsPlayer
  property alias statsOpponent: statsOpponent

  // public accessors for summary data
  property int totalReplays: dataBase.getNumReplays(dbUpdater)

  property int totalReplaysFiltered: summaryData && summaryData.count || 0
  property int totalReplaysFilteredWithResult: summaryData && summaryData.gameEndedCount || 0
  property int totalReplaysFilteredWon: summaryData && summaryData.winCount || 0
  property int totalReplaysFilteredWithTie: totalReplaysFiltered - totalReplaysFilteredWithResult

  readonly property real averageGameDuration: summaryData && summaryData.avgDuration || 0
  readonly property real totalGameDuration: averageGameDuration * totalReplaysFiltered

  readonly property real tieRate: totalReplaysFilteredWithTie / totalReplaysFiltered
  readonly property real winRate: totalReplaysFilteredWon / totalReplaysFilteredWithResult

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

  // compute all data - no bindings as this can be slow
  function refresh(numPlayerTags) {
    var limit = numPlayerTags || 1

    timeData = dataBase.getTimeStats()

    statsData = dataBase.getReplayStats(false)
    statsDataOpponent = dataBase.getReplayStats(true)

    stageDataMap = dataBase.getStageStats()
    otherStageAmount = dataBase.getOtherStageAmount()

    statsPlayer.refresh(limit)
    statsOpponent.refresh(limit)
  }
}
