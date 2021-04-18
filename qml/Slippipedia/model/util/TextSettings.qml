import QtQuick 2.0
import Felgo 3.0

QtObject {
  property string filterText: ""
  property bool matchCase: false
  property bool matchPartial: true

  signal filterChanged

  onFilterTextChanged:   filterChanged()
  onMatchCaseChanged:    filterChanged()
  onMatchPartialChanged: filterChanged()

  function reset() {
    filterText = ""
    matchCase = false
    matchPartial = true
  }

  function makeFilterCondition(colName) {
    if(matchPartial && matchCase) {
      // case sensitive wildcard (case sensitive like must be ON)
      return colName + " like ?"
    }
    else if(matchPartial) {
      // case insensitive wildcard -> compare upper
      return qsTr("upper(%1) like upper(?)").arg(colName)
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

  // make SQL wildcard if matchPartial is true
  function makeSqlWildcard(filter) {
    return matchPartial ? "%" + filterText + "%" : filterText
  }
}
