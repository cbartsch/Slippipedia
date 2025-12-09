import QtQuick 2.0
import Felgo 4.0

import Slippipedia 1.0

Column {

  SimpleSection {
    title: "Top slippi codes"
  }

  NameGrid {
    model: stats.statsPlayer.topSlippiCodes
    columns: nameColumns

    namesClickable: true
    onNameClicked: name => showList({ code1: name, name1: ciEqual(name, stats.dataBase.filterSettings.playerFilter.slippiCode.filterText) ? "" : undefined,
                                      exact: true, sourceFilter: stats.dataBase.filterSettings })
  }

  SimpleSection {
    title: "Top player tags"
  }

  NameGrid {
    model: stats.statsPlayer.topPlayerTags
    columns: nameColumns

    namesClickable: true
    onNameClicked: name => showList({ name1: name, code1: ciEqual(name, stats.dataBase.filterSettings.playerFilter.slippiName.filterText) ? "" : undefined,
                                      exact: true, sourceFilter: stats.dataBase.filterSettings })
  }

  SimpleSection {
    title: "Top Slippi codes (opponent)"
  }

  AppListItem {
    text: "No player filter configured."
    detailText: "Filter by player code, name or port to see opposing Slippi codes."

    visible: !dataModel.playerFilter.hasPlayerFilter
    onSelected: showFilteringPage(0)
  }

  NameGrid {
    visible: dataModel.playerFilter.hasPlayerFilter
    model: stats.statsOpponent.topSlippiCodes
    columns: nameColumns
    isOpponent: true

    namesClickable: true
    onNameClicked: name => showList({ code2: name, name2: ciEqual(name, stats.dataBase.filterSettings.opponentFilter.slippiCode.filterText) ? "" : undefined,
                                      exact: true, sourceFilter: stats.dataBase.filterSettings })
  }

  SimpleSection {
    title: "Top player tags (opponent)"
  }

  AppListItem {
    text: "No player filter configured."
    detailText: "Filter by player code, name or port to see opposing player tags."

    visible: !dataModel.playerFilter.hasPlayerFilter
    onSelected: showFilteringPage(0)
  }

  NameGrid {
    visible: dataModel.playerFilter.hasPlayerFilter
    model: stats.statsOpponent.topPlayerTags
    columns: nameColumns
    isOpponent: true

    namesClickable: true
    onNameClicked: name => showList({ name2: name, code2: ciEqual(name, stats.dataBase.filterSettings.opponentFilter.slippiName.filterText) ? "" : undefined,
                                      exact: true, sourceFilter: stats.dataBase.filterSettings })
  }

  Item {
    width: 1
    height: dp(Theme.contentPadding) / 2
  }
}
