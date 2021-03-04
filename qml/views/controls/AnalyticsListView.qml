import QtQuick 2.0
import QtQuick.Layouts 1.0
import Felgo 3.0

import "../../model/data"
import "../listitems"
import "../icons"

Item {
  id: analyticsListView

  property var model

  property string infoText
  property string infoDetailText

  property bool showsCharacters: false
  property bool showsStages: false
  property bool sortByWinRate: true

  signal showList(int id)
  signal showStats(int id)

  // bugfix - sorting doesn't work otherwise
  Component.onCompleted: Qt.callLater(() => {
                                        sortByWinRate = !sortByWinRate
                                        sortByWinRate = !sortByWinRate
                                      })

  property Sorter winRateSorter: RoleSorter {
    roleName: "winRate"
    ascendingOrder: false
  }

  property Sorter countSorter: RoleSorter {
    roleName: "gamesFinished"
    ascendingOrder: false
  }

  property Sorter idSorter: RoleSorter {
    roleName: "id"
    ascendingOrder: false
  }

  AppListItem {
    id: header
    Layout.fillWidth: true

    text: infoText
    detailText: infoDetailText + " " + (sortByWinRate
                                        ? "Ordered by your win rate."
                                        : "Ordered by number of games.")

    enabled: false
    backgroundColor: Theme.backgroundColor
  }

  Item {
    anchors.fill: parent
    anchors.topMargin: header.height + dp(Theme.contentPadding)

    AppListView {
      id: listView

      emptyText.text: "No replays found."

      spacing: dp(Theme.contentPadding)

      model: SortFilterProxyModel {
        id: sfpm

        sorters: sortByWinRate ? [winRateSorter] : []

        sourceModel: JsonListModel {
          id: listModel
          source: analyticsListView.model
          keyField: "id"
        }
      }

      delegate: RowLayout {
        width: listView.width
        height: dp(72)

        Item {
          Layout.preferredHeight: 1
          Layout.preferredWidth: dp(Theme.contentPadding)
        }

        CharacterIcon {
          charId: ~~model.id
          visible: showsCharacters
          Layout.preferredWidth: height * 66/56
          Layout.preferredHeight: dp(56)
        }

        StageIcon {
          stageId: ~~model.id
          visible: showsStages
          Layout.preferredWidth: height * 62/48
          Layout.preferredHeight: dp(56)
        }

        Item {
          visible: showsStages || showsCharacters
          Layout.preferredHeight: 1
          Layout.preferredWidth: dp(Theme.contentPadding) / 2
        }

        AppText {
          Layout.alignment: Qt.AlignVCenter
          Layout.preferredWidth: dp(140)
          font.pixelSize: sp(20)
          color: Theme.tintColor

          text: model.name
        }

        Item {
          Layout.preferredHeight: 1
          Layout.preferredWidth: dp(Theme.contentPadding)
        }

        StatsInfoItem {
          Layout.preferredHeight: dp(48)
          Layout.fillWidth: true

          stats: model

          onShowList: analyticsListView.showList(model.id)
          onShowStats: analyticsListView.showStats(model.id)
        }

        Item {
          Layout.preferredHeight: 1
          Layout.preferredWidth: dp(Theme.contentPadding)
        }
      }
    }
  }
}
