import Felgo 3.0

import QtQuick 2.0
import QtQuick.Controls 2.12 as QC2

import "../controls"
import "../model"

BasePage {
  id: replayListPage
  title: qsTr("Replay browser")

  property int numReplays: 25

  property var replayList: []

  property var sectionData: ({})

  // load first page when showing this page
  onSelected: if(replayList.length == 0) loadMore()

  Connections {
    target: dataModel.filter

    // clear list when filter changes
    onFilterChanged: refresh()
  }

  rightBarItem: NavigationBarRow {
    LoadingIcon {
    }
    IconButtonBarItem {
      icon: IconType.filter
      onClicked: showFilteringPage()
    }
    IconButtonBarItem {
      icon: IconType.refresh
      onClicked: refresh()
    }
  }

  AppListView {
    id: listView

    model: JsonListModel {
      id: listModel
      source: replayList
      keyField: "id"
    }

    section.labelPositioning: ViewSection.InlineLabels | ViewSection.CurrentLabelAtStart
    section.property: "section"
    section.criteria: ViewSection.FullString
    section.delegate: ReplaySectionHeader {
      sData: sectionData[section] || {}
    }

    delegate: ReplayListItem {
    }


    header: FilterInfoItem {
      stats: replayListPage.stats
      clickable: true
    }

    footer: AppListItem {
      text: "Load more replays..."
      onSelected: loadMore()
    }

    add: Transition {
      PropertyAnimation {
        property: "opacity"
        from: 0
        to: 1
      }
    }
  }

  function clear() {
    listView.positionViewAtBeginning()
    replayList = []
    sectionData = {}
  }

  function loadMore() {
    var loaded = dataModel.getReplayList(numReplays, replayList.length)

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

                               // TODO are we always port 0?
                               if(item.winnerPort === 0) {
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
