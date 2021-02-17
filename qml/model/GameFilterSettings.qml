import QtQuick 2.0
import Felgo 3.0
import Qt.labs.settings 1.1

Item {
  id: filterSettings

  signal filterChanged

  property alias winnerPlayerIndex: settings.winnerPlayerIndex

  readonly property var winnerTexts: ({
                                        [-3]: "Any",
                                        [-2]: "No result",
                                        [-1]: "Either (no tie)",
                                        [0]: "Me",
                                        [1]: "Opponent",
                                      })

  readonly property var stageIds: settings.stageIds.map(id => ~~id)

  onStageIdsChanged: filterChanged()

  Settings {
    id: settings

    // -3 = any, -2 = tie, -1 = either (no tie), 0 = me, 1 = opponent
    property int winnerPlayerIndex: -1
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
