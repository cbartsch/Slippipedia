import QtQuick 2.0
import QtQuick.Controls 2.0
import Felgo 3.0

Row {
  id: dateRangeRow

  property int numDays
  signal setPastRange(int numDays)
  signal addDateRange(int numDays)

  spacing: dp(1)

  readonly property string timeText: numDays === 1
                                     ? "24 hours"
                                     : qsTr("%1 days").arg(numDays)

  OptionButton {
    id: btnDay
    text: "Last " + timeText
    onClicked: setPastRange(numDays)
  }

  IconButton {
    id: btnMinus
    icon: IconType.minus
    size: dp(12)
    height: btnDay.height
    width: height / 2
    onClicked: addDateRange(-numDays)

    Rectangle {
      anchors.fill: parent
      color: ripple2.pressed ? Theme.secondaryBackgroundColor : Theme.controlBackgroundColor
      z: -1
    }

    RippleMouseArea {
      id: ripple2
      anchors.fill: parent
      hoverEffectEnabled: true
      backgroundColor: Theme.listItem.selectedBackgroundColor
      fillColor: backgroundColor
      opacity: 0.5
      onClicked: btnMinus.clicked()
    }

    ToolTip {
      visible: ripple2.containsMouse && !!text
      text: timeText + " earlier"
    }
  }

  IconButton {
    id: btnPlus
    icon: IconType.plus
    size: dp(12)
    height: btnDay.height
    width: height / 2
    onClicked: addDateRange(numDays)

    Rectangle {
      anchors.fill: parent
      color: ripple3.pressed ? Theme.secondaryBackgroundColor : Theme.controlBackgroundColor
      z: -1
    }

    RippleMouseArea {
      id: ripple3
      anchors.fill: parent
      hoverEffectEnabled: true
      backgroundColor: Theme.listItem.selectedBackgroundColor
      fillColor: backgroundColor
      opacity: 0.5
      onClicked: btnPlus.clicked()
    }

    ToolTip {
      visible: ripple3.containsMouse && !!text
      text: timeText + " later"
    }
  }
}
