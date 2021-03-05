import QtQuick 2.0
import Felgo 3.0
import "../grids"

Column {

  AppListItem {
    text: "Stats from all matched games"
    detailText: "All numbers are averaged per game, unless specified otherwise."
    enabled: false
    backgroundColor: Theme.backgroundColor
  }

  StatsGrid {
    width: parent.width

    title: "Stocks"

    statsList: [ stats.statsPlayer, stats.statsOpponent ]

    rowData: [
      { header: "Stocks taken", property: "stocksTaken", type: "stat" },
      { header: "Stocks lost", property: "stocksLost", type: "stat" },
      { header: "SDs", property: "selfDestructs", type: "stat" },
    ]
  }

  StatsGrid {
    width: parent.width

    title: "Offensive"

    statsList: [ stats.statsPlayer, stats.statsOpponent ]

    rowData: [
      // { header: "Total damage dealt", property: "totalDamageDealt", type: "number" },
      { header: "Damage per opening", property: "damagePerOpening", type: "decimal" },
      { header: "Openings per kill", property: "openingsPerKill", type: "decimal" },
      { header: "Avg. Kill %", property: "damagePerStock", type: "decimal" },
      { header: "Damage / minute", property: "damagePerMinute", type: "decimal" },
      { header: "Connected grabs", property: "grabs", type: "stat" },
      { header: "Grabs opponent escaped", property: "grabsEscapedRate", type: "percentage" },
    ]
  }

  StatsGrid {
    width: parent.width

    title: "Tech skill"

    statsList: [ stats.statsPlayer, stats.statsOpponent ]

    rowData: [
      { header: "Aerials L-cancelled", property: "lCancelRate", type: "percentage" },
      { header: "Edge/teeter-cancelled", property: "edgeCancelRate", type: "percentage" },
      { header: "Laggy aerials", property: "nonCancelledAerialRate", type: "percentage" },
      { header: "Intangible ledgedashes / game", property: "avgLedgedashes", type: "decimal" },
      { header: "Average GALINT", property: "avgGalint", type: "decimal" },
    ]
  }

  StatsGrid {
    width: parent.width

    title: "Movement"

    statsList: [ stats.statsPlayer, stats.statsOpponent ]

    rowData: [
      { header: "Wavedashes", property: "wavedashes", type: "stat" },
      { header: "Wavelands", property: "wavelands", type: "stat" },
      { header: "Dashdances ", property: "dashdances", type: "stat" },
      { header: "Pivots", property: "pivots", type: "stat" },
    ]
  }

  StatsGrid {
    width: parent.width

    title: "Defensive"

    statsList: [ stats.statsPlayer, stats.statsOpponent ]

    rowData: [
      { header: "Rolls", property: "rolls", type: "stat" },
      { header: "Spotdodges", property: "spotdodges", type: "stat" },
      { header: "Airdodges", property: "airdodges", type: "stat" },
      { header: "Techs", property: "techs", type: "stat" },
      { header: "Missed techs", property: "missedTechs", type: "stat" },
      { header: "Tech rate", property: "techRate", type: "percentage" },
      { header: "Walltechs", property: "walltechs", type: "stat" },
      { header: "Walltechjumps", property: "walltechjumps", type: "stat" },
      { header: "Walljumps", property: "walljumps", type: "stat" },
    ]
  }

  StatsGrid {
    width: parent.width

    title: "Other stats"

    statsList: [ stats.statsPlayer, stats.statsOpponent ]

    rowData: [
      { header: "Taunts", property: "taunts", type: "stat" },
    ]
  }

  Item {
    width: parent.width
    height: dp(Theme.contentPadding)
  }
}
