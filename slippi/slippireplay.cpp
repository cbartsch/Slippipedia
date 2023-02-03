#include "slippireplay.h"

#include <QtDebug>

SlippiReplay::SlippiReplay(QObject *parent) : QObject(parent)
{

}

SlippiReplay::~SlippiReplay() {
}

void SlippiReplay::fromAnalysis(const QString &filePath, slip::Analysis *analysis, const slip::SlippiReplay *replay) {
  if(analysis == nullptr) {
    return;
  }

  m_date = QDateTime::fromString(QString::fromStdString(analysis->game_time), Qt::DateFormat::ISODate);
  m_stageId = analysis->stage_id;
  m_gameDuration = analysis->game_length;
  m_winningPlayerPort = analysis->winner_port;
  m_lrasPlayerIndex = analysis->lras_player;
  m_endType = EndType(analysis->end_type);
  m_filePath = filePath;
  m_platform = QString::fromStdString(replay->played_on);
  m_slippiVersion = QString::fromStdString(replay->slippi_version);

  m_matchId = QString::fromStdString(replay->match_id);
  m_gameNumber = replay->game_number;
  m_tiebreakerNumber = replay->tiebreaker_number;

  if(m_matchId.startsWith("mode.ranked")) {
    m_gameMode = Ranked;
  }
  else if(m_matchId.startsWith("mode.unranked")) {
    m_gameMode = Unranked;
  }
  else if(m_matchId.startsWith("mode.direct")) {
    m_gameMode = Direct;
  }
  else {
    m_gameMode = Unknown;
  }
  // TODO spectate/mirror?

  // compute pseudo-unique hash for game
  qint64 uniqueId = 0;
  uniqueId = m_date.toSecsSinceEpoch();
  uniqueId = uniqueId * 17 + m_stageId;
  uniqueId = uniqueId * 17 + m_gameDuration;

  m_uniqueId = uniqueId;

  // parser currently only supports singles matches

  auto &p1 = analysis->ap[0];
  auto &p2 = analysis->ap[1];
  m_players << QVariant::fromValue(new PlayerData(this, *analysis, p1, p2));
  m_players << QVariant::fromValue(new PlayerData(this, *analysis, p2, p1));
}

PlayerData::PlayerData(QObject *parent, const slip::Analysis &analysis,
                       const slip::AnalysisPlayer &p, const slip::AnalysisPlayer &o)
  : QObject(parent) {

  m_port = p.port;
  m_isWinner = analysis.winner_port == m_port;

  m_slippiName = QString::fromStdString(p.tag_player);
  m_slippiCode = QString::fromStdString(p.tag_code);
  m_inGameTag = QString::fromStdString(p.tag_css);

  m_charId = p.char_id;
  m_charSkinId = p.color;

  unsigned int aIndex = 0;

  for(unsigned int pIndex = 0; pIndex < MAX_PUNISHES; pIndex++) {
    if(p.punishes[pIndex].end_frame == 0) {
      break;
    }

    m_punishes << QVariant::fromValue(new PunishData(this, analysis, p, o, pIndex, aIndex));

    while(p.attacks[aIndex].punish_id == pIndex && aIndex < MAX_ATTACKS) {
      aIndex++;
    }
  }

  m_stats["endStocks"] = p.end_stocks;
  m_stats["selfDestructs"] = p.self_destructs;

  auto stocksLost = p.start_stocks - p.end_stocks - p.self_destructs;
  auto stocksTaken = o.start_stocks - o.end_stocks - o.self_destructs;
  m_stats["stocksLost"] = stocksLost;
  m_stats["stocksTaken"] = stocksTaken;

  m_stats["endPercent"] = p.end_pct;
  m_stats["startStocks"] = p.start_stocks;
  m_stats["damageDealt"] = p.damage_dealt;

  m_stats["openings"] = p.total_openings;
  m_stats["damagePerOpening"] = p.mean_opening_percent;
  m_stats["openingsPerKill"] = p.mean_kill_openings;
  m_stats["killPercent"] = p.mean_kill_percent;
  m_stats["totalKillPercent"] = p.mean_kill_percent * stocksTaken;

  m_stats["taunts"] = p.taunts;
  m_stats["grabs"] = p.grabs;
  m_stats["grabsEscaped"] = o.grab_escapes;
  m_stats["grabEscapes"] = p.grab_escapes;
  m_stats["ledgeGrabs"] = p.ledge_grabs;

  m_stats["apm"] = p.apm;
  m_stats["aspm"] = p.aspm;

  qreal gameDurationMinutes = (qreal)analysis.game_length / 60 / 60;
  m_stats["totalActions"] = p.apm * gameDurationMinutes;
  m_stats["buttonsPressed"] = p.button_count;
  m_stats["analogStickMoves"] = p.astick_count;
  m_stats["cStickMoves"] = p.cstick_count;
  m_stats["stateChanges"] = p.state_changes;
  // note: p.state_changes is not, like the comment says, analog movoes
  // it is just total state changes (aspm * time)
  // thus we don't need to save the aspm value

  m_stats["pivots"] = p.pivots;
  m_stats["wavedashes"] = p.wavedashes;
  m_stats["wavelands"] = p.wavelands;
  m_stats["dashdances"] = p.dashdances;

  m_stats["airdodges"] = p.airdodges;
  m_stats["spotdodges"] = p.spotdodges;
  m_stats["rolls"] = p.rolls;

  m_stats["techs"] = p.techs;
  m_stats["missedTechs"] = p.missed_techs;
  m_stats["walltechs"] = p.walltechs;
  m_stats["walltechjumps"] = p.walltechjumps;
  m_stats["walljumps"] = p.walljumps;

  m_stats["lCancels"] = p.l_cancels_hit;
  m_stats["lCancelsMissed"] = p.l_cancels_missed;
  m_stats["ledgedashes"] = p.galint_ledgedashes;
  m_stats["avgGalint"] = p.mean_galint;
  m_stats["maxGalint"] = p.max_galint;
  m_stats["totalGalint"] = p.mean_galint * p.galint_ledgedashes;

  m_stats["edgeCancelAerials"] = p.edge_cancel_aerials;
  m_stats["edgeCancelSpecials"] = p.edge_cancel_specials;
  m_stats["teeterCancelAerials"] = p.teeter_cancel_aerials;
  m_stats["teeterCancelSpecials"] = p.teeter_cancel_specials;
}

PunishData::PunishData(QObject *parent, const slip::Analysis &analysis,
                       const slip::AnalysisPlayer &p, const slip::AnalysisPlayer &o,
                       int punishIndex, int firstAttackIndex)
  : QObject(parent)
{
  // maybe useful for stats added later:
  Q_UNUSED(analysis)
  Q_UNUSED(o)

  auto &punish = p.punishes[punishIndex];

  m_numMoves = punish.num_moves;

  m_startPercent = punish.start_pct;
  m_endPercent = punish.end_pct;
  m_stocks = punish.stocks;

  m_startFrame = punish.start_frame;
  m_endFrame = punish.end_frame;

  m_killDirection = Direction(punish.kill_dir);

  auto *firstAttack = &p.attacks[firstAttackIndex];
  auto *lastAttack = firstAttack;

  for(auto attack = firstAttack; attack->punish_id == punishIndex && attack < p.attacks + MAX_ATTACKS; attack++) {
    lastAttack = attack;
  }

  m_openingDynamic = Dynamic(firstAttack->opening);
  m_openingMoveId = firstAttack->move_id;
  m_lastMoveId = punish.last_move_id;

  // compute pseudo-unique hash for game
  qint64 uniqueId = 0;
  uniqueId = m_startFrame;
  uniqueId = uniqueId * 17 + m_endFrame;
  uniqueId = uniqueId * 17 + m_startPercent;
  uniqueId = uniqueId * 17 + m_endPercent;
  uniqueId = uniqueId * 17 + m_killDirection;
  uniqueId = uniqueId * 17 + m_numMoves;
  uniqueId = uniqueId * 17 + m_openingMoveId;
  uniqueId = uniqueId * 17 + m_lastMoveId;

  m_uniqueId = uniqueId;
}
