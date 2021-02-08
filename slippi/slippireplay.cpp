#include "slippireplay.h"

#include <QtDebug>

SlippiReplay::SlippiReplay(QObject *parent) : QObject(parent)
{

}

SlippiReplay::~SlippiReplay() {
 // qDebug() << "Replay destruction";
}

void SlippiReplay::fromAnalysis(slip::Analysis *analysis) {
  if(analysis == nullptr) {
    return;
  }

  m_date = QDateTime::fromString(QString::fromStdString(analysis->game_time), Qt::DateFormat::ISODate);
  m_stageId = analysis->stage_id;
  m_gameDuration = analysis->game_length;
  m_stageName = QString::fromStdString(analysis->stage_name);
  m_winningPlayerIndex = analysis->winner_port;

  // compute pseudo-unique hash for game
  qint64 uniqueId = 0;
  uniqueId = m_date.toSecsSinceEpoch();
  uniqueId = uniqueId * 17 + m_stageId;
  uniqueId = uniqueId * 17 + m_gameDuration;
  uniqueId = uniqueId * 17 + m_stageId;

  m_uniqueId = uniqueId;

  // parser currently only supports singles matches
  int numPlayers = 2;
  for(int i = 0; i < numPlayers; i++) {
    auto &p = analysis->ap[i];

    PlayerData *player = new PlayerData(this);

    player->m_tag = QString::fromStdString(p.tag_player);

    m_players << QVariant::fromValue(player);
  }
}

PlayerData::PlayerData(QObject *parent) : QObject(parent) {

}
