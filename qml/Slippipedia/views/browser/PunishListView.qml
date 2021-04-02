import QtQuick 2.0
import Felgo 3.0

import Slippipedia 1.0

Item {
  id: punishListView

  property var punishList: []

  property alias count: listView.count

  property int numPunishes: 50

  property var sectionData: ({})

  property bool hasMore: true

  property bool isLoading: false

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

    section.delegate: Column {
      width: parent.width

      PlayerInfoRow {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.contentPadding
        height: dp(48)

        model: sectionData[section] || {}
      }

      ReplayListItem {
        replayModel: sectionData[section] || {}
      }
    }

    delegate: AppListItem {
      text: qsTr("%1 moves, %2% %3 (Opening: %4)")
      .arg(model.numMoves).arg(model.damage)
      .arg(model.didKill ? " killed " + MeleeData.killDirectionNames[model.killDirection] : "")
      .arg(MeleeData.dynamicNames[model.openingDynamic])

      detailText: qsTr("%1: %4 - %2: %5 (%3)")
      .arg(dataModel.formatTime(model.startFrame))
      .arg(dataModel.formatTime(model.endFrame))
      .arg(dataModel.formatTime(model.punishDuration))
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

  Rectangle {
    anchors.fill: parent
    color: "#80000000"
    visible: punishListView.isLoading

    AppText {
      anchors.centerIn: parent
      text: "Loading punishes..."
      font.pixelSize: sp(32)
    }
  }

  function clear() {
    listView.positionViewAtBeginning()
    punishList = []
    sectionData = {}
    hasMore = true
  }

  function loadMore() {
    isLoading = true

    loadTimer.start()
  }

  Timer {
    id: loadTimer
    interval: 500

    onTriggered: doLoadMore()
  }

  function doLoadMore() {
    var loaded = stats.dataBase.getPunishList(numPunishes, punishList.length)

    if(!loaded || loaded.length === 0) {
      hasMore = false
      return
    }

    // adapt model with extra data for list view (sections, ...)
    var adapted = loaded.map(item => {
                               var section = item.replayId // TODO sensible section name for replay
                               section = dataModel.formatDate(item.date) + " - " + dataModel.playersText(item)

                               if(!(section in sectionData)) {
                                 sectionData[section] = item
                                 sectionData[section].chars1 = { [item.char1] : item.skin1 }
                                 sectionData[section].chars2 = { [item.char2] : item.skin2 }
                               }

                               item.section = section

                               return item
                             })

    punishList.push.apply(punishList, adapted)

    punishListChanged()

    isLoading = false
  }

  function refresh() {
    clear()

    loadMore()
  }
}
