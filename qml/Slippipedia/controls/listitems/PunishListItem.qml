import QtQuick 2.0
import QtQuick.Layouts 1.0
import Felgo 4.0

import Slippipedia 1.0

AppListItem {
  id: punishListItem

  property var punishModel: ({})

  readonly property bool showOptions: mouseArea.containsMouse || toolBtnOpen.hovered || toolBtnSetup.hovered

  height: dp(60)

  backgroundColor: Theme.backgroundColor

  leftItem: RowLayout {
    width: punishListItem.width - dp(100)
    height: parent.height
    spacing: dp(Theme.contentPadding)

    Column {
      Layout.preferredWidth: dp(80)
      Layout.alignment: Qt.AlignVCenter
      spacing: dp(Theme.contentPadding) / 4

      AppText {
        anchors.horizontalCenter: parent.horizontalCenter
        text: dataModel.formatNumber(punishModel.damage) + "%"

        font.pixelSize: sp(20)
        font.bold: true
        color: dataModel.damageColor(punishModel.damage)
      }

      AppText {
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("%1 %2")
        .arg(punishModel.numMoves)
        .arg(punishModel.numMoves > 1 ? "moves" : "move")
      }
    }

    Column {
      Layout.preferredWidth: dp(100)
      Layout.alignment: Qt.AlignVCenter
      spacing: dp(Theme.contentPadding) / 2

      StockIcons {
        id: stockIcons
        anchors.horizontalCenter: parent.horizontalCenter
        charId: punishModel && punishModel.char2 || 0
        skinId: punishModel && punishModel.skin2 || 0
        numStocks: punishModel && punishModel.stocks || 0
      }

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: dp(Theme.contentPadding) / 2
        height: sp(16)
        visible: showOptions

        AppText {
          // the game also rounds down for displaying percent
          text: qsTr("%1%").arg(Math.floor(punishModel.startPercent))

          font.pixelSize: sp(14)
          font.bold: true
          color: dataModel.damageColor(punishModel.startPercent)
        }

        AppText {
          text: "-"
        }

        AppText {
          // the game also rounds down for displaying percent
          text: qsTr("%1%").arg(Math.floor(punishModel.endPercent))

          font.pixelSize: sp(14)
          font.bold: true
          color: dataModel.damageColor(punishModel.endPercent)
        }
      }
    }

    Item {
      height: parent.height
      width: dp(32)

      AppText {
        text: "KO"
        anchors.centerIn: parent
        visible: punishModel.didKill
        font.pixelSize: sp(24)
      }
    }

    Column {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      spacing: dp(Theme.contentPadding) / 4

      AppText {
        text: qsTr("%1 Opening: %2 (%3)")
        .arg(dataModel.formatTime(punishModel.startFrame))
        .arg(MeleeData.moveNames[punishModel.openingMoveId])
        .arg(MeleeData.dynamicNames[model.openingDynamic])
      }

      AppText {
        text: qsTr("%1 %2: %3")
        .arg(dataModel.formatTime(punishModel.endFrame))
        .arg(punishModel.didKill
          ? qsTr("Killed (%1) with").arg(MeleeData.killDirectionNames[punishModel.killDirection])
          : "Last move")
        .arg(MeleeData.moveNames[punishModel.lastMoveId])
      }
    }
  }

  rightItem: Row {
    visible: showOptions
    height: parent.height
    spacing: dp(Theme.contentPadding) / 2

    AppToolButton {
      id: toolBtnOpen

      height: width
      anchors.verticalCenter: parent.verticalCenter

      iconType: IconType.play
      toolTipText: "Replay punish"

      visible: dataModel.hasDesktopApp
      onClicked: dataModel.replayPunishes([punishModel])
    }

    AppToolButton {
      id: toolBtnSetup
      iconType: IconType.gear
      toolTipText: "Set Slippi Desktop App folder to replay punish."
      height: width
      anchors.verticalCenter: parent.verticalCenter

      visible: !dataModel.hasDesktopApp
      onClicked: showSetup()
    }
  }
}
