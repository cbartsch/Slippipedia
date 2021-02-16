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
    "Captain Falcon", "Donkey Kong", "Fox", "Mr. Game & Watch", "Kirby",
    "Bowser", "Link", "Luigi", "Mario", "Marth", "Mewtwo", "Ness", "Peach",
    "Pikachu", "Ice Climbers", "Jigglypuff", "Samus", "Yoshi",
    "Zelda/Sheik", // zelda and sheik are considered the same in stats
    "Sheik", "Falco", "Young Link", "Dr. Mario", "Roy", "Pichu",
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

  // X/Y positions of each character id stock icon in the sprite sheet
  readonly property var stockIconPositions: [
    Qt.point(1, 74), // cf
    Qt.point(407, 38), // dk
    Qt.point(490, 74), // fox
    Qt.point(140, 217), // gnw
    Qt.point(270, 109), // kirby
    Qt.point(454, 1), // bowser
    Qt.point(386, 146), // link
    Qt.point(328, 1), // luigi
    Qt.point(176, 1), // mario
    Qt.point(273, 217), // marth
    Qt.point(23, 217), // mewtwo
    Qt.point(14, 109), // ness
    Qt.point(56, 38), // peach
    Qt.point(310, 182), // pikachu
    Qt.point(142, 109), // ics
    Qt.point(440, 182), // jigglypuff
    Qt.point(445, 109), // samus
    Qt.point(218, 38), // yoshi
    Qt.point(62, 146), // zelda
    Qt.point(224, 146), // sheik
    Qt.point(354, 74), // falco
    Qt.point(22, 182), // yl
    Qt.point(35, 1), // doc
    Qt.point(434, 217), // roy
    Qt.point(182, 182), // pichu
    Qt.point(188, 74) // ganon
  ]

  // distance between skins in the sprite sheet
  readonly property var stockIconDistance: [
    Qt.point(28, 0), // cf
    Qt.point(29, 0), // dk
    Qt.point(29, 0), // fox
    Qt.point(29, 0), // gnw
    Qt.point(27, 0), // kirby
    Qt.point(29, 0), // bowser
    Qt.point(29, 0), // link
    Qt.point(27, 0), // luigi
    Qt.point(28, 0), // mario
    Qt.point(28, 0), // marth
    Qt.point(26, 0), // mewtwo
    Qt.point(28, 0), // ness
    Qt.point(29, 0), // peach
    Qt.point(29, 0), // pikachu
    Qt.point(29, 0), // ics
    Qt.point(28, 0), // jigglypuff
    Qt.point(29, 0), // samus
    Qt.point(29, 0), // yoshi
    Qt.point(29, 0), // zelda
    Qt.point(29, 0), // sheik
    Qt.point(29, 0), // falco
    Qt.point(29, 0), // yl
    Qt.point(26, 0), // doc
    Qt.point(29, 0), // roy
    Qt.point(29, 0), // pichu
    Qt.point(29, 0) // ganon
  ]
}
