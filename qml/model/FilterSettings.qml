import QtQuick 2.0
import Felgo 3.0
import Qt.labs.settings 1.1

Item {
  id: filterSettings

  signal filterChanged

  property TextFilter slippiCode: TextFilter {
    id: slippiCode
    onPropertyChanged: filterChanged()
  }
  property TextFilter slippiName: TextFilter {
    id: slippiName
    onPropertyChanged: filterChanged()
  }
  property bool filterCodeAndName: true
  readonly property bool hasPlayerFilter: slippiCode.filterText != "" || slippiName.filterText != ""

  readonly property var charIds: settings.charIds.map(id => ~~id) // settings stores as list of string, convert to int
  readonly property var stageIds: settings.stageIds.map(id => ~~id)

  onFilterCodeAndNameChanged: filterChanged()
  onCharIdsChanged: filterChanged()
  onStageIdsChanged: filterChanged()

  readonly property string displayText: {
    var pText
    var codeText = slippiCode.filterText
    var nameText = slippiName.filterText

    if(codeText && nameText) {
      pText = qsTr("%1/%2").arg(codeText).arg(nameText)
    }
    else {
      pText = codeText || nameText || ""
    }

    var sText = null
    if(stageIds.length > 0) {
      sText = "Stages: " + stageIds.map(id => MeleeData.stageMap[id].name).join(", ")
    }

    var cText = null
    if(charIds.length > 0) {
      cText = "Characters: " + charIds.map(id => MeleeData.charNames[id]).join(", ")
    }

    return [pText, sText, cText].filter(_ => _).join("\n") || "(nothing)"
  }

  Settings {
    id: settings

    property alias slippiCodeText: slippiCode.filterText
    property alias slippiCodeCase: slippiCode.matchCase
    property alias slippiCodePartial: slippiCode.matchPartial

    property alias slippiNameText: slippiName.filterText
    property alias slippiNameCase: slippiName.matchCase
    property alias slippiNamePartial: slippiName.matchPartial

    property alias filterCodeAndName: filterSettings.filterCodeAndName // true: and, false: or

    property var charIds: []
    property var stageIds: []
  }

  function reset() {
    settings.stageIds = []
    settings.charIds = []
    slippiCode.reset()
    slippiName.reset()
  }

  // filtering

  function addCharFilter(charId) {
    settings.charIds = charIds.concat(charId)
  }

  function removeCharFilter(charId) {
    var list = charIds
    list.splice(list.indexOf(charId), 1)
    settings.charIds = list
  }

  function addStageFilter(stageId) {
    settings.stageIds = stageIds.concat(stageId)
  }

  function removeStageFilter(stageId) {
    var list = stageIds
    list.splice(list.indexOf(stageId), 1)
    settings.stageIds = list
  }
}
