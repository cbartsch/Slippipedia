import QtQuick 2.0

import Qt.labs.settings 1.1

import Slippi 1.0

Item {
  id: dataModel

  property int dbUpdater: 0

  // replay settings
  property alias replayFolder: settings.replayFolder
  readonly property var allFiles: Utils.listFiles(replayFolder, ["*.slp"], true)

  // analyze progress
  property bool progressCancelled: false
  property int numFilesSucceeded: 0
  property int numFilesFailed: 0
  property int numFilesProcessing: 0
  readonly property int numFilesProcessed: numFilesSucceeded + numFilesFailed
  readonly property bool isProcessing: !progressCancelled && numFilesProcessed < numFilesProcessing
  readonly property real processProgress: isProcessing ? numFilesProcessed / numFilesProcessing : 0

  // stats
  readonly property int totalReplays: dataBase.getNumReplays(dbUpdater)
  readonly property int totalReplaysFiltered: dataBase.getNumReplaysFiltered(dbUpdater)
  readonly property int totalReplaysFilteredWithResult: dataBase.getNumReplaysFilteredWithResult(dbUpdater)
  readonly property int totalReplaysFilteredWon: dataBase.getNumReplaysFilteredWon(dbUpdater)
  readonly property int totalReplaysFilteredWithTie: totalReplaysFiltered - totalReplaysFilteredWithResult

  readonly property real tieRate: dataModel.totalReplaysFilteredWithTie / dataModel.totalReplaysFiltered
  readonly property real winRate: dataModel.totalReplaysFilteredWon / dataModel.totalReplaysFilteredWithResult

  readonly property real otherStageAmount: dataBase.getOtherStageAmount(dbUpdater)

  readonly property real averageGameDuration: dataBase.getAverageGameDuration(dbUpdater)

  readonly property var charData: dataBase.getCharacterStats(dbUpdater)

  // filtering settings
  property TextFilter filterSlippiCode: TextFilter { id: filterSlippiCode }
  property TextFilter filterSlippiName: TextFilter { id: filterSlippiName }
  property alias filterCodeAndName: settings.filterCodeAndName
  readonly property bool hasPlayerFilter: filterSlippiCode.filterText != "" || filterSlippiName.filterText != ""
  property alias filterStageId: settings.stageId

  onFilterSlippiCodeChanged: dbUpdaterChanged()
  onFilterSlippiNameChanged: dbUpdaterChanged()
  onFilterCodeAndNameChanged: dbUpdaterChanged()
  onFilterStageIdChanged: dbUpdaterChanged()

  readonly property string filterDisplayText: {
    var pText
    var codeText = filterSlippiCode.filterText
    var nameText = filterSlippiName.filterText

    if(codeText && nameText) {
      pText = qsTr("%1/%2").arg(codeText).arg(nameText)
    }
    else {
      pText = codeText || nameText || ""
    }

    var sText
    if(filterStageId < 0) {
      sText = "Other stage"
    }
    else if(filterStageId > 0) {
      sText = "Stage: " + MeleeData.stageMap[filterStageId].name
    }

    return sText && pText ? (pText + ", " + sText) : sText || pText || "(nothing)"
  }

  onIsProcessingChanged: {
    if(!isProcessing) {
      dbUpdaterChanged() // refresh bindings
    }
  }

  Settings {
    id: settings

    property string replayFolder: ""
    property alias slippiCodeText: filterSlippiCode.filterText
    property alias slippiCodeCase: filterSlippiCode.matchCase
    property alias slippiCodePartial: filterSlippiCode.matchPartial
    property alias slippiNameText: filterSlippiName.filterText
    property alias slippiNameCase: filterSlippiName.matchCase
    property alias slippiNamePartial: filterSlippiName.matchPartial
    property bool filterCodeAndName: false // true: and, false: or
    property int stageId: 0 // 0 = no filter, -1 = "other" stages
  }

  SlippiParser {
    id: parser

    onReplayParsed: dataBase.analyzeReplay(filePath, replay)

    onReplayFailedToParse: {
      console.warn("Could not parse replay", filePath, ":", errorMessage)
      numFilesFailed++
    }
  }

  DataBase {
    id: dataBase
  }

  // replay / db management

  function parseReplays(replayFiles) {
    numFilesSucceeded = 0
    numFilesFailed = 0
    numFilesProcessing = replayFiles.length
    progressCancelled = false
    replayFiles.forEach(parseReplay)
  }

  function parseReplay(fileName) {
    parser.parseReplay(fileName)
  }

  function cancelAll() {
    parser.cancelAll()
  }

  function clearDatabase() {
    dataBase.clearAllData()

    dbUpdaterChanged() // refresh bindings
  }

  // stats

  function getStageAmount(stageId) {
    return dataBase.getStageAmount(stageId)
  }

  function getTopPlayerTags(max) {
    return dataBase.getTopPlayerTags(max)
  }

  // utils

  function formatPercentage(amount) {
    return amount > 1
        ? "100%"
        : amount <= 0
          ? "0%"
          : qsTr("%1%").arg((amount * 100).toFixed(2))
  }
}
