import QtQuick 2.0
import Felgo 4.0

import Slippipedia 1.0

AppFlickable {
  id: playerInfoRow

  flickableDirection: Flickable.HorizontalFlick
  contentWidth: Math.max(titleContent.width, width)
  height: titleContent.height

  property var model: ({})

  readonly property var charsIds1: model && model.chars1 ? Object.keys(model.chars1) : []
  readonly property var charsIds2: model && model.chars2 ? Object.keys(model.chars2) : []

  Row {
    id: titleContent
    anchors.verticalCenter: parent.verticalCenter

    spacing: dp(Theme.contentPadding) / 2

    AppText {
      id: nameText
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: sp(20)
      color: Theme.tintColor

      visible: !!text
      text: model.name1 || ""
    }

    AppText {
      anchors.baseline: nameText.baseline
      font.pixelSize: sp(12)
      color: Theme.secondaryTextColor

      visible: !!text
      text: qsTr("%1").arg(model.code1)
    }

    AppText {
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: sp(12)
      color: MeleeData.portColors[model.port1] || "white"

      text: qsTr("P%1").arg(model.port1 + 1)
    }

    Repeater {
      model: charsIds1

      StockIcon {
        anchors.verticalCenter: parent.verticalCenter
        charId: modelData
        skinId: playerInfoRow.model.chars1 && playerInfoRow.model.chars1[modelData] || 0
      }
    }

    AppText {
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: sp(18)
      color: Theme.secondaryTextColor

      text: "vs"
    }

    Repeater {
      model: charsIds2

      StockIcon {
        anchors.verticalCenter: parent.verticalCenter
        charId: modelData
        skinId: playerInfoRow.model.chars2 && playerInfoRow.model.chars2[modelData] || 0
      }
    }

    AppText {
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: sp(12)
      color: MeleeData.portColors[model.port2] || "white"

      text: qsTr("P%1").arg(model.port2 + 1)
    }

    AppText {
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: sp(20)
      color: Theme.tintColor

      visible: !!text
      text: model.name2 || ""
    }

    AppText {
      anchors.baseline: nameText.baseline
      font.pixelSize: sp(12)
      color: Theme.secondaryTextColor

      visible: !!text
      text: qsTr("%1").arg(model.code2)
    }
  }
}
