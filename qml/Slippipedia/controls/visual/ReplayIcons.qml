import QtQuick 2.0
import Felgo 3.0

import Slippipedia 1.0

Item {
  implicitWidth: content.width
  implicitHeight: content.height

  property var replayModel: ({})

  property bool showPercent: false

  property real stockIconColumnWidth: dp(90)

  Row {
    id: content
    anchors.verticalCenter: parent.verticalCenter
    spacing: dp(1)
    scale: parent.width / width
    transformOrigin: Item.Left

    Column {
      anchors.verticalCenter: parent.verticalCenter
      width: stockIconColumnWidth

      StockIcons {
        id: stockIcons1
        anchors.horizontalCenter: parent.horizontalCenter
        charId: replayModel && replayModel.char1 || 0
        skinId: replayModel && replayModel.skin1 || 0
        numStocks: replayModel && replayModel.endStocks1 || 0
      }

      Row {
        visible: showPercent
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: dp(4)

        AppText {
          // the game also rounds down for displaying percent
          text: replayModel && replayModel.endStocks1 > 0
                ? qsTr("%1%").arg(Math.floor(replayModel.endPercent1))
                : "KO" || ""

          font.pixelSize: sp(16)
          font.bold: true
          color: replayModel && replayModel.endStocks1 > 0 ? dataModel.damageColor(replayModel.endPercent1) : "#80ffffff"
        }

        AppText {
          text: "(LRAS)"
          visible: replayModel.lrasPort === replayModel.port1

          font.pixelSize: sp(16)
          color: Theme.textColor
        }
      }
    }

    Item {
      width: dp(Theme.contentPadding) / 2
      height: 1
    }

    AppText {
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: sp(18)
      color: Theme.secondaryTextColor

      text: "vs"
    }

    Item {
      width: dp(Theme.contentPadding) / 2
      height: 1
    }

    Column {
      anchors.verticalCenter: parent.verticalCenter
      width: stockIconColumnWidth

      StockIcons {
        id: stockIcons2
        anchors.horizontalCenter: parent.horizontalCenter
        charId: replayModel && replayModel.char2 || 0
        skinId: replayModel && replayModel.skin2 || 0
        numStocks: replayModel && replayModel.endStocks2 || 0
      }

      Row {
        visible: showPercent
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: dp(4)

        AppText {
          text: replayModel && replayModel.endStocks2 > 0
                ? qsTr("%1%").arg(Math.floor(replayModel.endPercent2))
                : "KO" || ""

          font.pixelSize: sp(16)
          font.bold: true
          color: replayModel && replayModel.endStocks2 > 0 ? dataModel.damageColor(replayModel.endPercent2) : "#80ffffff"
        }

        AppText {
          text: "(LRAS)"
          visible: replayModel.lrasPort === replayModel.port2

          font.pixelSize: sp(16)
          color: Theme.textColor
        }
      }
    }

    Item {
      width: dp(Theme.contentPadding)
      height: 1
    }

    StageIcon {
      anchors.verticalCenter: parent.verticalCenter
      stageId: replayModel && replayModel.stageId || 0
      width: dp(62 * 0.8)
      height: dp(54 * 0.8)
    }

    Item {
      width: dp(Theme.contentPadding)
      height: 1
    }

    AppText {
      anchors.verticalCenter: parent.verticalCenter
      horizontalAlignment: Text.AlignHCenter
      width: dp(40)

      text: dataModel.formatTime(replayModel.duration)
    }
  }
}
