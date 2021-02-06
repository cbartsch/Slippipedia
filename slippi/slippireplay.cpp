#include "slippireplay.h"

#include <QtDebug>

SlippiReplay::SlippiReplay(QObject *parent) : QObject(parent)
{

}

SlippiReplay::~SlippiReplay() {
  qDebug() << "Replay destruction";

  if(m_analysis) {
    delete m_analysis;
    m_analysis = nullptr;
  }
}

void SlippiReplay::setAnalysis(slip::Analysis *analysis) {
  m_analysis = analysis;
}

QString SlippiReplay::stageName() const
{
  return m_analysis ? QString::fromStdString(m_analysis->stage_name) : "";
}
