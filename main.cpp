#include <QtQml/QtQml>
#include <QApplication>
#include <FelgoApplication>

#include <QQmlApplicationEngine>

#include "slippiparser.h"
#include "slippireplay.h"

#include "utils.h"

#include <QtDebug>

#ifdef FELGO_LIVE
#include <FelgoLiveClient>
#endif

int main(int argc, char *argv[])
{

  QApplication app(argc, argv);

  FelgoApplication felgo;

  // Use platform-specific fonts instead of Felgo's default font
  felgo.setPreservePlatformFonts(true);

  QQmlApplicationEngine engine;
  felgo.initialize(&engine);

  // Set an optional license key from project file
  // This does not work if using Felgo Live, only for Felgo Cloud Builds and local builds
  felgo.setLicenseKey(PRODUCT_LICENSE_KEY);

  // use this during development
  // for PUBLISHING, use the entry point below
#ifdef USE_RESOURCES
  felgo.setMainQmlFileName(QStringLiteral("qrc:/qml/Main.qml"));
#else
  felgo.setMainQmlFileName(QStringLiteral("qml/Main.qml"));
#endif

  Utils::registerQml();

  qmlRegisterType<SlippiParser>("Slippi", 1, 0, "SlippiParser");
  qmlRegisterUncreatableType<SlippiReplay>("Slippi", 1, 0, "SlippiReplay", "Returned by SlippiParser");
  qmlRegisterUncreatableType<PlayerData>("Slippi", 1, 0, "PlayerData", "Returned by SlippiParser");

#ifdef FELGO_LIVE
  FelgoLiveClient client (&engine);
#else
  engine.load(QUrl(felgo.mainQmlFileName()));
#endif

  return app.exec();
}
