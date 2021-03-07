import QtQuick 2.0
import Felgo 3.0

import Slippipedia 1.0

Column {
  AppListItem {
    text: "Data from all matched games"
    detailText: "Data calculated only from games matched by the selected filter. Click a tag/code to show all games with/vs that player."
    enabled: false
    backgroundColor: Theme.backgroundColor
  }

  SimpleSection {
    title: "Top player tags"
  }

  NameGrid {
    model: stats.statsPlayer.topPlayerTags
    columns: nameColumns

    namesClickable: true
    onNameClicked: showList({ name1: name, code1: "", name2: "", code2: "", exact: true })
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

    namesClickable: true
    onNameClicked: showList({ name1: "", code1: "", name2: name, code2: "", exact: true })
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

    namesClickable: true
    onNameClicked: showList({ name1: "", code1: "", name2: "", code2: name, exact: true })
  }

  Item {
    width: 1
    height: dp(Theme.contentPadding) / 2
  }
}
