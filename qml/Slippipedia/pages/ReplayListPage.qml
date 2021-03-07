import Felgo 3.0

import QtQuick 2.0
import QtQuick.Controls 2.12 as QC2

import Slippipedia 1.0

BasePage {
  id: replayListPage
  title: qsTr("Replay browser")

  property bool filterChangeable: true

  property int numReplays: 25

  property var replayList: []

  property var sectionData: ({})

  property bool hasMore: true

  readonly property string currentSection: navigationStack.currentPage && navigationStack.currentPage.section || ""

  // load first page when showing this page
  onSelected: if(replayList.length == 0) loadMore()
  onPushed: if(replayList.length == 0) loadMore()

  filterModal.onClosed: if(stats) refresh()

  rightBarItem: NavigationBarRow {
    LoadingIcon {
    }
    IconButtonBarItem {
      icon: IconType.filter
      onClicked: showFilteringPage()
      visible: filterChangeable
    }
    IconButtonBarItem {
      icon: IconType.refresh
      onClicked: refresh()
    }
  }


  Column {
    id: header
    width: parent.width

    FilterInfoItem {
      stats: replayListPage.stats
      clickable: filterChangeable
    }
  }


  AppListView {
    id: listView

    anchors.fill: parent
    anchors.topMargin: header.height

    model: JsonListModel {
      id: listModel
      source: replayList
      keyField: "id"
    }

    // labels at start are kinda bugged
    section.labelPositioning: ViewSection.InlineLabels// | ViewSection.CurrentLabelAtStart
    section.criteria: ViewSection.FullString
    section.property: "section"
    section.delegate: ReplaySectionHeader {
      sData: sectionData[section] || emptySection
      checked: currentSection === section

      onShowStats: {
        sessionFilter.copyFrom(replayListPage.stats.dataBase.filterSettings)

        // TODO find out why it can be off by a minute (or the seconds are truncated)
        sessionFilter.gameFilter.startDateMs = sData.dateFirst.getTime() - 1000 * 60
        sessionFilter.gameFilter.endDateMs = sData.dateLast.getTime() + 1000 * 60

        sessionFilter.playerFilter.slippiCode.filterText = sData.code1
        sessionFilter.playerFilter.slippiName.filterText = sData.name1
        sessionFilter.opponentFilter.slippiCode.filterText = sData.code2
        sessionFilter.opponentFilter.slippiName.filterText = sData.name2

        navigationStack.push(statisticsPageC, {
                               section: section
                             })
      }
    }

    delegate: ReplayListItem {
    }

    footer: AppListItem {
      text: hasMore ? "Load more replays..." : "No more replays."
      onSelected: loadMore()

      enabled: hasMore
      backgroundColor: hasMore ? Theme.controlBackgroundColor : Theme.backgroundColor
    }

    add: Transition {
      PropertyAnimation {
        property: "opacity"
        from: 0
        to: 1
      }
    }
  }

  FilterSettings {
    id: sessionFilter

    playerFilter: PlayerFilterSettings {
      settingsCategory: "session-player-filter"
      filterCodeAndName: false
    }

    opponentFilter: PlayerFilterSettings {
      settingsCategory: "session-opponent-filter"
      filterCodeAndName: false
    }

    gameFilter: GameFilterSettings {
      settingsCategory: "session-game-filter"
    }
  }

  ReplayStats {
    id: sessionStats

    dataBase: DataBase {
      filterSettings: sessionFilter
    }
  }

  Component {
    id: statisticsPageC

    StatisticsPage {
      id: statisticsPage
      property string section: ""

      filterChangeable: false
      stats: sessionStats
    }
  }

  function clear() {
    listView.positionViewAtBeginning()
    replayList = []
    sectionData = {}
    hasMore = true
  }

  function loadMore() {
    var loaded = stats.dataBase.getReplayList(numReplays, replayList.length)

    if(!loaded || loaded.length === 0) {
      hasMore = false
      return
    }

    // adapt model with extra data for list view (sections, ...)
    var adapted = loaded.map(item => {
                               var section = dataModel.playersText(item)

                               if(!(section in sectionData)) {
                                 sectionData[section] = {
                                   name1: item.name1,
                                   code1: item.code1,
                                   name2: item.name2,
                                   code2: item.code2,
                                   chars1: {},
                                   chars2: {},
                                   dateLast: item.date,
                                   numGames: 0,
                                   gamesFinished: 0,
                                   gamesWon: 0
                                 }
                               }

                               sectionData[section].chars1[item.char1] = item.skin1
                               sectionData[section].chars2[item.char2] = item.skin2
                               sectionData[section].dateFirst = item.date
                               sectionData[section].numGames++

                               if(item.winnerPort >= 0) {
                                 sectionData[section].gamesFinished++
                               }

                               if(item.winnerPort === item.port1) {
                                 sectionData[section].gamesWon++
                               }

                               item.section = section

                               return item
                             })

    replayList.push.apply(replayList, adapted)

    replayListChanged()
  }

  function refresh() {
    clear()

    loadMore()
  }
}
