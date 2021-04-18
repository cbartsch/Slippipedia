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
    horizontalPadding: dp(Theme.contentPadding) / 2

    Rectangle {
      anchors.fill: parent
      color: ripple.pressed ? Theme.secondaryBackgroundColor : Theme.controlBackgroundColor
      z: -1
    }

    RippleMouseArea {
      id: ripple
      anchors.fill: parent
      hoverEffectEnabled: true
      backgroundColor: Theme.listItem.selectedBackgroundColor
      fillColor: backgroundColor
      opacity: 0.5
      onClicked: btnDay.clicked()
    }
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
  }
}
