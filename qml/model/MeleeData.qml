pragma Singleton
import QtQuick 2.0
import Felgo 3.0

Item {

  // data structs

  // stages. sssIndex = index on a 9x3 grid on stage select screen
  readonly property var stageMap: {
    0: { id: 0,   name: "Other stages",       shortName: "Other", sssIndex: -1 },
    32: { id: 32, name: "Final Destination",  shortName: "FD",    sssIndex: 23 },
    31: { id: 31, name: "Battlefield",        shortName: "BF",    sssIndex: 22  },
    3: { id: 3,   name: "Pokémon Stadium",    shortName: "PS",    sssIndex: 19  },
    28: { id: 28, name: "Dreamland",          shortName: "DL",    sssIndex: 1  },
    2: { id: 2,   name: "Fountain of Dreams", shortName: "FoD",   sssIndex: 9  },
    8: { id: 8,   name: "Yoshi's Story",      shortName: "YS",    sssIndex: 7  },
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

  // char id -> css index (on a 9x3 grid)
  readonly property var charCssIndices: [
    7, // cf
    6, // dk
    10, // fox
    23, // gnw
    13, // kirby
    3, // bowser
    16, // link
    2, // luigi
    1, // mario
    24, // marth
    22, // mewtwo
    11, // ness
    4, // peach
    20, // pikachu
    12, // ics
    21, // jigglypuff
    14, // samus
    5, // yoshi
    15, // zelda
    15, // sheik (also zelda)
    9, // falco
    17, // yl
    0, // doc
    25, // roy
    19, // pichu
    8 // ganon
  ]

  // css index (on a 9x3 grid) -> char id
  readonly property var cssCharIds: [...Array(27).keys()].map(index => charCssIndices.indexOf(index))
}
