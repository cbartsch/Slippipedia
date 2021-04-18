import QtQuick 2.0
import QtQuick.Layouts 1.0
import Felgo 3.0

import Slippipedia 1.0

Column {
  property RangeSettings range: null

  property real labelWidth: -1

  property alias label: label
  property alias inputFrom: inputFrom
  property alias inputTo: inputTo

  property var textFunc: (v => v)
  property var valueFunc: (v => v)

  anchors.left: parent.left
  anchors.right: parent.right

  RowLayout {
    width: parent.width
    height: inputFrom.height
    spacing: 0

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
        onTextChanged: {
          if(text) {
            var newValue = valueFunc(text, inputFrom)
            if(typeof newValue !== "undefined") {
              range.from = newValue
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
        onTextChanged: {
          if(text) {
            var newValue = valueFunc(text, inputTo)
            if(typeof newValue !== "undefined") {
              range.to = newValue
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
