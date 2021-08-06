import QtQuick 2.0
import Felgo 3.0

import Slippipedia 1.0

Item {
  property var replayList: []

  property alias count: listView.count

  property int numReplays: 25

  property var sectionData: ({})

  property bool hasMore: true

  readonly property string currentSection: navigationStack.currentPage && navigationStack.currentPage.section || ""


  Connections {
    target: dataModel

    onIsProcessingChanged: refresh()
  }

  AppListView {
    id: listView
    anchors.fill: parent

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
      sectionModel: sectionData[section] || emptySection
      checked: currentSection === section
      height: dp(110)

      onShowStats: app.showStats({
                                   code1: sectionModel.code1,
                                   name1: sectionModel.name1,
                                   code2: sectionModel.code2,
                                   name2: sectionModel.name2,
                                   // TODO find out why it can be off by a minute (or the seconds are truncated)
                                   startMs: sectionModel.dateFirst.getTime() - 1000 * 60,
                                   endMs: sectionModel.dateLast.getTime() + 1000 * 60
                                 })
    }

    delegate: ReplayListItem {
      onOpenReplayFolder: dataModel.openReplayFolder(filePath)
      onOpenReplayFile: dataModel.openReplayFile(filePath)
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

                               while(section in sectionData) {
                                 var sData = sectionData[section]

                                 // item.duration is in frames - calculate ms
                                 var gameDurationMs = item.duration / 60 * 1000

                                 // calculate time between first game of current session and this game's start time minus its duration
                                 var tDiff = sData.dateFirst.getTime() - item.date.getTime() - gameDurationMs

                                 var intervalMs = stats.dataBase.gameFilter.sessionSplitIntervalMs
                                 if(intervalMs > 0 && tDiff > intervalMs) {
                                   // time between games is greater than the session split interval

                                   section += "2"
                                 }
                                 else {
                                   break
                                 }
                               }

                               if(!(section in sectionData)) {
                                 sectionData[section] = {
                                   name1: item.name1,
                                   tag1: item.tag1,
                                   code1: item.code1,
                                   port1: item.port1,
                                   name2: item.name2,
                                   tag2: item.tag2,
                                   code2: item.code2,
                                   port2: item.port2,
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
