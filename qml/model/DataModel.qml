import QtQuick 2.0

import Qt.labs.settings 1.1

import Slippi 1.0

Item {
  id: dataModel

  property int dbUpdater: 0

  // replay settings
  property alias replayFolder: settings.replayFolder
  readonly property var allFiles: Utils.listFiles(replayFolder, ["*.slp"], true)
  property var newFiles: dataBase.getNewReplays(allFiles)

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
  readonly property var stageData: dataBase.getStageStats(dbUpdater)

  readonly property var charDataCss: MeleeData.cssCharIds.map((id, index) => {
                                                                var cd = charData[id]

                                                                return {
                                                                  id: id,
                                                                  count: cd ? cd.count : 0,
                                                                  name: cd ? cd.name : ""
                                                                }
                                                              })

  // filtering settings
  property TextFilter filterSlippiCode: TextFilter {
    id: filterSlippiCode
    onPropertyChanged: filterChanged()
  }
  property TextFilter filterSlippiName: TextFilter {
    id: filterSlippiName
    onPropertyChanged: filterChanged()
  }
  property alias filterCodeAndName: settings.filterCodeAndName
  readonly property bool hasPlayerFilter: filterSlippiCode.filterText != "" || filterSlippiName.filterText != ""
  property alias filterStageId: settings.stageId
  property var filterCharId: filterCharIds[0] || -1
  readonly property var filterCharIds: settings.charIds.map(id => ~~id) // settings stores as list of string, convert to int

  onFilterCodeAndNameChanged: filterChanged()
  onFilterCharIdChanged: filterChanged()

  signal filterChanged
  onFilterChanged: dbUpdaterChanged()

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
    if(filterStageId == 0) {
      sText = "Other stage"
    }
    else if(filterStageId > 0) {
      sText = "Stage: " + MeleeData.stageMap[filterStageId].name
    }

    var cText
    if(filterCharIds.length > 0) {
      sText = "Characters: " + filterCharIds.map(id => MeleeData.charNames[id]).join(", ")
    }

    return [pText, sText, cText].filter(_ => _).join(", ") || "(nothing)"
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

    property int stageId: 0 // -1 = no filter, 0 = "other" stages
    property var charIds: []
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

  // filtering

  function addCharFilter(charId) {
    settings.charIds = filterCharIds.concat(charId)
  }

  function removeCharFilter(charId) {
    var list = filterCharIds
    list.splice(list.indexOf(charId), 1)
    settings.charIds = list
  }

  // replay list

  function getReplayList(max, start) {
    return dataBase.getReplayList(max, start)
  }

  function resetFilters() {
    filterStageId = -1
    filterCharIds = []
    filterSlippiCode.reset()
    filterSlippiName.reset()
  }

  // utils

  function formatPercentage(amount) {
    return amount > 1
        ? "100%"
        : amount <= 0 || amount !== amount
          ? "0%"
          : qsTr("%1%").arg((amount * 100).toFixed(2))
  }

  function formatTime(numFrames) {
    var minutes = Math.floor(numFrames / 60 / 60)
    var seconds = Math.floor(numFrames / 60 % 60)

    return qsTr("%1:%2").arg(minutes).arg(seconds)
  }

  function formatDate(date) {
    return date.toLocaleString("dd/MM/yyyy HH:mm")
  }
}
