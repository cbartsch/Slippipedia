import QtQuick 2.0
import QtQuick.Layouts 1.12
import Felgo 3.0

import Slippipedia 1.0

Item {
  id: sectionHeader

  width: parent.width
  height: content.height

  readonly property var emptySection: ({
                                         chars1: [],
                                         chars2: []
                                       })

  property var sectionModel: emptySection

  property bool checked: false

  property alias listButtonVisible: statsItem.listButtonVisible
  property alias statsButtonVisible: statsItem.statsButtonVisible

  signal showStats

  Rectangle {
    anchors.fill: parent
    color: checked ? Qt.darker(Theme.tintColor, 3) : Theme.backgroundColor
  }

  Column {
    id: content
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: dp(Theme.contentPadding)
    anchors.verticalCenter: parent.verticalCenter
    spacing: dp(Theme.contentPadding) / 4

    PlayerInfoRow {
      id: titleFlick
      width: parent.width
      model: sectionModel
    }

    StatsInfoItem {
      id: statsItem

      width: parent.width

      listButtonVisible: false

      stats: sectionModel
      onShowStats: sectionHeader.showStats()
    }
  }
}
