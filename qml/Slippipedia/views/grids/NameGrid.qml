import QtQuick 2.0
import QtQuick.Controls 2.0
import Felgo 4.0
import Slippipedia 1.0

Grid {
  id: nameGrid

  // an object like { list: [...], maxCount: 1000 }
  property var model: ({})

  property bool namesClickable: false
  signal nameClicked(string name)

  anchors.left: parent.left
  anchors.right: parent.right

  property bool isOpponent: false
  readonly property string slotText: isOpponent ? "vs" : "as"

  Repeater {
    id: repeater
    model: nameGrid.model.list

    Item {
      width: parent.width / parent.columns
      height: dp(48) + dp(Theme.contentPadding) / 2

      Rectangle {
        anchors.fill: parent
        color: Theme.backgroundColor
        visible: namesClickable

        RippleMouseArea {
          id: mouseArea
          anchors.fill: parent
          enabled: namesClickable
          onClicked: nameGrid.nameClicked(modelData.text)

          hoverEffectEnabled: true
          backgroundColor: Theme.listItem.selectedBackgroundColor
          fillColor: backgroundColor
          opacity: 0.5
        }

        CustomToolTip {
          shown: mouseArea.containsMouse
          text: qsTr("List all %1 games %2 %3").arg(modelData.count).arg(slotText).arg(modelData.text)
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

          opacity: (modelData.count / nameGrid.model.maxCount) * 0.5 + 0.5
        }
      }
    }
  }
}
