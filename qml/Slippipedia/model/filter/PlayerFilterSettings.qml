import QtQuick 2.0
import QtCore
import Felgo 4.0

import Slippipedia 1.0

Item {
  id: playerFilterSettings

  property string settingsCategory: ""
  property bool persistenceEnabled: false

  property TextSettings slippiCode: TextSettings {
    id: slippiCode

    onFilterTextChanged:   if(settingsLoader.item) settingsLoader.item.slippiCodeText = filterText
    onMatchCaseChanged:    if(settingsLoader.item) settingsLoader.item.slippiCodeCase = matchCase
    onMatchPartialChanged: if(settingsLoader.item) settingsLoader.item.slippiCodePartial = matchPartial

    onFilterChanged: playerFilterSettings.filterChanged()
  }
  property TextSettings slippiName: TextSettings {
    id: slippiName

    onFilterTextChanged:   if(settingsLoader.item) settingsLoader.item.slippiNameText = filterText
    onMatchCaseChanged:    if(settingsLoader.item) settingsLoader.item.slippiNameCase = matchCase
    onMatchPartialChanged: if(settingsLoader.item) settingsLoader.item.slippiNamePartial = matchPartial

    onFilterChanged: playerFilterSettings.filterChanged()
  }

  property bool filterCodeAndName: true
  property int port: -1

  property var charIds: []

  signal filterChanged

  // due to this being in a loader, can't use alias properties -> save on change:
  onFilterCodeAndNameChanged: {
    filterChanged()
    if(settingsLoader.item) settingsLoader.item.filterCodeAndName = filterCodeAndName
  }
  onCharIdsChanged: {
    filterChanged()
    if(settingsLoader.item) settingsLoader.item.charIds = charIds
  }
  onPortChanged: {
    filterChanged()
    if(settingsLoader.item) settingsLoader.item.port = port
  }

  readonly property bool hasFilter: hasPlayerFilter || hasCharFilter
  readonly property bool hasPlayerFilter: slippiCode.filterText != "" || slippiName.filterText != "" || port >= 0
  readonly property bool hasCharFilter: charIds && charIds.length > 0

  onHasPlayerFilterChanged: filterChanged()

  readonly property string nameFilterText: {
    var codeText = slippiCode.filterText
    var nameText = slippiName.filterText
    var pText

    var portText = port >= 0 ? "Port " + (port + 1) : ""

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

    return [pText, portText].filter(s => s).join(", ")
  }

  readonly property string displayText: {
    var pText = nameFilterText


    var cText = null
    if(charIds.length > 0) {
      cText = charIds.map(id => MeleeData.charNames[id]).join(", ")
    }

    return [pText, cText].filter(_ => _).join(", ") || ""
  }

  Loader {
    id: settingsLoader

    active: persistenceEnabled
    onLoaded: item.apply()

    sourceComponent: Settings {
      id: settings

      category: playerFilterSettings.settingsCategory

      property string slippiCodeText: slippiCode.filterText
      property bool slippiCodeCase: slippiCode.matchCase
      property bool slippiCodePartial: slippiCode.matchPartial

      property string slippiNameText: slippiName.filterText
      property bool slippiNameCase: slippiName.matchCase
      property bool slippiNamePartial: slippiName.matchPartial

      property bool filterCodeAndName: playerFilterSettings.filterCodeAndName // true: and, false: or

      property int port: playerFilterSettings.port
      property var charIds: playerFilterSettings.charIds

      function apply() {
        // due to this being in a loader, can't use alias properties -> apply on load:
        playerFilterSettings.slippiCode.filterText = slippiCodeText
        playerFilterSettings.slippiCode.matchCase = slippiCodeCase
        playerFilterSettings.slippiCode.matchPartial = slippiCodePartial
        playerFilterSettings.slippiName.filterText = slippiNameText
        playerFilterSettings.slippiName.matchCase = slippiNameCase
        playerFilterSettings.slippiName.matchPartial = slippiNamePartial
        playerFilterSettings.filterCodeAndName = filterCodeAndName
        playerFilterSettings.port = port
        playerFilterSettings.charIds = charIds.map(id => ~~id) // settings stores as list of string, convert to int
      }
    }
  }

  function reset() {
    charIds = []
    resetPlayerFilter()
  }

  function resetPlayerFilter() {
    port = -1
    slippiCode.reset()
    slippiName.reset()
  }

  function copyFrom(other) {
    setCharFilter(other.charIds)

    slippiCode.filterText = other.slippiCode.filterText
    slippiCode.matchCase = other.slippiCode.matchCase
    slippiCode.matchPartial = other.slippiCode.matchPartial

    slippiName.filterText = other.slippiName.filterText
    slippiName.matchCase = other.slippiName.matchCase
    slippiName.matchPartial = other.slippiName.matchPartial

    port = other.port
    filterCodeAndName = other.filterCodeAndName
  }

  // filtering

  function setCharFilter(charIds) {
    playerFilterSettings.charIds = charIds
  }

  function addCharFilter(charId) {
    playerFilterSettings.charIds = charIds.concat(charId)
  }

  function removeCharFilter(charId) {
    var list = charIds
    list.splice(list.indexOf(charId), 1)
    playerFilterSettings.charIds = list
  }

  function removeAllCharFilters() {
    playerFilterSettings.charIds = []
  }

  // DB filtering functions

  function getFilterCondition(tableName) {
    var playerCon = getPlayerFilterCondition(tableName)

    var charCon = getCharFilterCondition(tableName + ".charId")

    var portCon = port >= 0 ? tableName + ".port = ?" : ""

    var condition = [ playerCon, charCon, portCon ]
      .map(c => ("(" + (c || true) + ")" ))
      .join(" and ")

    return "(" + condition + ")"
  }

  function getFilterParams() {
    var playerParams = getPlayerFilterParams()
    var charParams = getCharFilterParams()
    var portParams = port >= 0 ? [port] : []

    return playerParams.concat(charParams, portParams)
  }

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
      return ""
    }
  }

  function getCharFilterCondition(colName) {
    if(charIds && charIds.length > 0) {
      return "(" + colName + " in " + dataModel.globalDataBase.makeSqlWildcards(charIds) + ")"
    }
    else {
      return ""
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
