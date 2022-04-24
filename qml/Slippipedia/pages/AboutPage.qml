import QtQuick 2.0
import QtGraphicalEffects 1.0
import Felgo 3.0

import Slippipedia 1.0

BasePage {

  title: "About"

  flickable.contentHeight: content.height

  readonly property real iconSize: dp(40)
  readonly property color pinkColor: "#FF51AD"

  Column {
    id: content

    width: parent.width

    AppListItem {
      text: "Slippipedia " + Constants.versionName
      detailText: qsTr("%1 build (v%2)").arg(Constants.buildName).arg(Constants.versionCode)
      textFontSize: sp(24)
      height: iconSize * 2.5
      textVerticalSpacing: dp(Theme.contentPadding) / 2

      enabled: false
      backgroundColor: Theme.backgroundColor

      leftItem: Item {
        anchors.verticalCenter: parent.verticalCenter
        height: iconSize * 1.75
        width: height

        AppImage {
          anchors.fill: parent
          source: "../../../assets/img/icon.png"
          fillMode: Image.PreserveAspectFit

          mipmap: true
        }
      }
    }

    SimpleSection {
      title: "Dev"
    }

    AppListItem {
      text: "Made by Chrisu"

      enabled: false
      backgroundColor: Theme.backgroundColor
    }

    CustomListItem {
      text: "Follow me on Twitter"
      detailText: Constants.twitterUrl

      hasExternalLink: true
      backgroundColor: Theme.controlBackgroundColor

      leftItem: Item {
        anchors.verticalCenter: parent.verticalCenter
        height: iconSize
        width: height

        Icon {
          icon: IconType.twitter
          color: "#1DA1F2"
          size: parent.height
          anchors.centerIn: parent
        }
      }

      onSelected: nativeUtils.openUrl(Constants.twitterUrl)
    }

    CustomListItem {
      text: "Source code at GitHub"
      detailText: Constants.githubUrl

      hasExternalLink: true
      backgroundColor: Theme.controlBackgroundColor

      leftItem: Item {
        anchors.verticalCenter: parent.verticalCenter
        height: iconSize
        width: height

        Icon {
          icon: IconType.github
          color: Theme.tintColor
          size: parent.height
          anchors.centerIn: parent
        }
      }
      onSelected: nativeUtils.openUrl(Constants.githubUrl)
    }

    CustomListItem {
      text: "Support me on Patreon"
      detailText: Constants.patreonUrl

      hasExternalLink: true
      backgroundColor: Theme.controlBackgroundColor

      leftItem: Item {
        anchors.verticalCenter: parent.verticalCenter
        height: iconSize
        width: height

        AppImage {
          id: patreonImg
          anchors.fill: parent
          visible: false
          source: "../../../assets/img/patreon-logo.png"
          fillMode: Image.PreserveAspectFit
        }

        ColorOverlay {
          anchors.fill: parent
          source: patreonImg
          color: pinkColor
        }
      }

      onSelected: nativeUtils.openUrl(Constants.patreonUrl)
    }

    CustomListItem {
      text: "More of my Stuff"
      detailText: Constants.homeUrl

      hasExternalLink: true
      backgroundColor: Theme.controlBackgroundColor

      leftItem: Item {
        anchors.verticalCenter: parent.verticalCenter
        height: iconSize
        width: height

        Icon {
          icon: IconType.home
          color: pinkColor
          size: parent.height
          anchors.centerIn: parent
        }
      }
      onSelected: nativeUtils.openUrl(Constants.homeUrl)
    }

    SimpleSection {
      title: "Credits"
    }

    CustomListItem {
      text: "Using Slippc replay parser library"
      detailText: Constants.slippcUrl

      hasExternalLink: true
      backgroundColor: Theme.controlBackgroundColor

      leftItem: Item {
        anchors.verticalCenter: parent.verticalCenter
        height: iconSize
        width: height

        Icon {
          icon: IconType.github
          color: "white"
          size: parent.height
          anchors.centerIn: parent
        }
      }

      onSelected: nativeUtils.openUrl(Constants.slippcUrl)
    }

    CustomListItem {
      text: "Made for use with Project Slippi"
      detailText: Constants.slippiUrl

      hasExternalLink: true
      backgroundColor: Theme.controlBackgroundColor

      leftItem: Item {
        height: iconSize
        width: height
        anchors.verticalCenter: parent.verticalCenter

        AppImage {
          id: slippiImg
          anchors.fill: parent
          visible: false
          source: "../../../assets/img/slippi.svg"
          fillMode: Image.PreserveAspectFit
        }

        ColorOverlay {
          anchors.fill: parent
          source: slippiImg
          color: Theme.tintColor
        }
      }

      onSelected: nativeUtils.openUrl(Constants.slippiUrl)
    }

    CustomListItem {
      text: qsTr("Built with Felgo %1 (based on Qt %2)").arg(Constants.felgoVersion).arg(Constants.qtVersion)
      detailText: Constants.felgoUrl

      hasExternalLink: true
      backgroundColor: Theme.controlBackgroundColor

      leftItem: AppImage {
        source: "../../../assets/img/felgo-logo.png"

        height: iconSize
        width: height
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
      }

      onSelected: nativeUtils.openUrl(Constants.felgoUrl)
    }

    CustomListItem {
      text: "Shoutouts to DAFT Home <3"
      detailText: "And everyone else who helped test and improve this app"

      hasExternalLink: true
      backgroundColor: Theme.controlBackgroundColor

      leftItem: AppImage {
        source: "../../../assets/img/daft.png"

        height: iconSize
        width: height
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
      }

      onSelected: nativeUtils.openUrl(Constants.discordUrl)
    }
  }
}
