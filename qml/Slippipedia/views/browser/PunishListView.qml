import QtQuick 2.0
import Felgo 3.0

import Slippipedia 1.0

Item {
  property var punishList: []

  property alias count: listView.count

  property int numPunishes: 50

  property var sectionData: ({})

  property bool hasMore: true

  readonly property string currentSection: navigationStack.currentPage && navigationStack.currentPage.section || ""

  AppListView {
    id: listView
    anchors.fill: parent

    model: SortFilterProxyModel {
//      filters: ExpressionFilter {
//        expression: model.numMoves > 1
//      }

      sourceModel: JsonListModel {
        source: punishList
        keyField: "id"
      }
    }

    // labels at start are kinda bugged
    section.labelPositioning: ViewSection.InlineLabels// | ViewSection.CurrentLabelAtStart
    section.criteria: ViewSection.FullString
    section.property: "section"
    section.delegate: SimpleSection {
//      sData: sectionData[section] || emptySection
//      checked: currentSection === section

//      onShowStats: app.showStats({
//                                   code1: sData.code1,
//                                   name1: sData.name1,
//                                   code2: sData.code2,
//                                   name2: sData.name2,
//                                   // TODO find out why it can be off by a minute (or the seconds are truncated)
//                                   startMs: sData.dateFirst.getTime() - 1000 * 60,
//                                   endMs: sData.dateLast.getTime() + 1000 * 60
//                                 })
    }

    delegate: AppListItem {
      text: qsTr("%1 moves, %2 %%3 (%4)")
      .arg(model.numMoves).arg(model.damage)
      .arg(model.didKill ? " killed " + MeleeData.killDirectionNames[model.killDirection] : "")
      .arg(MeleeData.dynamicNames[model.openingDynamic])

      detailText: qsTr("%1: %4 - %2: %5 (%3)")
      .arg(dataModel.formatTime(model.startFrame))
      .arg(dataModel.formatTime(model.endFrame))
      .arg(dataModel.formatTime(model.duration))
      .arg(MeleeData.moveNames[model.openingMoveId])
      .arg(MeleeData.moveNames[model.lastMoveId])

      enabled: false
      backgroundColor: Theme.backgroundColor
    }

    footer: AppListItem {
      text: hasMore ? "Load more punishes..." : "No more punishes."
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
    punishList = []
    sectionData = {}
    hasMore = true
  }

  function loadMore() {
    var loaded = stats.dataBase.getPunishList(numPunishes, punishList.length)

    if(!loaded || loaded.length === 0) {
      hasMore = false
      return
    }

    // adapt model with extra data for list view (sections, ...)
    var adapted = loaded.map(item => {
                               var section = item.replayId // TODO sensible section name for replay
                               section = dataModel.formatDate(item.date) + " - " + dataModel.playersText(item)

//                               if(!(section in sectionData)) {
//                                 sectionData[section] = {
//                                   name1: item.name1,
//                                   code1: item.code1,
//                                   name2: item.name2,
//                                   code2: item.code2,
//                                   chars1: {},
//                                   chars2: {},
//                                   dateLast: item.date,
//                                   numGames: 0,
//                                   gamesFinished: 0,
//                                   gamesWon: 0
//                                 }
//                               }

//                               sectionData[section].chars1[item.char1] = item.skin1
//                               sectionData[section].chars2[item.char2] = item.skin2
//                               sectionData[section].dateFirst = item.date
//                               sectionData[section].numGames++

//                               if(item.winnerPort >= 0) {
//                                 sectionData[section].gamesFinished++
//                               }

//                               if(item.winnerPort === item.port1) {
//                                 sectionData[section].gamesWon++
//                               }

                               item.section = section

                               return item
                             })

    punishList.push.apply(punishList, adapted)

    punishListChanged()
  }

  function refresh() {
    clear()

    loadMore()
  }
}
