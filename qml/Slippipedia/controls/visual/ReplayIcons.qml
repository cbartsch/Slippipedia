import QtQuick 2.0
import QtQuick.Controls 2.0
import Felgo 4.0
import Qt5Compat.GraphicalEffects

import Slippipedia 1.0

Item {
  implicitWidth: content.width
  implicitHeight: content.height

  property var replayModel: ({})
  property var stockSummary: []

  property bool showPercent: false

  property real stockIconColumnWidth: dp(90)

  property bool stockHovered: false

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
      width: dp(Theme.contentPadding) / 2
      height: 1
    }

    AppText {
      anchors.verticalCenter: parent.verticalCenter
      horizontalAlignment: Text.AlignHCenter
      width: dp(40)

      text: dataModel.formatTime(replayModel.duration)
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
      visible: !!stockSummary
      width: dp(Theme.contentPadding)
      height: 1
    }

    Repeater {
      model: stockSummary

      Item {
        id: stockInfo

        // if it's P1's punish, P2 lost the stock
        readonly property bool isP1: modelData.port !== replayModel.port1

        readonly property string pText: isP1 ? replayModel.name1 : replayModel.name2
        readonly property string oText: isP1 ? replayModel.name2 : replayModel.name1

        readonly property bool hovered: stockMouse.containsMouse || toolTipMouse.containsMouse || toolBtnOpen.hovered

        onHoveredChanged: stockHovered = hovered

        // cancel the options when the list view starts dragging
        Connections {
          target: replayListView
          onMovementStarted: stockHovered = false
        }

        height: parent.height
        width: dp(32)
        anchors.verticalCenter: parent.verticalCenter

        visible: modelData.killed

        RippleMouseArea {
          id: stockMouse

          anchors.fill: parent
          onPressed: mouse => mouse.accepted = false

          hoverEffectEnabled: true
          cursorShape: Qt.ArrowCursor
          backgroundColor: Theme.listItem.selectedBackgroundColor
          fillColor: backgroundColor
          opacity: 0.5
        }

        CustomToolTip {
          id: stockToolTip
          shown: stockInfo.hovered

          MouseArea {
            id: toolTipMouse
            hoverEnabled: true
            anchors.fill: parent
            parent: stockToolTip.background
            anchors.margins: -dp(3)

            onPressed: mouse => mouse.accepted = false
          }

          contentItem: Row {
            spacing: dp(Theme.contentPadding)

            Column {
              AppText {
                text: qsTr("%1 lost stock %2 at %3").arg(pText).arg(replayModel.startStocks - modelData.stock + 1).arg(dataModel.formatTime(modelData.endFrame))
              }
              AppText {
                text: qsTr("%6 punishes from %7, %8% damage").arg(modelData.numPunishes).arg(oText).arg(Math.floor(modelData.totalDamage))
              }
            }

            AppToolButton {
              id: toolBtnOpen
              iconType: IconType.play
              toolTipText: qsTr("Replay stock (%1 - %2)").arg(dataModel.formatTime(modelData.startFrame)).arg(dataModel.formatTime(modelData.endFrame))
              height: width
              anchors.verticalCenter: parent.verticalCenter

              visible: dataModel.hasDesktopApp
              onClicked: dataModel.replayPunishes([{
                                                     startFrame: modelData.startFrame,
                                                     endFrame: modelData.endFrame,
                                                     filePath: replayModel.filePath
                                                  }])
            }
          }
        }

        Column {
          anchors.centerIn: parent

          StockIcon {
            anchors.horizontalCenter: parent.horizontalCenter

            charId: replayModel && isP1 ? replayModel.char1 : replayModel.char2 || 0
            skinId: replayModel && isP1 ? replayModel.skin1 : replayModel.skin2 || 0
          }

          AppText {
            anchors.horizontalCenter: parent.horizontalCenter

            font.pixelSize: sp(10)
            style: Text.Outline
            styleColor: "black"
            color: dataModel.damageColor(modelData.totalDamage)
            text: Math.floor(modelData.endPercent) + "%"
          }
        }
      }
    }
  }
}
