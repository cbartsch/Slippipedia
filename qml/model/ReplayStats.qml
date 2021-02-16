import QtQuick 2.0
import Felgo 3.0

Item {
  id: replayStats

  property DataBase dataBase

  // stats
  readonly property int totalReplays: dataBase.getNumReplays(dbUpdater)

  readonly property var statsData: dataBase.getReplayStats(dbUpdater)

  readonly property int totalReplaysFiltered: statsData ? statsData.count : 0
  readonly property int totalReplaysFilteredWithResult: statsData ? statsData.gameEndedCount : 0
  readonly property int totalReplaysFilteredWon: statsData ? statsData.winCount : 0
  readonly property int totalReplaysFilteredWithTie: totalReplaysFiltered - totalReplaysFilteredWithResult

  readonly property real averageGameDuration: statsData ? statsData.avgDuration : 0

  readonly property real tieRate: totalReplaysFilteredWithTie / totalReplaysFiltered
  readonly property real winRate: totalReplaysFilteredWon / totalReplaysFilteredWithResult

  readonly property real lCancels: statsData ? statsData.lCancels : 0
  readonly property real lCancelsMissed: statsData ? statsData.lCancelsMissed : 0
  readonly property real lCancelRate: statsData ? statsData.lCancelRate : 0

  readonly property real lCancelsOpponent: statsData ? statsData.lCancelsOpponent : 0
  readonly property real lCancelsMissedOpponent: statsData ? statsData.lCancelsMissedOpponent : 0
  readonly property real lCancelRateOpponent: statsData ? statsData.lCancelRateOpponent : 0

  readonly property real otherStageAmount: dataBase.getOtherStageAmount(dbUpdater)

  readonly property var charData: dataBase.getCharacterStats(dbUpdater)
  readonly property var charDataCss: toCssCharData(charData)

  readonly property var charDataOpponent: dataBase.getCharacterStatsOpponent(dbUpdater)
  readonly property var charDataOpponentCss: toCssCharData(charDataOpponent)

  readonly property var stageDataMap: dataBase.getStageStats(dbUpdater)
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

  function toCssCharData(charData) {
    if(!charData) {
      return []
    }

    // map DB results to css-viewable data
    return MeleeData.cssCharIds.map((id, index) => {
                                      var cd = charData[id]

                                      return {
                                        id: id,
                                        count: cd ? cd.count : 0,
                                        name: cd ? cd.name : ""
                                      }
                                    })
  }
}
