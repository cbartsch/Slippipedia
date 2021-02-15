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
  int numPlayers = 2;
  for(int i = 0; i < numPlayers; i++) {
    auto &p = analysis->ap[i];

    PlayerData *player = new PlayerData(this);

    player->m_slippiName = QString::fromStdString(p.tag_player);
    player->m_slippiCode = QString::fromStdString(p.tag_code);
    player->m_inGameTag = QString::fromStdString(p.tag_css);
    player->m_charId = p.char_id;
    player->m_charSkinId = p.color;
    player->m_port = p.port;
    player->m_endStocks = p.end_stocks;
    player->m_endPercent = p.end_pct;
    player->m_startStocks = p.start_stocks;
    player->m_isWinner = m_winningPlayerIndex == i;

    m_players << QVariant::fromValue(player);
  }
}

PlayerData::PlayerData(QObject *parent) : QObject(parent) {

}
