import QtQuick 2.0
import Felgo 4.0

import Slippipedia 1.0

Item {
  id: playerStats

  property var statsData: ({})
  property bool isOpponent: false
  property DataBase dataBase: null

  property var openingMoves: null

  readonly property Stat stocksLost: Stat { name: "stocksLost" }
  readonly property Stat selfDestructs: Stat { name: "selfDestructs" }
  readonly property Stat stocksTaken: Stat { name: "stocksTaken" }

  readonly property real totalDamageDealt: statsData && statsData.damageDealt || 0
  readonly property real damagePerMinute: totalDamageDealt / (totalGameDuration / 60 / 60)
  readonly property real damagePerStock: stocksTaken.value == 0 ? 0 : statsData.totalKillPercent / stocksTaken.value

  readonly property real lCancels: statsData && statsData.lCancels || 0
  readonly property real lCancelsMissed: statsData && statsData.lCancelsMissed || 0
  readonly property real totalAerials: lCancels + lCancelsMissed
  readonly property real lCancelRate: totalAerials == 0 ? 0 : (lCancels / totalAerials)

  readonly property Stat lrasCount: Stat { name: "lrasCount" }

  readonly property Stat taunts: Stat { name: "taunts" }

  readonly property Stat pivots: Stat { name: "pivots" }
  readonly property Stat wavedashes: Stat { name: "wavedashes" }
  readonly property Stat wavelands: Stat { name: "wavelands" }
  readonly property Stat dashdances: Stat { name: "dashdances" }

  readonly property Stat airdodges: Stat { name: "airdodges" }
  readonly property Stat spotdodges: Stat { name: "spotdodges" }
  readonly property Stat rolls: Stat { name: "rolls" }

  readonly property Stat techs: Stat { name: "techs" }
  readonly property Stat missedTechs: Stat { name: "missedTechs" }
  readonly property Stat walltechs: Stat { name: "walltechs" }
  readonly property Stat walltechjumps: Stat { name: "walltechjumps" }
  readonly property Stat walljumps: Stat { name: "walljumps" }

  readonly property Stat openings: Stat { name: "openings" }
  readonly property real damagePerOpening: totalDamageDealt / openings.value
  readonly property real openingsPerKill: stocksTaken.value == 0 ? 0 : openings.value / stocksTaken.value

  readonly property real techRate: techs.value / (techs.value + missedTechs.value)

  readonly property Stat grabs: Stat { name: "grabs" }
  readonly property Stat grabsEscaped: Stat { name: "grabsEscaped" }
  readonly property real grabsEscapedRate: grabsEscaped.value / grabs.value

  readonly property real edgeCancels: statsData && statsData.edgeCancelAerials + statsData.teeterCancelAerials || 0
  readonly property real edgeCancelRate: edgeCancels / totalAerials

  readonly property real nonCancelledAerials: totalAerials - lCancels - edgeCancels
  readonly property real nonCancelledAerialRate: nonCancelledAerials / totalAerials

  readonly property real numLedgedashes: statsData && statsData.ledgedashes || 0
  readonly property real avgLedgedashes: totalReplaysFiltered == 0 ? 0 : (numLedgedashes / totalReplaysFiltered)
  readonly property real totalGalint: statsData && statsData.totalGalint || 0
  readonly property real maxGalint: statsData && statsData.maxGalint || 0
  readonly property real avgGalint: numLedgedashes == 0 ? 0 : totalGalint / numLedgedashes

  readonly property Stat actionsPerMinute: Stat { name: "totalActions"; count: totalGameDurationMinutes }
  readonly property Stat stateChangesPerMinute: Stat { name: "stateChanges"; count: totalGameDurationMinutes }
  readonly property Stat buttonsPressedPerMinute: Stat { name: "buttonsPressed"; count: totalGameDurationMinutes }
  readonly property Stat analogStickMovesPerMinute: Stat { name: "analogStickMoves"; count: totalGameDurationMinutes }
  readonly property Stat cStickMovesPerMinute: Stat { name: "cStickMoves"; count: totalGameDurationMinutes }

  readonly property Stat actions: Stat { name: "totalActions" }
  readonly property Stat stateChanges: Stat { name: "stateChanges" }
  readonly property Stat buttonsPressed: Stat { name: "buttonsPressed" }
  readonly property Stat analogStickMoves: Stat { name: "analogStickMoves" }
  readonly property Stat cStickMoves: Stat { name: "cStickMoves" }

  property var charData: ({})
  readonly property var charDataCss: toCssCharData(charData)

  readonly property var charDataAnalytics: charData ? Object.values(charData).map(
                                                        item => {
                                                          item.winRate = item.gamesFinished === 0
                                                            ? 0 : (item.gamesWon / item.gamesFinished)
                                                          return item
                                                        })
                                                    : []

  property var topPlayerTags: []
  property var topSlippiCodes: []

  function toCssCharData(charData) {
    if(!charData) {
      return []
    }

    // map DB results to css-viewable data
    return MeleeData.cssCharIds.map((id, index) => {
                                      var cd = charData[id] || { name: "", count: 0 }
                                      cd.id = id
                                      cd.winRate = cd.gamesWon / cd.gamesFinished
                                      return cd
                                    })
  }

  function refresh(limit) {
    charData = dataBase.getCharacterStats(isOpponent)
    topPlayerTags = dataBase.getTopPlayerTags(isOpponent, limit)
    topSlippiCodes = dataBase.getTopSlippiCodes(isOpponent, limit)
  }

  function refreshOpenings() {
    openingMoves = dataBase.getOpeningMoveSummary(isOpponent)
  }

  function clearOpenings() {
    openingMoves = null
  }
}
