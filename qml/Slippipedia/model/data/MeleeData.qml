pragma Singleton
import QtQuick 2.0
import Felgo 4.0

Item {

  // data structs

  // all IDs:
  // https://github.com/project-slippi/slippi-wiki/blob/master/SPEC.md#melee-ids
  // https://docs.google.com/spreadsheets/d/1JX2w-r2fuvWuNgGb6D3Cs4wHQKLFegZe2jhbBuIhCG8/preview#gid=20

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

  // number of skins per character
  readonly property var numSkins: [
    6, // cf
    5, // dk
    4, // fox
    4, // gnw
    6, // kirby
    4, // bowser
    5, // link
    4, // luigi
    5, // mario
    5, // marth
    4, // mewtwo
    4, // ness
    5, // peach
    4, // pikachu
    4, // ics
    5, // jigglypuff
    5, // samus
    6, // yoshi
    5, // zelda
    5, // sheik
    4, // falco
    5, // yl
    5, // doc
    5, // roy
    4, // pichu
    5 // ganon
  ]

  // kill direction index -> text
  readonly property var killDirectionNames: [
    "None",
    "Up", "Right", "Down", "Left",
    "Up-Right", "Up-Left", "Down-Right", "Down-Left"
  ]

  // the diagonal ones seem to never occur in real games
  readonly property var killDirectionNamesUsed: [
    "None", "Up", "Right", "Down", "Left"
  ]

  // dynamic id -> text
  readonly property var dynamicNames: [
    "None", "Recovering", "Escaping", "Punished", "Grounding", "Pressured",
    "Defensive", "Trading", "Poking", "Neutral", "Positioning", "Footsies",
    "Offensive", "Pressuring", "Sharking", "Punishing", "Techchasing", "Edgeguarding"
  ]

  // Attack IDs: https://docs.google.com/spreadsheets/d/1spibzWaitiA22s7db1AEw1hqQXzPDNFZHYjc4czv2dc/preview#gid=1743381614

  // move id -> name
  readonly property var moveNames: [
    "(none)",
    "Miscellaneous", //Fizzi: "This includes all thrown items, zair, luigi's taunt, samus bombs, etc"
    "Jab 1", "Jab 2", "Jab 3", "Rapid Jab", "Dash Attack",
    "Forward Tilt", "Up Tilt", "Down Tilt",
    "Forward Smash", "Up Smash", "Down Smash",
    "Neutral Air", "Forward Air", "Back Air", "Up Air", "Down Air",
    "Neutral Special", "Side Special", "Up Special", "Down Special",
    "22","23","24","25","26","27","28","29","30","31",
    "32","33","34","35","36","37","38","39","40","41",
    "42","43","44","45","46","47","48","49",
    "Getup Attack (Back)", "Getup Attack (Front)", "Pummel",
    "Forward Throw", "Back Throw", "Up Throw", "Down Throw",
    "Cargo Forward Throw","Cargo Back Throw", "Cargo Up Throw", "Cargo Down Throw",
    "Edge Getup", "Edge Getup (100%+)",
    "Beam Sword Jab", "Beam Sword Tilt Swing", "Beam Sword Smash Swing", "Beam Sword Dash Swing",
    "Homerun Bat Jab", "Homerun Bat Tilt Swing", "Homerun Bat Smash Swing", "Homerun Bat Dash Swing",
    "Parasol Jab","Parasol Tilt Swing","Parasol Smash Swing","Parasol Dash Swing",
    "Fan Jab","Fan Tilt Swing","Fan Smash Swing","Fan Dash Swing",
    "Star Rod Jab","Star Rod Tilt Swing","Star Rod Smash Swing","Star Rod Dash Swing",
    "Lip's Stick Jab","Lip's Stick Tilt Swing","Lip's Stick Smash Swing","Lip's Stick Dash Swing",
    "Open parasol",
    "88","89","90",
    "91","92","93","94","95","96","97","98","99","100",
    "101","102","103","104","105","106","107","108","109","110",
    "111","112","113","114","115","116","117","118","119","120",
    "121","122","123","124","125","126","127","128","129","130",
    "131","132","133","134","135","136","137","138","139","140",
    "141","142","143","144","145","146","147","148","149","150",
    "151","152","153","154","155","156","157","158","159","160",
    "161","162","163","164","165","166","167","168","169","170",
    "171","172","173","174","175","176","177","178","179","180",
    "181","182","183","184","185","186","187","188","189","190",
    "191","192","193","194","195","196","197","198","199","200",
    "201","202","203","204","205","206","207","208","209","210",
    "211","212","213","214","215","216","217","218","219","220",
    "221","222","223","224","225","226","227","228","229","230",
    "231","232","233","234","235","236","237","238","239","240",
    "241","242","243","244","245","246","247","248","249","250",
    "251","252","253","254",
    "[Bubble]",
  ]

  // move id -> name
  readonly property var moveNamesUsed: [
    "Miscellaneous",
    "Jab 1", "Jab 2", "Jab 3", "Rapid Jab", "Dash Attack",
    "Forward Tilt", "Up Tilt", "Down Tilt",
    "Forward Smash", "Up Smash", "Down Smash",
    "Neutral Air", "Forward Air", "Back Air", "Up Air", "Down Air",
    "Neutral Special", "Side Special", "Up Special", "Down Special",
    "Getup Attack (Back)", "Getup Attack (Front)", "Pummel",
    "Forward Throw", "Back Throw", "Up Throw", "Down Throw",
    "Edge Getup", "Edge Getup (100%+)",
    "Open parasol",
  ]

  // move id -> name
  readonly property var moveNamesShort: [
    "(none)",
    "Misc",
    "Jab1", "Jab2", "Jab3", "Jabs", "DashAtk",
    "FTilt", "UpTilt", "DTilt",
    "FSmash", "UpSmash", "DSmash",
    "NAir", "FAir", "BAir", "UpAir", "DAir",
    "Neutral B", "Side B", "Up B", "Down B",
    "22","23","24","25","26","27","28","29","30","31",
    "32","33","34","35","36","37","38","39","40","41",
    "42","43","44","45","46","47","48","49",
    "GetupBack", "GetupFront", "Pummel",
    "FThrow", "BThrow", "UpThrow", "DThrow",
    "CFThrow","CBThrow", "CUThrow", "CDThrow",
    "SlowEdge", "FastEdge",
    "BS Jab", "BS TSwing", "BS SSwing", "BS DSwing",
    "HRB Jab", "HRB TSwing", "HRB SSwing", "HRB DSwing",
    "Prs Jab","Prs TSwing","Prs SSwing","Prs DSwing",
    "Fan Jab","Fan TSwing","Fan SSwing","Fan DSwing",
    "SR Jab","SR TSwing","SR SSwing","SR DSwing",
    "LS Jab","LS TSwing","LS SSwing","LS DSwing",
    "Parasol",
    "88","89","90",
    "91","92","93","94","95","96","97","98","99","100",
    "101","102","103","104","105","106","107","108","109","110",
    "111","112","113","114","115","116","117","118","119","120",
    "121","122","123","124","125","126","127","128","129","130",
    "131","132","133","134","135","136","137","138","139","140",
    "141","142","143","144","145","146","147","148","149","150",
    "151","152","153","154","155","156","157","158","159","160",
    "161","162","163","164","165","166","167","168","169","170",
    "171","172","173","174","175","176","177","178","179","180",
    "181","182","183","184","185","186","187","188","189","190",
    "191","192","193","194","195","196","197","198","199","200",
    "201","202","203","204","205","206","207","208","209","210",
    "211","212","213","214","215","216","217","218","219","220",
    "221","222","223","224","225","226","227","228","229","230",
    "231","232","233","234","235","236","237","238","239","240",
    "241","242","243","244","245","246","247","248","249","250",
    "251","252","253","254",
    "[Bubble]",
  ]

  // move id -> name
  readonly property var moveNamesShortUsed: [
    "Misc",
    "Jab1", "Jab2", "Jab3", "Jabs", "DashAtk",
    "FTilt", "UpTilt", "DTilt",
    "FSmash", "UpSmash", "DSmash",
    "NAir", "FAir", "BAir", "UpAir", "DAir",
    "Neutral B", "Side B", "Up B", "Down B",
    "GetupBack", "GetupFront", "Pummel",
    "FThrow", "BThrow", "UpThrow", "DThrow",
    "SlowEdge", "FastEdge",
    "Parasol",
  ]

  // move name -> id
  readonly property var moveIds: moveNames.reduce((acc, val, index) => {
                                                    acc[val] = index
                                                    return acc
                                                  }, {})

  // move name -> id
  readonly property var moveIdsShort: moveNamesShort.reduce((acc, val, index) => {
                                                              acc[val] = index
                                                              return acc
                                                            }, {})

  readonly property var portColors: [
    "red", "blue", "yellow", "green"
  ]
}
