import QtQuick 2.0
import Felgo 3.0

import "../model"

AppListItem {
  text: qsTr("%1 (%2) vs %3 (%4)")
    .arg(name1).arg(code1)
    .arg(name2).arg(code2)

  backgroundColor: Theme.backgroundColor
  mouseArea.enabled: false

  detailText: qsTr("%1 (%2 stocks) / %3 (%4 stocks), time: %5, date: %6")
    .arg(MeleeData.charNames[char1])
    .arg(endStocks1)
    .arg(MeleeData.charNames[char2])
    .arg(endStocks2)
    .arg(dataModel.formatTime(duration))
    .arg(dataModel.formatDate(date))

  rightItem: IconButtonBarItem {
    icon: IconType.play
    onClicked: openReplay(filePath)
    height: width
    anchors.verticalCenter: parent.verticalCenter
  }

  function openReplay(filePath) {
    fileUtils.openFile(filePath)
  }
}
