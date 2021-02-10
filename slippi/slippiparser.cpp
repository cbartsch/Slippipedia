#include "slippiparser.h"

#include "parser.h"

#include <QtDebug>
#include <QQmlEngine>
#include <QtConcurrent/QtConcurrent>

struct SlippiParserPrivate : public QObject {
  Q_OBJECT

public:
  SlippiParserPrivate(SlippiParser *item) : m_item(item) {
  }

public slots:
  void doParseReplay(const QString &filePath);

private:
  SlippiParser *m_item;
};

#include "slippiparser.moc"

SlippiParser::SlippiParser(QObject *parent) : QObject(parent), thread(new QThread(this))
{
  initPrivate();
}

SlippiParser::~SlippiParser()
{
  destroyPrivate();
}

void SlippiParser::parseReplay(const QString &filePath)
{
  QMetaObject::invokeMethod(d, "doParseReplay", Q_ARG(QString, filePath));
}

void SlippiParser::cancelAll()
{
  // cancel all invocations by deleting private object and thread, then recreating
  destroyPrivate();
  initPrivate();
}

void SlippiParser::initPrivate()
{
  thread->start();

  d = new SlippiParserPrivate(this);
  d->moveToThread(thread);
}

void SlippiParser::destroyPrivate()
{
  delete d;
  d = nullptr;

  thread->quit();
  thread->wait();
}


void SlippiParserPrivate::doParseReplay(const QString &filePath)
{
  SlippiReplay *replay = new SlippiReplay();

  QQmlEngine::setObjectOwnership(replay, QQmlEngine::ObjectOwnership::JavaScriptOwnership);

  QString errorMessage;
  try {
    slip::Parser parser(0);
    parser.load(filePath.toLocal8Bit().data());
    QScopedPointer<slip::Analysis> analysis(parser.analyze());

    replay->fromAnalysis(filePath, analysis.data());

    emit m_item->replayParsed(filePath, replay);
  }
  catch(std::exception &ex) {
    // qWarning() << "Could not parse SLP file" << filePath << ex.what();

    emit m_item->replayFailedToParse(filePath, ex.what());
  }


}
