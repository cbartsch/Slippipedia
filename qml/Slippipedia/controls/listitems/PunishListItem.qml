import QtQuick 2.0
import QtQuick.Layouts 1.0
import Felgo 3.0

import Slippipedia 1.0

AppListItem {
  id: punishListItem

  property var punishModel: ({})

  height: dp(60)

  backgroundColor: Theme.backgroundColor

  leftItem: RowLayout {
    width: punishListItem.width - dp(100)
    height: parent.height

    Column {
      Layout.preferredWidth: dp(100)
      anchors.verticalCenter: parent.verticalCenter
      spacing: dp(Theme.contentPadding) / 4

      AppText {
        anchors.horizontalCenter: parent.horizontalCenter
        text: dataModel.formatNumber(punishModel.damage) + "%"

        font.pixelSize: sp(22)
        color: dataModel.damageColor(punishModel.damage)
      }

      AppText {
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("%1 moves").arg(punishModel.numMoves)
      }
    }

    Column {
      Layout.fillWidth: true
      anchors.verticalCenter: parent.verticalCenter
      spacing: dp(Theme.contentPadding) / 4

      AppText {
        text: qsTr("%1 Opening: %2 (%3)")
        .arg(dataModel.formatTime(punishModel.startFrame))
        .arg(MeleeData.moveNames[punishModel.openingMoveId])
        .arg(MeleeData.dynamicNames[model.openingDynamic])
      }

      AppText {
        text: qsTr("%1 %2: %3%4")
        .arg(dataModel.formatTime(punishModel.endFrame))
        .arg(punishModel.didKill ? "Killed with" : "Last move")
        .arg(MeleeData.moveNames[punishModel.lastMoveId])
        .arg(punishModel.didKill ? qsTr(" (%1)").arg(MeleeData.killDirectionNames[punishModel.killDirection]) : "")
      }
    }
  }

  rightItem: Row {
    visible: mouseArea.containsMouse || toolBtnOpen.hovered
    height: parent.height
    spacing: dp(Theme.contentPadding) / 2

    AppToolButton {
      id: toolBtnOpen

      height: width
      anchors.verticalCenter: parent.verticalCenter

      iconType: IconType.play
      toolTipText: "Replay punish"

      onClicked: dataModel.replayPunishes([punishModel])
    }
  }
}
