#include "slippireplay.h"

#include <QtDebug>

SlippiReplay::SlippiReplay(QObject *parent) : QObject(parent)
{

}

SlippiReplay::~SlippiReplay() {
 // qDebug() << "Replay destruction";
}

void SlippiReplay::fromAnalysis(const QString &filePath, slip::Analysis *analysis) {
  if(analysis == nullptr) {
    return;
  }

  m_date = QDateTime::fromString(QString::fromStdString(analysis->game_time), Qt::DateFormat::ISODate);
  m_stageId = analysis->stage_id;
  m_gameDuration = analysis->game_length;
  m_winningPlayerIndex = analysis->winner_port;
  m_filePath = filePath;

  // compute pseudo-unique hash for game
  qint64 uniqueId = 0;
  uniqueId = m_date.toSecsSinceEpoch();
  uniqueId = uniqueId * 17 + m_stageId;
  uniqueId = uniqueId * 17 + m_gameDuration;
  uniqueId = uniqueId * 17 + m_stageId;

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

  m_stats["endStocks"] = p.end_stocks;
  m_stats["selfDestructs"] = p.self_destructs;
  m_stats["stocksLost"] = p.start_stocks - p.end_stocks - p.self_destructs;
  m_stats["stocksTaken"] = o.start_stocks - o.end_stocks - o.self_destructs;
  m_stats["endPercent"] = p.end_pct;
  m_stats["startStocks"] = p.start_stocks;
  m_stats["damageDealt"] = p.damage_dealt;

  m_stats["openings"] = p.total_openings;
  m_stats["damagePerOpening"] = p.mean_opening_percent;
  m_stats["openingsPerKill"] = p.mean_kill_openings;
  m_stats["killPercent"] = p.mean_kill_percent;

  m_stats["taunts"] = p.taunts;
  m_stats["grabs"] = p.grabs;
  m_stats["grabsEscaped"] = o.grab_escapes;
  m_stats["grabEscapes"] = p.grab_escapes;
  m_stats["ledgeGrabs"] = p.ledge_grabs;

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
  m_stats["totalGalint"] = p.mean_galint * p.galint_ledgedashes;

  m_stats["edgeCancelAerials"] = p.edge_cancel_aerials;
  m_stats["edgeCancelSpecials"] = p.edge_cancel_specials;
  m_stats["teeterCancelAerials"] = p.teeter_cancel_aerials;
  m_stats["teeterCancelSpecials"] = p.teeter_cancel_specials;
}
