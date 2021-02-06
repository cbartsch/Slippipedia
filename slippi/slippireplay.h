#ifndef SLIPPIREPLAY_H
#define SLIPPIREPLAY_H

#include <QObject>

#include "analysis.h"

class SlippiReplay : public QObject
{
  Q_OBJECT
  Q_PROPERTY(QString stageName READ stageName)
public:
  explicit SlippiReplay(QObject *parent = nullptr);
  ~SlippiReplay();

  void setAnalysis(slip::Analysis *analysis);

  QString stageName() const;

signals:

private:
  slip::Analysis *m_analysis = nullptr;
  QString m_stageName;
};

#endif // SLIPPIREPLAY_H
