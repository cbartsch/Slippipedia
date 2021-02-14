import QtQuick 2.0
import Felgo 3.0

Grid {
  id: nameGridOpponent

  property alias model: repeater.model

  columns: Math.round(width / dp(200))
  anchors.left: parent.left
  anchors.right: parent.right
  anchors.margins: dp(Theme.contentPadding)
  spacing: dp(Theme.contentPadding) / 2
  rowSpacing: dp(1)

  Repeater {
    id: repeater

    Item {
      width: parent.width / parent.columns
      height: dp(48)

      Column {
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter

        AppText {
          width: parent.width
          text: modelData.text
          maximumLineCount: 1
          elide: Text.ElideRight
          font.pixelSize: sp(20)
        }
        AppText {
          width: parent.width
          text: qsTr("%1 (%2)").arg(modelData.count).arg(dataModel.formatPercentage(modelData.count / dataModel.totalReplaysFiltered))
          maximumLineCount: 1
          elide: Text.ElideRight
        }
      }
    }
  }
}
