import Felgo 3.0

import QtQuick 2.0

BasePage {
  title: qsTr("Filtering")

  flickable.contentHeight: content.height

  Column {
    id: content
    width: parent.width

    SimpleSection {
      title: "Slippi Code"
    }

    AppTextInput {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: Theme.contentPadding
      height: dp(48)
      color: Theme.textColor

      text: dataModel.slippiCode
      placeholderText: "Enter your Slippi code..."

      onAccepted: dataModel.slippiCode = text
    }
  }
}
