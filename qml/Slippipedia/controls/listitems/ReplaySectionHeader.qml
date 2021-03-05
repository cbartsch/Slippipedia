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

  readonly property var chars1: Object.keys(sData.chars1)
  readonly property var chars2: Object.keys(sData.chars2)

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

      AppFlickable {
        id: titleFlick
        anchors.fill: parent
        flickableDirection: Flickable.HorizontalFlick
        contentWidth: Math.max(titleContent.width, width)

        Row {
          id: titleContent
          height: parent.height
          anchors.verticalCenter: parent.verticalCenter

          spacing: dp(Theme.contentPadding) / 2

          AppText {
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: sp(20)
            color: Theme.tintColor

            text: qsTr("%1 (%2)").arg(sData.name1).arg(sData.code1)
          }

          Repeater {
            model: chars1

            StockIcon {
              anchors.verticalCenter: parent.verticalCenter
              charId: modelData
              skinId: sData.chars1[modelData]
            }
          }

          AppText {
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: sp(18)
            color: Theme.secondaryTextColor

            text: "vs"
          }

          Repeater {
            model: chars2

            StockIcon {
              anchors.verticalCenter: parent.verticalCenter
              charId: modelData
              skinId: sData.chars2[modelData]
            }
          }

          AppText {
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: sp(20)
            color: Theme.tintColor

            text: qsTr("%1 (%2)").arg(sData.name2).arg(sData.code2)
          }
        }
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
