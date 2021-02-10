import Felgo 3.0

import QtQuick 2.0

import Slippi 1.0

import "model"
import "pages"

App {
  id: app

  onInitTheme: {
    Theme.colors.tintColor = "#21BA45" // slippi green

    // dark theme
    Theme.colors.textColor = "white"
    Theme.colors.secondaryTextColor = "#888"
    Theme.colors.secondaryBackgroundColor = "#222"
    Theme.colors.controlBackgroundColor = "#111"
    Theme.colors.dividerColor = "#222"
    Theme.colors.selectedBackgroundColor = "#888"
    Theme.colors.backgroundColor = "black"

    Theme.colors.inputCursorColor = "white"

    Theme.listItem.backgroundColor = Theme.controlBackgroundColor

    Theme.navigationTabBar.titleOffColor= "white"
    Theme.navigationTabBar.backgroundColor = Theme.controlBackgroundColor
  }

  DataModel {
    id: dataModel
  }

  Navigation {
    id: navigation
    navigationMode: navigationModeTabs

    NavigationItem {
      title: "Replay Database"
      icon: IconType.database

      NavigationStack {
        DatabasePage { }
      }
    }

    NavigationItem {
      id: filteringItem
      title: "Filtering"
      icon: IconType.filter

      NavigationStack {
        FilterPage { }
      }
    }

    NavigationItem {
      title: "Statistics"
      icon: IconType.barchart

      NavigationStack {
        StatisticsPage { }
      }
    }

    NavigationItem {
      title: "Browser"
      icon: IconType.list

      onSelected: if(page) page.selected()
      onPageChanged: if(page) page.selected()

      NavigationStack {
        ReplayListPage { }
      }
    }
  }

  function showFilteringPage() {
    navigation.currentIndex = 1
  }
}
