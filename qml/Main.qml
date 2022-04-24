import Felgo 3.0

import QtQuick 2.0
import QtQuick.Controls.Styles 1.4

import Slippipedia 1.0

App {
  id: app

  readonly property real splitPaneWidth: dp(500)
  readonly property bool useSplitMode: width > dp(1000)

  width: dp(1024)
  height: dp(768)

  storeWindowGeometry: true

  title: "Slippipedia " + Constants.versionName

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

    Theme.appButton.rippleEffect = true
    Theme.appButton.horizontalMargin = 0
    Theme.appButton.horizontalPadding = dp(2)
  }

  GoogleAnalytics {
    id: analytics
    propertyId: "UA-163972040-2"
  }

  DataModel {
    id: dataModel

    // if DB has no replays, show DB page, otherwise, go to stats directly
    onInitialized: navigation.currentIndex = stats.totalReplays > 0 && !dataModel.dbNeedsUpdate
                   ? navigation.count - 2 : 0
  }

  Rectangle {
    anchors.fill: parent
    color: Theme.backgroundColor
  }

  // global mouse back button handling:
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.BackButton

    onClicked: {
      if(mouse.button === Qt.BackButton) {
        var stack = navigation.currentNavigationItem && navigation.currentNavigationItem.navigationStack || null
        if(stack && stack.depth > 1) {
          stack.pop()
          mouse.accepted = true
          return
        }
      }
      mouse.accepted = false
    }
  }

  Navigation {
    id: navigation
    navigationMode: navigationModeTabs

    onCurrentNavigationItemChanged: if(currentNavigationItem) currentNavigationItem.page.appeared()

    NavigationItem {
      title: "Setup"

      onSelected: if(page) page.selected()

      iconComponent: CustomTabIcon {
        iconType: IconType.gear
        selected: navigation.currentIndex === 0
        badgeValue: dataModel.newFiles.length || ""
      }

      BaseNavigationStack {
        SetupPage {
        }
      }
    }

    NavigationItem {
      title: "Statistics"
      icon: IconType.barchart

      onSelected: if(page) page.selected()

      BaseNavigationStack {
        StatisticsPage {
          stats: dataModel.stats
        }
      }
    }

    NavigationItem {
      title: "Analytics"
      icon: IconType.lightbulbo

      onSelected: if(page) page.selected()

      BaseNavigationStack {
        AnalyticsPage {
          stats: dataModel.stats
        }
      }
    }

    NavigationItem {
      title: "Browser"
      icon: IconType.list

      onSelected: if(page) page.selected()

      BaseNavigationStack {
        BrowserPage {
          stats: dataModel.stats
        }
      }
    }

    NavigationItem {
      title: "About"
      icon: IconType.exclamationcircle

      onSelected: if(page) page.selected()

      BaseNavigationStack {
        AboutPage {
          stats: dataModel.stats
        }
      }
    }
  }

  // additional pages with custom filters to push to the current stack:

  Component {
    id: statisticsPageC

    StatisticsPage {
      property var filterData: ({})

      filterChangeable: true

      stats: ReplayStats {
        dataBase: DataBase {
          filterSettings: FilterSettings {
            id: customFilter

            persistenceEnabled: false
          }
        }
      }

      Component.onCompleted: customFilter.setFromData(filterData)
    }
  }

  Component {
    id: browserPageC

    BrowserPage {
      property var filterData: ({})

      filterChangeable: true

      stats: ReplayStats {
        dataBase: DataBase {
          filterSettings: FilterSettings {
            id: customFilter

            persistenceEnabled: false
          }
        }
      }

      Component.onCompleted: customFilter.setFromData(filterData)
    }
  }

  function showSetup() {
    navigation.currentIndex = 0
  }

  function showPage(page, filterData) {
    var stack = navigation.currentNavigationItem.navigationStack

    if(stack) {
      stack.push(page, { filterData: filterData })
    }
  }

  // show list view for specific char, opponent char, stage and/or month of year
  function showList(filterData) {
    showPage(browserPageC, filterData)
  }

  // show stats view for specific char, opponent char, stage and/or month of year
  function showStats(filterData) {
    showPage(statisticsPageC, filterData)
  }

  function isNan(number) {
    return number !== number
  }

  function isDateValid(date) {
    return date && !isNan(date.getTime())
  }

  function logPage(title) {
    console.log("log page:", title)

    analytics.logScreen(title)
  }

  // case insensitive equal for 2 strings
  function ciEqual(a, b) {
    return a.toLowerCase() === b.toLowerCase()
  }
}
