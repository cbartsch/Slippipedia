#include "slippiparser.h"

#include "parser.h"

#include <QtDebug>
#include <QQmlEngine>

SlippiParser::SlippiParser(QObject *parent) : QObject(parent)
{

}

SlippiReplay *SlippiParser::parseReplay(const QString &filePath)
{
  SlippiReplay *replay = new SlippiReplay();

  QQmlEngine::setObjectOwnership(replay, QQmlEngine::ObjectOwnership::JavaScriptOwnership);

  try {
    slip::Parser parser(0);
    parser.load(filePath.toLocal8Bit().data());
    replay->setAnalysis(parser.analyze());
  }
  catch(std::exception &ex) {
    qWarning() << "Could not parse SLP file" << ex.what();
  }

  return replay;
}
