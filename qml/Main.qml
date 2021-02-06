import Felgo 3.0
import QtQuick 2.0
import QtQuick.Dialogs 1.2
import Slippi 1.0

App {
  // You get free licenseKeys from https://felgo.com/licenseKey
  // With a licenseKey you can:
  //  * Publish your games & apps for the app stores
  //  * Remove the Felgo Splash Screen or set a custom one (available with the Pro Licenses)
  //  * Add plugins to monetize, analyze & improve your apps (available with the Pro Licenses)
  //licenseKey: "<generate one from https://felgo.com/licenseKey>"

  NavigationStack {

    Page {
      title: qsTr("Main Page")

      AppButton {
        text: "Open SLP file"

        onClicked: fileDialog.open()
      }
    }
  }

  SlippiParser {
    id: parser
  }

  FileDialog {
    id: fileDialog
    title: "Please choose a file"
    nameFilters: ["Slippi Replays (*.slp)"]
    onAccepted: {
        console.log("You chose: " + fileDialog.fileUrls)

      var anal = parser.parseReplay(fileUtils.stripSchemeFromUrl(fileDialog.fileUrl))

      console.log("stage is", anal.stageName)
    }
    onRejected: {
        console.log("Canceled")
    }
  }
}
