import QtQuick 2.0
import Felgo 4.0

QtObject {
  property real from: -1
  property real to: -1

  readonly property bool hasFilter: from >= 0 || to >= 0

  signal filterChanged

  onFromChanged:  filterChanged()
  onToChanged:    filterChanged()

  readonly property var displayText: {
    if(from >= 0 && to >= 0) {
      if(from == to) {
        return from + ""
      }
      else {
        return qsTr("%1-%2").arg(from).arg(to)
      }
    }
    else if(from >= 0) {
      return qsTr("%1+").arg(from)
    }
    else if(to >= 0) {
      return qsTr("≤%1").arg(to)
    }
    else {
      return ""
    }
  }

  function reset() {
    from = -1
    to = -1
  }

  function getFilterCondition(colName) {
    if(from >= 0 && to >= 0) {
      return colName + " between ? and ?"
    }
    else if(from >= 0) {
      return colName + " >= ?"
    }
    else if(to >= 0) {
      return colName + " <= ?"
    }
    else {
      return "true"
    }
  }

  function getFilterParams(mapFunc) {
    return [from, to]
      .filter(v => v >= 0)
      .map(v => mapFunc ? mapFunc(v) : v)
  }

  function copyFrom(other) {
    from = other.from
    to = other.to
  }
}
