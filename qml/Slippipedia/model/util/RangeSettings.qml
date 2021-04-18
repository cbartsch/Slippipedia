import QtQuick 2.0
import Felgo 3.0

QtObject {
  property real from: 0
  property real to: 0

  readonly property bool hasFilter: from > 0 || to > 0

  signal filterChanged

  onFromChanged:  filterChanged()
  onToChanged:    filterChanged()

  function reset() {
    from = 0
    to = 0
  }

  function getFilterCondition(colName) {
    if(from > 0 && to > 0) {
      return colName + " between ? and ?"
    }
    else if(from > 0) {
      return colName + " >= ?"
    }
    else if(to > 0) {
      return colName + " <= ?"
    }
    else {
      return "true"
    }
  }

  function getFilterParams(mapFunc) {
    return [from, to]
      .filter(v => v > 0)
      .map(v => mapFunc ? mapFunc(v) : v)
  }

  function copyFrom(other) {
    from = other.from
    to = other.to
  }
}
