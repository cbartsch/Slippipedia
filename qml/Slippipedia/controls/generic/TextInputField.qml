import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.0

import Felgo 3.0

import Slippipedia 1.0

Item {
  id: textInputField

  anchors.left: parent.left
  anchors.right: parent.right
  height: dp(48)

  property alias divider: divider

  property alias label: label
  property alias labelText: label.text
  property real labelWidth: dp(120)

  property alias textInput: input
  property alias text: input.text
  property alias placeholderText: input.placeholderText

  property bool showOptions: true
  property alias matchCaseSensitive: toolBtnCase.checked
  property alias matchPartialText: toolBtnPartial.checked

  signal accepted
  signal editingFinished

  Rectangle {
    anchors.fill: ripple
    color: Theme.controlBackgroundColor
  }

  RippleMouseArea {
    id: ripple
    anchors.fill: parent
    anchors.leftMargin: label.width > 0 ? label.width + dp(Theme.contentPadding) : 0

    onClicked: input.forceActiveFocus()

    hoverEffectEnabled: true
    backgroundColor: Theme.listItem.selectedBackgroundColor
    fillColor: backgroundColor
    opacity: 0.5
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

      maximumLineCount: 1
      elide: Text.ElideRight
    }

    AppTextInput {
      id: input

      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      Layout.leftMargin: label.width > 0 ? dp(Theme.contentPadding) : 0

      color: Theme.textColor

      onAccepted: textInputField.accepted()
      onEditingFinished: textInputField.editingFinished()
    }

    AppToolButton {
      id: toolBtnCase
      text: "Aa"
      toolTipText: "Match case sensitive"
      Layout.alignment: Qt.AlignVCenter
      visible: showOptions
    }

    AppToolButton {
      id: toolBtnPartial
      text: "*"
      toolTipText: "Match partial text"
      Layout.alignment: Qt.AlignVCenter
      visible: showOptions
    }
  }

  Divider { id: divider }
}
