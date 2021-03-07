import QtQuick 2.0
import Felgo 3.0

Grid {
  id: nameGridOpponent

  property alias model: repeater.model

  property bool namesClickable: false
  signal nameClicked(string name)

  anchors.left: parent.left
  anchors.right: parent.right

  Repeater {
    id: repeater

    Item {
      width: parent.width / parent.columns
      height: dp(48) + dp(Theme.contentPadding) / 2

      Rectangle {
        anchors.fill: parent
        color: Theme.backgroundColor
        visible: namesClickable

        RippleMouseArea {
          anchors.fill: parent
          hoverEffectEnabled: true
          onClicked: nameGridOpponent.nameClicked(modelData.text)
          enabled: namesClickable
          z: 1
          backgroundColor: Theme.listItem.selectedBackgroundColor
          fillColor: backgroundColor
          opacity: 0.5
        }
      }

      Column {
        id: col
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: dp(Theme.contentPadding) / 2

        AppText {
          width: parent.width
          text: modelData.text
          maximumLineCount: 1
          elide: Text.ElideRight
          font.pixelSize: sp(20)
        }

        AppText {
          width: parent.width
          text: qsTr("%1 (%2)")
          .arg(modelData.count)
          .arg(dataModel.formatPercentage(modelData.count / stats.totalReplaysFiltered))
          maximumLineCount: 1
          elide: Text.ElideRight
        }
      }
    }
  }
}
