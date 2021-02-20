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

    Theme.tabBar.backgroundColor = Theme.backgroundColor

    Theme.listItem.backgroundColor = Theme.controlBackgroundColor

    Theme.navigationTabBar.titleOffColor= "white"
    Theme.navigationTabBar.backgroundColor = Theme.controlBackgroundColor
  }

  GoogleAnalytics {
    propertyId: "UA-163972040-2"

    onPluginLoaded: {
      console.log("GA log main screen")
      logScreen("Main")
    }
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
        DatabasePage {
        }
      }
    }

    // filtering is currently not a main navigation item but a modal in the pages where it's relevant
//    NavigationItem {
//      id: filteringItem
//      title: "Filtering"
//      icon: IconType.filter

//      NavigationStack {
//        FilterPage {
//          stats: dataModel.stats
//        }
//      }
//    }

    NavigationItem {
      title: "Statistics"
      icon: IconType.barchart

      onSelected: if(page) page.selected()
      onPageChanged: if(page) page.selected()

      NavigationStack {
        StatisticsPage {
          stats: dataModel.stats
        }
      }
    }

    NavigationItem {
      title: "Browser"
      icon: IconType.list

      onSelected: if(page) page.selected()
      onPageChanged: if(page) page.selected()

      NavigationStack {
        id: stack

        ReplayListPage {
          stats: dataModel.stats
        }
      }
    }
  }

  function isNan(number) {
    return number !== number
  }

  function isDateValid(date) {
    return date && !isNan(date.getTime())
  }
}
