import QtQuick 2.0
import Felgo 3.0

import Slippipedia 1.0

Item {
  implicitWidth: content.width
  implicitHeight: content.height

  property var replayModel: ({})

  Row {
    id: content
    anchors.verticalCenter: parent.verticalCenter
    spacing: dp(1)
    scale: parent.width / width
    transformOrigin: Item.Left

    StockIcons {
      anchors.verticalCenter: parent.verticalCenter
      charId: replayModel && replayModel.char1 || 0
      skinId: replayModel && replayModel.skin1 || 0
      numStocks: replayModel && replayModel.endStocks1 || 0
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

    StockIcons {
      anchors.verticalCenter: parent.verticalCenter
      charId: replayModel && replayModel.char2 || 0
      skinId: replayModel && replayModel.skin2 || 0
      numStocks: replayModel && replayModel.endStocks2 || 0
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
  }
}
