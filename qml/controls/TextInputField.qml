import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.0

import Felgo 3.0

Rectangle {
  id: textInputField

  anchors.left: parent.left
  anchors.right: parent.right
  height: dp(48)
  color: Theme.controlBackgroundColor

  property alias label: label
  property alias labelText: label.text
  property real labelWidth: dp(120)

  property alias textInput: input
  property alias text: input.text
  property alias placeholderText: input.placeholderText

  property alias matchCaseSensitive: toolBtnCase.checked
  property alias matchPartialText: toolBtnPartial.checked

  signal accepted

  RippleMouseArea {
    anchors.fill: parent

    onClicked: input.forceActiveFocus()
  }

  RowLayout {
    anchors.fill: parent
    anchors.leftMargin: dp(Theme.contentPadding)
    anchors.rightMargin: dp(Theme.contentPadding)
    spacing: 0

    AppText {
      id: label

      Layout.preferredWidth: labelWidth
      Layout.alignment: Qt.AlignVCenter
    }

    AppTextInput {
      id: input

      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter

      color: Theme.textColor

      onAccepted: textInputField.accepted()
    }

    AppToolButton {
      id: toolBtnCase
      text: "Aa"
      toolTipText: "Match case sensitive"
      Layout.alignment: Qt.AlignVCenter
    }

    AppToolButton {
      id: toolBtnPartial
      text: "*"
      toolTipText: "Match partial text"
      Layout.alignment: Qt.AlignVCenter
    }
  }

  Divider { }
}
