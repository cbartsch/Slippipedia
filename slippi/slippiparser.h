#ifndef SLIPPIPARSER_H
#define SLIPPIPARSER_H

#include <QObject>

#include "slippireplay.h"

class SlippiParser : public QObject
{
  Q_OBJECT

public:
  explicit SlippiParser(QObject *parent = nullptr);

  Q_INVOKABLE SlippiReplay *parseReplay(const QString &filePath);
};

#endif // SLIPPIPARSER_H
