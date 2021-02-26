import QtQuick 2.0
import Felgo 3.0

Item {
  id: stat

  property string name

  property real count: totalReplaysFiltered

  readonly property real value: statsData && statsData[name] || 0
  readonly property real avg: value / count

  function format() {
    /* dataModel.formatNumber(value) +  " / " +*/

    return dataModel.formatNumber(avg) // only show average for now
  }
}
