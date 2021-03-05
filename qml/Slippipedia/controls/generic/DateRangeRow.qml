import QtQuick 2.0
import Felgo 3.0

Row {
  property int numDays
  signal setPastRange(int numDays)
  signal addDateRange(int numDays)

  AppButton {
    id: btnDay
    text: numDays === 1
          ? "Last 24 hours"
          : numDays === 7
            ? "Last week"
            : qsTr("Last %1 days").arg(numDays)

    flat: true
    onClicked: setPastRange(numDays)
  }

  IconButton {
    icon: IconType.minus
    size: dp(12)
    height: btnDay.height
    width: height / 2
    onClicked: addDateRange(-numDays)
  }

  IconButton {
    icon: IconType.plus
    size: dp(12)
    height: btnDay.height
    width: height / 2
    onClicked: addDateRange(numDays)
  }
}
