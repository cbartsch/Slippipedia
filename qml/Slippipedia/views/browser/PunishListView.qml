import QtQuick 2.0
import Felgo 3.0

import Slippipedia 1.0

Item {
  id: punishListView

  property var punishList: []

  property alias count: listView.count

  property int numPunishes: 25

  property var sectionData: ({})

  property bool hasMore: true

  property bool isLoading: false

  readonly property string currentSection: navigationStack.currentPage && navigationStack.currentPage.section || ""

  property string prevSessionSection: ""

  Connections {
    target: dataModel

    onIsProcessingChanged: refresh()
  }

  AppListItem {
    id: header

    text: qsTr("%1%2 punishes found.")
    .arg(listView.count)
    .arg(hasMore ? "+" : "")

    detailText: "Set up punish filter to refine your search."

    onSelected: {
      filterModal.showTab(4)
      filterModal.open()
    }

    rightItem: Row {
      height: parent.height

      AppToolButton {
        height: width
        anchors.verticalCenter: parent.verticalCenter

        iconType: IconType.play
        toolTipText: "Replay all punishes"

        visible: dataModel.hasDesktopApp
        onClicked: dataModel.replayPunishes(punishList)
      }

      AppToolButton {
        id: toolBtnSetup
        iconType: IconType.gear
        toolTipText: "Set Slippi Desktop App folder to replay punishes."
        height: width
        anchors.verticalCenter: parent.verticalCenter

        visible: !dataModel.hasDesktopApp
        onClicked: showSetup()
      }
    }
  }

  AppListView {
    id: listView
    anchors.fill: parent
    anchors.topMargin: header.height

    model: SortFilterProxyModel {
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

      ReplaySectionHeader {
        sectionModel: sectionData[section] || {}
        height: dp(64)
        statsButtonVisible: false

      // sections having different heights is buggy...
      //  visible: model.showNames
      }

      ReplayListItem {
        replayModel: sectionData[section] || {}

        toolBtnOpen.toolTipText: "Replay all punishes"

        onOpenReplayFolder: dataModel.openReplayFolder(filePath)
        onOpenReplayFile: dataModel.replayPunishes(sectionData[section].punishes)
      }
    }

    delegate: PunishListItem {
      punishModel: model
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
      style: Text.Outline
      styleColor: "black"
    }
  }

  function clear() {
    listView.positionViewAtBeginning()
    punishList = []
    sectionData = {}
    hasMore = true
    prevSessionSection = ""
  }

  function loadMore() {
    isLoading = true

    loadTimer.start()
  }

  Timer {
    id: loadTimer
    interval: 250

    onTriggered: doLoadMore()
  }

  function doLoadMore() {
    var loaded = stats.dataBase.getPunishList(numPunishes, punishList.length)

    isLoading = false

    if(!loaded || loaded.length === 0) {
      hasMore = false
      return
    }

    // adapt model with extra data for list view (sections, ...)
    var adapted = loaded.map(item => {
                               var sessionSection = dataModel.playersText(item)
                               var section = dataModel.formatDate(item.date) + " - " + sessionSection

                               var isNewSession = sessionSection !== prevSessionSection
                               prevSessionSection = sessionSection

                               if(!(section in sectionData)) {
                                 sectionData[section] = item
                                 sectionData[section].chars1 = { [item.char1] : item.skin1 }
                                 sectionData[section].chars2 = { [item.char2] : item.skin2 }
                                 sectionData[section].punishes = [item]
                                 sectionData[section].showNames = isNewSession
                               }
                               else {
                                 sectionData[section].punishes.push(item)
                               }

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
