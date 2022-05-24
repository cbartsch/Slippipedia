import QtQuick 2.0
import QtQuick.Controls 2.15
import Felgo 4.0

AppText {
  id: customText

  property string toolTipText: ""

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    enabled: !!customText.toolTipText
  }

  CustomToolTip {
    parent: customText
    visible: mouseArea.containsMouse && !!text
    text: customText.toolTipText
  }
}
