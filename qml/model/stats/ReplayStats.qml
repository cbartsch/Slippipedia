import QtQuick 2.0
import Felgo 3.0

import "../data"
import "../db"

Item {
  id: replayStats

  property DataBase dataBase

  // DB data
  property var statsData: dataBase.getReplayStats(false, dbUpdater)
  property var statsDataOpponent: dataBase.getReplayStats(true, dbUpdater)

  // public accessors for player stats
  property alias statsPlayer: statsPlayer
  property alias statsOpponent: statsOpponent

  // public accessors for general stats
  property int totalReplays: dataBase.getNumReplays(dbUpdater)

  property int totalReplaysFiltered: statsData && statsData.count || 0
  property int totalReplaysFilteredWithResult: statsData && statsData.gameEndedCount || 0
  property int totalReplaysFilteredWon: statsData && statsData.winCount || 0
  property int totalReplaysFilteredWithTie: totalReplaysFiltered - totalReplaysFilteredWithResult

  readonly property real averageGameDuration: statsData && statsData.avgDuration || 0
  readonly property real totalGameDuration: averageGameDuration * totalReplaysFiltered

  readonly property real tieRate: totalReplaysFilteredWithTie / totalReplaysFiltered
  readonly property real winRate: totalReplaysFilteredWon / totalReplaysFilteredWithResult

  PlayerStats {
    id: statsPlayer

    statsData: replayStats.statsData
  }

  PlayerStats {
    id: statsOpponent

    statsData: replayStats.statsDataOpponent
  }

  property real otherStageAmount: 0

  property var stageDataMap: ({})
  readonly property var stageData: Object.values(stageDataMap)

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

    stageDataMap = dataBase.getStageStats()
    otherStageAmount = dataBase.getOtherStageAmount()

    statsPlayer.charData = dataBase.getCharacterStats(false)
    statsPlayer.topPlayerTags = dataBase.getTopPlayerTags(false, limit)
    statsPlayer.topSlippiCodes = dataBase.getTopSlippiCodes(false, limit)

    statsOpponent.charData = dataBase.getCharacterStats(true)
    statsOpponent.topPlayerTags = dataBase.getTopPlayerTags(true, limit)
    statsOpponent.topSlippiCodes = dataBase.getTopSlippiCodes(true, limit)

    dbUpdaterChanged()
  }
}
