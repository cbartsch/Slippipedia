import Felgo 3.0

import QtQuick 2.0
import QtQuick.Controls 2.12 as QC2

import "../controls"
import "../model"

BasePage {
  title: qsTr("Replay browser")

  property int numReplays: 25

  property var replayList: dataModel.getReplayList(numReplays, 0)

  AppListView {
    id: listView

    model: JsonListModel {
      id: listModel
      source: replayList
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
