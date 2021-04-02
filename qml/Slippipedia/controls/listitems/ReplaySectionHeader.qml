import QtQuick 2.0
import QtQuick.Layouts 1.12
import Felgo 3.0

import Slippipedia 1.0

Item {
  id: sectionHeader

  width: parent.width
  height: dp(120)

  readonly property var emptySection: ({
                                         chars1: [],
                                         chars2: []
                                       })

  property var sData: emptySection

  property bool checked: false

  signal showStats

  Rectangle {
    anchors.fill: parent
    color: checked ? Qt.darker(Theme.tintColor, 3) : Theme.backgroundColor
  }

  ColumnLayout {
    id: content
    anchors.fill: parent
    anchors.margins: dp(Theme.contentPadding)

    Item {
      Layout.fillHeight: true
      Layout.fillWidth: true

      PlayerInfoRow {
        id: titleFlick
        anchors.fill: parent
        model: sData
      }
    }

    Item {
      width: 1
      height: dp(Theme.contentPadding / 2)
    }

    StatsInfoItem {
      Layout.preferredWidth: parent.width

      listButtonVisible: false

      stats: sData
      onShowStats: sectionHeader.showStats()
    }
  }
}
