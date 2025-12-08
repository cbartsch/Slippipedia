import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.0

import Felgo 4.0

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
  property alias splitText: toolBtnSplit.checked

  property bool validationError: false
  property string validationText: "Check input"

  property string toolTipText: ""

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

    onClicked: function(mouse) {
      input.forceActiveFocus()
      const pos = mapToItem(input, Qt.point(mouse.x, mouse.y))
      input.cursorPosition = input.positionAt(pos.x, pos.y)
    }

    hoverEffectEnabled: true
    backgroundColor: Theme.listItem.selectedBackgroundColor
    fillColor: backgroundColor
    opacity: 0.5
    cursorShape: Qt.PointingHandCursor
  }

  CustomToolTip {
    shown: ripple.containsMouse && !!text
    text: textInputField.toolTipText
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

    Item {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
      Layout.leftMargin: label.width > 0 ? dp(Theme.contentPadding) : 0

      AppTextField {
        id: input
        color: Theme.textColor

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        background: null
        leftPadding: 0
        rightPadding: 0
        font.pixelSize: label.font.pixelSize

        onAccepted: textInputField.accepted()
        onEditingFinished: textInputField.editingFinished()
      }
    }

    AppToolButton {
      id: toolBtnSplit
      text: ","
      toolTipText: "Split comma-separated"
      Layout.alignment: Qt.AlignVCenter
      visible: showOptions
      checkable: true
    }

    AppToolButton {
      id: toolBtnCase
      text: "Aa"
      toolTipText: "Match case sensitive"
      Layout.alignment: Qt.AlignVCenter
      visible: showOptions
      checkable: true
    }

    AppToolButton {
      id: toolBtnPartial
      text: "*"
      toolTipText: "Match partial text"
      Layout.alignment: Qt.AlignVCenter
      visible: showOptions
      checkable: true
    }
  }

  AppToolButton {
    id: validationIcon

    visible: validationError
    toolTipText: validationText

    mouseArea.hoverEffectEnabled: false
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.margins: dp(Theme.contentPadding)

    iconType: IconType.warning
    iconItem.color: "yellow"
  }

  Divider { id: divider }
}
