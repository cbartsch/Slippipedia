import QtQuick 2.0
import Felgo 3.0

Item {
  id: replayStats

  property DataBase dataBase

  // stats
  readonly property int totalReplays: dataBase.getNumReplays(dbUpdater)

  property var statsData: dataBase.getReplayStats(dbUpdater)

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

  readonly property real numLedgedashes: statsData ? statsData.numLedgedashes : 0
  readonly property real avgLedgedashes: numLedgedashes / totalReplaysFiltered
  readonly property real totalGalint: statsData ? statsData.totalGalint : 0
  readonly property real avgGalint: totalGalint / numLedgedashes

  readonly property real lCancelsOpponent: statsData ? statsData.lCancelsOpponent : 0
  readonly property real lCancelsMissedOpponent: statsData ? statsData.lCancelsMissedOpponent : 0
  readonly property real lCancelRateOpponent: statsData ? statsData.lCancelRateOpponent : 0

  readonly property real numLedgedashesOpponent: statsData ? statsData.numLedgedashesOpponent : 0
  readonly property real avgLedgedashesOpponent: numLedgedashesOpponent / totalReplaysFiltered
  readonly property real totalGalintOpponent: statsData ? statsData.totalGalintOpponent : 0
  readonly property real avgGalintOpponent: numLedgedashesOpponent == 0 ? 0 : (totalGalintOpponent / numLedgedashesOpponent)

  property real otherStageAmount: 0

  property var charData: ({})
  readonly property var charDataCss: toCssCharData(charData)

  property var charDataOpponent: ({})
  readonly property var charDataOpponentCss: toCssCharData(charDataOpponent)

  property var stageDataMap: ({})
  readonly property var stageData: Object.values(stageDataMap)

  property var topPlayerTags: []
  property var topPlayerTagsOpponent: []
  property var topSlippiCodesOpponent: []

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

  function refresh(numPlayerTags) {
    var limit = numPlayerTags || 1

    otherStageAmount = dataBase.getOtherStageAmount()
    charData = dataBase.getCharacterStats()
    charDataOpponent = dataBase.getCharacterStatsOpponent()
    stageDataMap = dataBase.getStageStats()
    topPlayerTags = dataModel.getTopPlayerTags(limit)
    topPlayerTagsOpponent = dataModel.getTopPlayerTagsOpponent(limit)
    topSlippiCodesOpponent = dataModel.getTopSlippiCodesOpponent(limit)

    dbUpdaterChanged()
  }
}
