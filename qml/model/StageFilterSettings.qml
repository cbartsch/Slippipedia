import QtQuick 2.0
import Felgo 3.0
import Qt.labs.settings 1.1

Item {
  id: filterSettings

  signal filterChanged

  readonly property var stageIds: settings.stageIds.map(id => ~~id)

  onStageIdsChanged: filterChanged()

  Settings {
    id: settings

    property var stageIds: []
  }

  function reset() {
    settings.stageIds = []
  }

  function addStage(stageId) {
    settings.stageIds = stageIds.concat(stageId)
  }

  function removeStage(stageId) {
    var list = stageIds
    list.splice(list.indexOf(stageId), 1)
    settings.stageIds = list
  }
}
