import QtQuick 2.0
import Felgo 3.0

import "../data"

Item {
  id: playerStats

  property var statsData: ({})

  readonly property int totalStocksLost: statsData && statsData.totalStocksLost || 0
  readonly property int totalStocksTaken: statsData && statsData.totalStocksLostOpponent || 0
  readonly property real averageStocksLost: totalReplaysFiltered == 0 ? 0 : totalStocksLost / totalReplaysFiltered
  readonly property real averageStocksTaken: totalReplaysFiltered == 0 ? 0 : totalStocksTaken / totalReplaysFiltered

  readonly property real totalDamageDealt: statsData && statsData.damageDealt || 0
  readonly property real damagePerMinute: totalDamageDealt / (totalGameDuration / 60 / 60)
  readonly property real damagePerStock: totalDamageDealt / totalStocksTaken

  readonly property real lCancels: statsData && statsData.lCancels || 0
  readonly property real lCancelsMissed: statsData && statsData.lCancelsMissed || 0
  readonly property real totalAerials: lCancels + lCancelsMissed
  readonly property real lCancelRate: totalAerials == 0 ? 0 : (lCancels / totalAerials)

  readonly property real edgeCancels: statsData && statsData.edgeCancelAerials + statsData.teeterCancelAerials || 0
  readonly property real edgeCancelRate: edgeCancels / totalAerials

  readonly property real nonCancelledAerials: totalAerials - lCancels - edgeCancels
  readonly property real nonCancelledAerialRate: nonCancelledAerials / totalAerials

  readonly property real numLedgedashes: statsData && statsData.numLedgedashes || 0
  readonly property real avgLedgedashes: totalReplaysFiltered == 0 ? 0 : (numLedgedashes / totalReplaysFiltered)
  readonly property real totalGalint: statsData && statsData.totalGalint || 0
  readonly property real avgGalint: numLedgedashes == 0 ? 0 : totalGalint / numLedgedashes

  property var charData: ({})
  readonly property var charDataCss: toCssCharData(charData)

  property var topPlayerTags: []
  property var topSlippiCodes: []

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
