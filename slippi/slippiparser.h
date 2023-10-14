#ifndef SLIPPIPARSER_H
#define SLIPPIPARSER_H

#include <QObject>
#include <QQmlEngine>
#include <QThread>

#include "slippireplay.h"

class SlippiParser : public QObject
{
  Q_OBJECT
  QML_ELEMENT

public:
  explicit SlippiParser(QObject *parent = nullptr);
  ~SlippiParser();

public slots:
  void parseReplay(const QString &filePath);
  void cancelAll();

signals:
  void replayParsed(const QString &filePath, SlippiReplay *replay);
  void replayFailedToParse(const QString &filePath, const QString &errorMessage);

private:
  void initPrivate();
  void destroyPrivate();

  QThread *thread;

  struct SlippiParserPrivate *d;
  friend struct SlippiParserPrivate;
};

#endif // SLIPPIPARSER_H
