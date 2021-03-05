import QtQuick 2.0
import Felgo 3.0
import Qt.labs.settings 1.1

import Slippipedia 1.0

Item {
  id: playerFilterSettings

  signal filterChanged

  property alias settingsCategory: settings.category

  property TextFilter slippiCode: TextFilter {
    id: slippiCode
    onPropertyChanged: filterChanged()
  }
  property TextFilter slippiName: TextFilter {
    id: slippiName
    onPropertyChanged: filterChanged()
  }
  property bool filterCodeAndName: true

  readonly property bool hasFilter: hasPlayerFilter || hasCharFilter
  readonly property bool hasPlayerFilter: slippiCode.filterText != "" || slippiName.filterText != ""
  readonly property bool hasCharFilter: charIds && charIds.length > 0

  readonly property var charIds: settings.charIds.map(id => ~~id) // settings stores as list of string, convert to int

  onFilterCodeAndNameChanged: filterChanged()
  onCharIdsChanged: filterChanged()

  readonly property string displayText: {
    var pText
    var codeText = slippiCode.filterText
    var nameText = slippiName.filterText

    if(codeText && nameText) {
      pText = qsTr("%1%2%3")
      .arg(codeText)
      .arg(filterCodeAndName ? " & " : " / ")
      .arg(nameText)
    }
    else {
      pText = codeText || nameText || ""
    }

    if(pText) {
      pText = "\"" + pText + "\""
    }

    var cText = null
    if(charIds.length > 0) {
      cText = charIds.map(id => MeleeData.charNames[id]).join(", ")
    }

    return [pText, cText].filter(_ => _).join(", ") || ""
  }

  Settings {
    id: settings

    property alias slippiCodeText: slippiCode.filterText
    property alias slippiCodeCase: slippiCode.matchCase
    property alias slippiCodePartial: slippiCode.matchPartial

    property alias slippiNameText: slippiName.filterText
    property alias slippiNameCase: slippiName.matchCase
    property alias slippiNamePartial: slippiName.matchPartial

    property alias filterCodeAndName: playerFilterSettings.filterCodeAndName // true: and, false: or

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

  function setCharFilter(charId) {
    settings.charIds = charId
  }

  function addCharFilter(charId) {
    settings.charIds = charIds.concat(charId)
  }

  function removeCharFilter(charId) {
    var list = charIds
    list.splice(list.indexOf(charId), 1)
    settings.charIds = list
  }

  function removeAllCharFilters() {
    settings.charIds = []
  }

  // DB filtering functions

  function getPlayerFilterCondition(tableName) {
    var cf = slippiCode.makeFilterCondition(tableName + ".slippiCode")
    var nf = slippiName.makeFilterCondition(tableName + ".slippiName")

    if(slippiCode.filterText && slippiName.filterText) {
      return qsTr("(%1 %2 %3)")
        .arg(cf)
        .arg(filterCodeAndName ? "and" : "or")
        .arg(nf)
    }
    else if(slippiCode.filterText) {
      return qsTr("(%1)").arg(cf)
    }
    else if(slippiName.filterText) {
      return qsTr("(%1)").arg(nf)
    }
    else {
      return "true"
    }
  }

  function getCharFilterCondition(colName) {
    if(charIds && charIds.length > 0) {
      return "(" + colName + " in " + dataModel.globalDataBase.makeSqlWildcards(charIds) + ")"
    }
    else {
      return "true"
    }
  }

  function getPlayerFilterParams() {
    var codeValue = slippiCode.makeSqlWildcard()
    var nameValue = slippiName.makeSqlWildcard()

    if(slippiCode.filterText && slippiName.filterText) {
      return [codeValue, nameValue]
    }
    else if(slippiCode.filterText) {
      return [codeValue]
    }
    else if(slippiName.filterText) {
      return [nameValue]
    }
    else {
      return []
    }
  }

  function getCharFilterParams() {
    if(charIds && charIds.length > 0) {
      return charIds
    }
    else {
      return []
    }
  }
}
