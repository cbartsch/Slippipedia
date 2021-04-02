import QtQuick 2.0
import Felgo 3.0

import Slippipedia 1.0

AppFlickable {
  id: playerInfoRow

  flickableDirection: Flickable.HorizontalFlick
  contentWidth: Math.max(titleContent.width, width)
  implicitHeight: titleContent.height

  property var model: ({})

  readonly property var charsIds1: model && model.chars1 ? Object.keys(model.chars1) : []
  readonly property var charsIds2: model && model.chars2 ? Object.keys(model.chars2) : []

  Row {
    id: titleContent
    height: parent.height
    anchors.verticalCenter: parent.verticalCenter

    spacing: dp(Theme.contentPadding) / 2

    AppText {
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: sp(20)
      color: Theme.tintColor

      text: qsTr("%1 (%2)").arg(playerInfoRow.model.name1).arg(playerInfoRow.model.code1)
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
      font.pixelSize: sp(20)
      color: Theme.tintColor

      text: qsTr("%1 (%2)").arg(playerInfoRow.model.name2).arg(playerInfoRow.model.code2)
    }
  }
}
