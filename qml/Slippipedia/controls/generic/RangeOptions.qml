import QtQuick 2.0
import QtQuick.Layouts 1.0
import Felgo 4.0

import Slippipedia 1.0

Column {
  id: rangeOptions

  property RangeSettings range: null

  property real labelWidth: -1

  property alias label: label
  property alias inputFrom: inputFrom
  property alias inputTo: inputTo

  property var textFunc: (v => v)
  property var valueFunc: (v => v)
  property string validationText: ""

  anchors.left: parent.left
  anchors.right: parent.right

  RowLayout {
    width: parent.width
    height: inputFrom.height
    spacing: dp(1)

    AppText {
      id: label

      Layout.leftMargin: dp(Theme.contentPadding)
      Layout.preferredWidth: labelWidth
    }

    Item {
      height: dp(48)
      Layout.fillWidth: true

      TextInputField {
        id: inputFrom

        anchors.leftMargin: dp(Theme.contentPadding)

        labelText: ""
        placeholderText: "From..."

        labelWidth: 0
        showOptions: false

        textInput.inputMethodHints: Qt.ImhDigitsOnly
        divider.visible: false

        text: range && range.from >= 0 ? textFunc(range.from, inputFrom) : ""

        validationError: typeof value === "undefined"
        validationText: rangeOptions.validationText

        readonly property var value: text ? valueFunc(text, inputFrom) : null

        onValueChanged: {
          if(!range) return

          if(text) {
            if(typeof value !== "undefined") {
              range.from = value
            }
          }
          else {
            range.from = -1
          }
        }
      }
    }

    Item {
      height: dp(48)
      Layout.fillWidth: true

      TextInputField {
        id: inputTo

        labelText: ""
        placeholderText: "To..."

        labelWidth: 0
        showOptions: false

        textInput.inputMethodHints: Qt.ImhDigitsOnly
        divider.visible: false

        text: range && range.to >= 0 ? textFunc(range.to, inputTo) : ""

        validationError: typeof value === "undefined"
        validationText: rangeOptions.validationText

        readonly property var value: text ? valueFunc(text, inputTo) : null

        onValueChanged: {
          if(!range) return

          if(text) {
            if(typeof value !== "undefined") {
              range.to = value
            }
          }
          else {
            range.to = -1
          }
        }
      }
    }
  }

  Divider { anchors.bottom: undefined }
}
