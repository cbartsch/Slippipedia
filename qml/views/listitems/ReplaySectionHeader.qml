import QtQuick 2.0
import QtQuick.Layouts 1.12
import Felgo 3.0

import "../controls"
import "../icons"
import "../../model"
import "../../pages"

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

  signal showStats

  Rectangle {
    anchors.fill: parent
    color: Theme.backgroundColor
  }

  ColumnLayout {
    id: content
    anchors.fill: parent
    anchors.margins: dp(Theme.contentPadding)

    Item {
      Layout.fillHeight: true
      width: parent.width

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

    RowLayout {
      Layout.preferredWidth: parent.width

      Column {
        Layout.fillWidth: true

        AppText {
          font.pixelSize: dp(16)
          color: Theme.secondaryTextColor

          width: parent.width
          text: !sData ? "" : dataModel.formatDate(sData.dateFirst) + " - " + dataModel.formatDate(sData.dateLast)
        }

        AppText {
          Layout.preferredWidth: parent.width
          font.pixelSize: dp(16)
          color: Theme.secondaryTextColor

          width: parent.width
          text: !sData ? "" : !dataModel.playerFilter.hasPlayerFilter ? "Configure name filter to see win rate"
                                                                      : qsTr("Games won: %1 / %2 (%3). Games not finished: %4")
          .arg(sData.gamesWon).arg(sData.gamesFinished)
          .arg(dataModel.formatPercentage(sData.gamesWon / sData.gamesFinished))
          .arg(sData.numGames - sData.gamesFinished)

          RippleMouseArea {
            anchors.fill: parent
            onClicked: showFilteringPage()
          }
        }
      }

      AppToolButton {
        Layout.preferredWidth: implicitWidth

        iconType: IconType.barchart
        toolTipText: "Show statistics for session"

        onClicked: showStats()
      }
    }
  }
}
