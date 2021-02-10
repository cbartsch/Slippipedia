import Felgo 3.0

import QtQuick 2.0
import QtQuick.Controls 2.12 as QC2

import "../controls"
import "../model"

BasePage {
  title: qsTr("Replay browser")

  property int numReplays: 25

  property var replayList: []

  Connections {
    target: dataModel

    // reset list when filter changes
    onFilterChanged: replayList = []
  }

  // load first page when showing this page
  onSelected: loadMore()

  AppListView {
    id: listView

    model: JsonListModel {
      id: listModel
      source: replayList
      keyField: "id"
    }

    delegate: ReplayListItem { }

    footer: AppListItem {
      text: "Load more replays..."
      onSelected: loadMore()
    }
  }

  function loadMore() {
    var loaded = dataModel.getReplayList(numReplays, replayList.length)

    replayList.push.apply(replayList, loaded)

    replayListChanged()
  }
}
