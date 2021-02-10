pragma Singleton
import QtQuick 2.0
import Felgo 3.0

Item {

  // data structs

  // stages
  readonly property var stageMap: {
    32: { id: 32, name: "Final Destination", shortName: "FD" },
    31: { id: 31, name: "Battlefield", shortName: "BF" },
    3: { id: 3, name: "Pokémon Stadium", shortName: "PS" },
    28: { id: 28, name: "Dreamland", shortName: "DL" },
    2: { id: 2, name: "Fountain of Dreams", shortName: "FoD" },
    8: { id: 8, name: "Yoshi's Story", shortName: "YS" },
  }
  readonly property var stageData: Object.values(stageMap)
  readonly property var stageIds: stageData.map(obj => obj.id)

  // characters
  readonly property var charNames: [
    "Captain Falcon", "Donkey Kong", "Fox", "Mr. Game & Watch", "Kirby", "Bowser", "Link",
    "Luigi", "Mario", "Marth", "Mewtwo", "Ness", "Peach", "Pikachu", "Ice Climbers", "Jigglypuff",
    "Samus", "Yoshi", "Zelda", "Sheik", "Falco", "Young Link", "Dr. Mario", "Roy", "Pichu",
    "Ganondorf", "Master Hand", "Fighting Wire Frame ♂", "Fighting Wire Frame ♀",
    "Giga Bowser", "Crazy Hand", "Sandbag", "SoPo", "NONE"
  ]
  readonly property var charIds: charNames.map((obj, index) => index)

}
