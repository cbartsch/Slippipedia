pragma Singleton
import QtQuick 2.0

Item {
  readonly property string versionCode: system ? system.appVersionCode : ""
  readonly property string versionName: system ? system.appVersionName : ""
  readonly property string buildName: system && system.publishBuild ? "Release" : "Debug"

  readonly property string felgoVersion: system ? system.felgoVersion : ""
  readonly property string qtVersion: system ? system.qtVersion : ""

  readonly property string twitterUrl: "https://twitter.com/ChrisuSSBMtG"
  readonly property string patreonUrl: "https://www.patreon.com/chrisu"
  readonly property string githubUrl: "https://github.com/cbartsch/Slippipedia"
  readonly property string homeUrl: "https://cbartsch.github.io"
  readonly property string discordUrl: "http://daft.homes"

  readonly property string slippiUrl: "https://slippi.gg"
  readonly property string slippcUrl: "https://github.com/pcrain/slippc"
  readonly property string felgoUrl: "https://felgo.com"

  readonly property string ffmpegUrl: "https://ffmpeg.org/download.html"
  readonly property url desktopAppDownloadUrl: "https://slippi.gg/downloads"
}
