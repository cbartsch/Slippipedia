import QtQuick 2.0
import Felgo 3.0

import Slippipedia 1.0

Column {
  AppListItem {
    text: "Data from all matched games"
    detailText: "Data calculated only from games matched by the selected filter."
    enabled: false
    backgroundColor: Theme.backgroundColor
  }

  SimpleSection {
    title: "Top player tags"
  }

  NameGrid {
    model: stats.statsPlayer.topPlayerTags
    columns: nameColumns
  }

  SimpleSection {
    title: "Top player tags (opponent)"
  }

  AppListItem {
    text: "No name filter configured."
    detailText: "Filter by Slippi code and/or name to see opposing player tags."

    visible: !dataModel.playerFilter.hasPlayerFilter
    onSelected: showFilteringPage()
  }

  NameGrid {
    visible: dataModel.playerFilter.hasPlayerFilter
    model: stats.statsOpponent.topPlayerTags
    columns: nameColumns
  }

  SimpleSection {
    title: "Top Slippi codes (opponent)"
  }

  AppListItem {
    text: "No name filter configured."
    detailText: "Filter by Slippi code and/or name to see opposing Slippi codes."

    visible: !dataModel.playerFilter.hasPlayerFilter
    onSelected: showFilteringPage()
  }

  NameGrid {
    visible: dataModel.playerFilter.hasPlayerFilter
    model: stats.statsOpponent.topSlippiCodes
    columns: nameColumns
  }

  Item {
    width: 1
    height: dp(Theme.contentPadding) / 2
  }
}
