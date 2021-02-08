#ifndef SLIPPIREPLAY_H
#define SLIPPIREPLAY_H

#include <QObject>
#include <QDateTime>
#include <QVariant>

#include "analysis.h"

struct PlayerData : public QObject {
  Q_OBJECT

  Q_PROPERTY(QString tag MEMBER m_tag)

public:
  PlayerData(QObject *parent);

private:
  QString m_tag;

  friend class SlippiReplay;
};

class SlippiReplay : public QObject
{
  Q_OBJECT

  Q_PROPERTY(qint64 uniqueId MEMBER m_uniqueId NOTIFY parsedFromAnalysis)
  Q_PROPERTY(QDateTime date MEMBER m_date NOTIFY parsedFromAnalysis)
  Q_PROPERTY(int stageId MEMBER m_stageId NOTIFY parsedFromAnalysis)
  Q_PROPERTY(int gameDuration MEMBER m_gameDuration NOTIFY parsedFromAnalysis)
  Q_PROPERTY(QString stageName MEMBER m_stageName NOTIFY parsedFromAnalysis)

  Q_PROPERTY(QVariantList players MEMBER m_players NOTIFY parsedFromAnalysis)
  Q_PROPERTY(int winningPlayerIndex MEMBER m_winningPlayerIndex NOTIFY parsedFromAnalysis)

public:
  explicit SlippiReplay(QObject *parent = nullptr);
  ~SlippiReplay();

  void fromAnalysis(slip::Analysis *analysis);

signals:
  void parsedFromAnalysis();

  void parsedFromAna(qint64 uniqueId);

private:
  QString m_stageName;
  int m_stageId;
  int m_gameDuration;
  QDateTime m_date;
  qint64 m_uniqueId;

  QVariantList m_players;
  int m_winningPlayerIndex;
};

#endif // SLIPPIREPLAY_H
