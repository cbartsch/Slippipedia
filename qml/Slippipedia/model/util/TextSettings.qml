import QtQuick 2.0
import Felgo 4.0

QtObject {
  property string filterText: ""
  property bool matchCase: false
  property bool matchPartial: true
  property bool splitText: false
  property string delimiter: ","

  readonly property var textParts: (splitText ? filterText.split(delimiter) : [filterText]).filter(p => p)

  signal filterChanged

  onTextPartsChanged:    filterChanged()
  onMatchCaseChanged:    filterChanged()
  onMatchPartialChanged: filterChanged()

  function reset() {
    filterText = ""
    matchCase = false
    matchPartial = true
  }

  function _makeFilterCondition(colName, text) {
    if(matchPartial && matchCase) {
      // case sensitive wildcard (case sensitive like must be ON)
      return colName + " like ?"
    }
    else if(matchPartial) {
      // case insensitive wildcard -> compare upper
      return "upper(%1) like upper(?)".arg(colName)
    }
    else if(matchCase) {
      // case sensitive comparison
      return colName + " = ?"
    }
    else {
      // case insensitive comparison
      return colName + " = ? collate nocase"
    }
  }

  function makeFilterCondition(colName) {
    return textParts.map(p => _makeFilterCondition(colName, p)).join(" OR ")
  }

  // make SQL wildcard if matchPartial is true
  function _getFilterParams(text) {
    return matchPartial ? "%" + text + "%" : text
  }

  function getFilterParams() {
    return textParts.map(p => _getFilterParams(p))
  }
}
