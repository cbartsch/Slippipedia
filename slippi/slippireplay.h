#ifndef SLIPPIREPLAY_H
#define SLIPPIREPLAY_H

#include <QObject>
#include <QQmlEngine>
#include <QDateTime>
#include <QVariant>

#include "analysis.h"
#include "replay.h"

struct PunishData : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("Returned by SlippiParser")

  Q_PROPERTY(qint64 uniqueId MEMBER m_uniqueId)

  Q_PROPERTY(int numMoves MEMBER m_numMoves)
  Q_PROPERTY(Dynamic openingDynamic MEMBER m_openingDynamic)
  Q_PROPERTY(int openingMoveId MEMBER m_openingMoveId)
  Q_PROPERTY(int lastMoveId MEMBER m_lastMoveId)

  Q_PROPERTY(int startFrame MEMBER m_startFrame)
  Q_PROPERTY(int endFrame MEMBER m_endFrame)
  Q_PROPERTY(int durationFrames READ durationFrames CONSTANT)

  Q_PROPERTY(qreal startPercent MEMBER m_startPercent)
  Q_PROPERTY(qreal endPercent MEMBER m_endPercent)
  Q_PROPERTY(qreal stocks MEMBER m_stocks)
  Q_PROPERTY(qreal damage READ damage CONSTANT)

  Q_PROPERTY(bool didKill READ didKill CONSTANT)
  Q_PROPERTY(Direction killDirection MEMBER m_killDirection)

public:
  // same values as slip::Dir
  enum Direction {
    NoDir = 0, Up, Right, Down, Left, UpRight, UpLeft, DownRight, DownLeft,
  };
  Q_ENUM(Direction)

  // same values as slip::Dynamic
  enum Dynamic {
    None = 0, Recovering, Escaping, Punished, Grounding, Pressured,
    Defensive, Trading, Poking, Neutral, Positioning, Footsies,
    Offensive, Pressuring, Sharking, Punishing, Techchasing, Edgeguarding
  };
  Q_ENUM(Dynamic)

  PunishData(QObject *parent, const slip::Analysis &analysis,
             const slip::AnalysisPlayer &player, const slip::AnalysisPlayer &opponent,
             int punishIndex, int firstAttackIndex);

  inline bool didKill() const { return m_killDirection > NoDir; }
  inline qreal damage() const { return m_endPercent - m_startPercent; }
  inline int durationFrames() const { return m_endFrame - m_startFrame; }

private:
  qint64 m_uniqueId;

  int m_numMoves, m_openingMoveId, m_lastMoveId,
    m_startFrame, m_endFrame, m_stocks;

  qreal m_startPercent, m_endPercent;

  Direction m_killDirection;
  Dynamic m_openingDynamic;

  friend class SlippiReplay;
};

struct PlayerData : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("Returned by SlippiParser")

  // basic info
  Q_PROPERTY(int port MEMBER m_port)
  Q_PROPERTY(bool isWinner MEMBER m_isWinner)

  // names
  Q_PROPERTY(QString slippiName MEMBER m_slippiName)
  Q_PROPERTY(QString slippiCode MEMBER m_slippiCode)
  Q_PROPERTY(QString inGameTag MEMBER m_inGameTag)

  // character info
  Q_PROPERTY(int charId MEMBER m_charId)
  Q_PROPERTY(int charSkinId MEMBER m_charSkinId)

  // stats
  Q_PROPERTY(QVariantMap stats MEMBER m_stats)
  Q_PROPERTY(QVariantList punishes MEMBER m_punishes)

public:
  PlayerData(QObject *parent, const slip::Analysis &analysis,
             const slip::AnalysisPlayer &player, const slip::AnalysisPlayer &opponent);

private:
  QString m_slippiName, m_slippiCode, m_inGameTag;

  int m_charId, m_charSkinId, m_port;

  QVariantMap m_stats;
  QVariantList m_punishes;

  bool m_isWinner;

  friend class SlippiReplay;
};

class SlippiReplay : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  QML_UNCREATABLE("Returned by SlippiParser")

  Q_PROPERTY(qint64 uniqueId MEMBER m_uniqueId NOTIFY parsedFromAnalysis)
  Q_PROPERTY(QDateTime date MEMBER m_date NOTIFY parsedFromAnalysis)
  Q_PROPERTY(int stageId MEMBER m_stageId NOTIFY parsedFromAnalysis)
  Q_PROPERTY(int gameDuration MEMBER m_gameDuration NOTIFY parsedFromAnalysis)
  Q_PROPERTY(QString filePath MEMBER m_filePath NOTIFY parsedFromAnalysis)
  Q_PROPERTY(QString platform MEMBER m_platform NOTIFY parsedFromAnalysis)
  Q_PROPERTY(QString slippiVersion MEMBER m_slippiVersion NOTIFY parsedFromAnalysis)

  Q_PROPERTY(QString matchId MEMBER m_matchId NOTIFY parsedFromAnalysis)
  Q_PROPERTY(int gameNumber MEMBER m_gameNumber NOTIFY parsedFromAnalysis)
  Q_PROPERTY(int tiebreakerNumber MEMBER m_tiebreakerNumber NOTIFY parsedFromAnalysis)
  Q_PROPERTY(GameMode gameMode MEMBER m_gameMode NOTIFY parsedFromAnalysis)

  Q_PROPERTY(QVariantList players MEMBER m_players NOTIFY parsedFromAnalysis)
  Q_PROPERTY(int winningPlayerPort MEMBER m_winningPlayerPort NOTIFY parsedFromAnalysis)
  Q_PROPERTY(EndType gameEndType MEMBER m_endType NOTIFY parsedFromAnalysis)
  Q_PROPERTY(int lrasPlayerIndex MEMBER m_lrasPlayerIndex NOTIFY parsedFromAnalysis)

public:
  // same values as slip::EndType
  enum EndType {
      Unresolved = 0, Resolved = 3,
      Time = 1, Game = 2, NoContest = 7
  };
  Q_ENUM(EndType)

  // determined by replay matchId. unknown before Slippi 3.14
  enum GameMode {
      Unknown = 0, Ranked, Unranked, Direct
  };
  Q_ENUM(GameMode)

  explicit SlippiReplay(QObject *parent = nullptr);
  ~SlippiReplay();

  void fromAnalysis(const QString &filePath, slip::Analysis *analysis, const slip::SlippiReplay *replay);

signals:
  void parsedFromAnalysis();

  void parsedFromAna(qint64 uniqueId);

private:
  int m_stageId;
  int m_gameDuration;
  QDateTime m_date;
  qint64 m_uniqueId;
  QString m_filePath;
  QString m_platform; // Platform the game was played on (values include dolphin, console, and network)
  QString m_slippiVersion; // Slippi version as string e.g. "3.7.0"

  QVariantList m_players;
  int m_winningPlayerPort, m_lrasPlayerIndex;
  EndType m_endType;

  // added in v3.14.0:
  QString m_matchId; // Unique ID for the match. Can use it to group sessions / ranked matches
  int m_gameNumber, m_tiebreakerNumber; // # of game in a session, tiebreaker number for ranked
  GameMode m_gameMode;
};

#endif // SLIPPIREPLAY_H
