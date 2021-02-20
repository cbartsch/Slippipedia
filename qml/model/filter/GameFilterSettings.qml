import QtQuick 2.0
import Felgo 3.0
import Qt.labs.settings 1.1

import "../data"

Item {
  id: filterSettings

  signal filterChanged

  property alias winnerPlayerIndex: settings.winnerPlayerIndex

  property alias startDateMs: settings.startDateMs
  property alias endDateMs: settings.endDateMs

  readonly property var winnerTexts: ({
                                        [-3]: "Any",
                                        [-2]: "No result",
                                        [-1]: "Either (no tie)",
                                        [0]: "Me",
                                        [1]: "Opponent",
                                      })

  readonly property var stageIds: settings.stageIds.map(id => ~~id)

  onStageIdsChanged: filterChanged()

  readonly property string displayText: {
    var sText = null
    if(stageIds.length > 0) {
      sText = "Stages: " + stageIds.map(id => MeleeData.stageMap[id].name).join(", ")
    }

    var wText = winnerPlayerIndex == -3
        ? "" : ("Winner: " + winnerTexts[winnerPlayerIndex])

    var sdText = startDateMs > 0 ? new Date(startDateMs).toLocaleString(Qt.locale(), "dd/MM/yyyy hh:mm") : ""
    var edText = endDateMs > 0 ? new Date(endDateMs).toLocaleString(Qt.locale(), "dd/MM/yyyy hh:mm") : ""

    var dText = sdText && edText
        ? sdText + " to " + edText
        : sdText
          ? "After " + sdText
          : edText
            ? "Before " + edText
            : ""

    dText = dText ? "Date: " + dText : ""

    return [sText, wText, dText].filter(_ => _).join("\n") || ""
  }

  Settings {
    id: settings

    // -3 = any, -2 = tie, -1 = either (no tie), 0 = me, 1 = opponent
    property int winnerPlayerIndex: -3
    property var stageIds: []

    // start and end date as Date.getTime() ms values
    property double startDateMs: -1
    property double endDateMs: -1
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
