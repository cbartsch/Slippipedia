import QtQuick 2.0
import Felgo 3.0

import "../data"
import "../db"

Item {
  id: replayStats

  property DataBase dataBase

  // stats
  readonly property int totalReplays: dataBase.getNumReplays(dbUpdater)

  property var statsData: dataBase.getReplayStats(dbUpdater)

  readonly property int totalReplaysFiltered: statsData && statsData.count || 0
  readonly property int totalReplaysFilteredWithResult: statsData && statsData.gameEndedCount || 0
  readonly property int totalReplaysFilteredWon: statsData && statsData.winCount || 0
  readonly property int totalReplaysFilteredWithTie: totalReplaysFiltered - totalReplaysFilteredWithResult

  readonly property real averageGameDuration: statsData && statsData.avgDuration || 0
  readonly property real totalGameDuration: averageGameDuration * totalReplaysFiltered

  readonly property real tieRate: totalReplaysFilteredWithTie / totalReplaysFiltered
  readonly property real winRate: totalReplaysFilteredWon / totalReplaysFilteredWithResult

  readonly property int totalStocksLost: statsData && statsData.totalStocksLost || 0
  readonly property real averageStocksLost: totalReplaysFiltered == 0 ? 0 : totalStocksLost / totalReplaysFiltered

  readonly property real totalDamageDealt: statsData && statsData.damageDealt || 0
  readonly property real damagePerMinute: totalDamageDealt / (totalGameDuration / 60 / 60)
  readonly property real damagePerStock: totalDamageDealt / totalStocksLostOpponent

  readonly property real lCancels: statsData && statsData.lCancels || 0
  readonly property real lCancelsMissed: statsData && statsData.lCancelsMissed || 0
  readonly property real totalAerials: lCancels + lCancelsMissed
  readonly property real lCancelRate: statsData && statsData.lCancelRate || 0

  readonly property real edgeCancels: statsData && statsData.edgeCancelAerials + statsData.teeterCancelAerials || 0
  readonly property real edgeCancelRate: edgeCancels / totalAerials

  readonly property real nonCancelledAerials: totalAerials - lCancels - edgeCancels
  readonly property real nonCancelledAerialRate: nonCancelledAerials / totalAerials

  readonly property real numLedgedashes: statsData && statsData.numLedgedashes || 0
  readonly property real avgLedgedashes: totalReplaysFiltered == 0 ? 0 : (numLedgedashes / totalReplaysFiltered)
  readonly property real totalGalint: statsData && statsData.totalGalint || 0
  readonly property real avgGalint: numLedgedashes == 0 ? 0 : totalGalint / numLedgedashes

  readonly property int totalStocksLostOpponent: statsData && statsData.totalStocksLostOpponent || 0
  readonly property real averageStocksLostOpponent: totalReplaysFiltered == 0 ? 0 : totalStocksLostOpponent / totalReplaysFiltered

  readonly property real totalDamageDealtOpponent: statsData && statsData.damageDealtOpponent || 0
  readonly property real damagePerMinuteOpponent: totalDamageDealtOpponent / (totalGameDuration / 60 / 60)
  readonly property real damagePerStockOpponent: totalDamageDealtOpponent / totalStocksLost

  readonly property real lCancelsOpponent: statsData && statsData.lCancelsOpponent || 0
  readonly property real lCancelsMissedOpponent: statsData && statsData.lCancelsMissedOpponent || 0
  readonly property real totalAerialsOpponent: lCancelsOpponent + lCancelsMissedOpponent
  readonly property real lCancelRateOpponent: statsData && statsData.lCancelRateOpponent || 0

  readonly property real edgeCancelsOpponent: statsData && statsData.edgeCancelAerialsOpponent + statsData.teeterCancelAerialsOpponent || 0
  readonly property real edgeCancelRateOpponent: edgeCancelsOpponent / totalAerialsOpponent

  readonly property real nonCancelledAerialsOpponent: totalAerialsOpponent - lCancelsOpponent - edgeCancelsOpponent
  readonly property real nonCancelledAerialRateOpponent: nonCancelledAerialsOpponent / totalAerialsOpponent

  readonly property real numLedgedashesOpponent: statsData && statsData.numLedgedashesOpponent || 0
  readonly property real avgLedgedashesOpponent: totalReplaysFiltered == 0 ? 0 : (numLedgedashesOpponent / totalReplaysFiltered)
  readonly property real totalGalintOpponent: statsData && statsData.totalGalintOpponent || 0
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
