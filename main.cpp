#include <QtQml/QtQml>
#include <QApplication>
#include <FelgoApplication>

#include <QQmlApplicationEngine>

#include "slippiparser.h"
#include "slippireplay.h"

#include "utils.h"

#include <QtDebug>

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>

#ifdef FELGO_LIVE
#include <FelgoLiveClient>
#endif

// cannot configure DB pragmas in QML (error:
// so do it here:
QSqlDatabase setupDatabase(QQmlEngine& engine) {
  auto dbName = engine.offlineStorageDatabaseFilePath("SlippiStatsDB");
  QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", QFileInfo(dbName).fileName());
  db.setDatabaseName(dbName + ".sqlite");

  if(db.open()) {
    // use write-ahead-logging and normal sync mode for optimized performance
    // https://www.sqlite.org/wal.html
    // https://www.sqlite.org/pragma.html#pragma_synchronous
    db.exec("pragma journal_mode = wal");
    db.exec("pragma synchronous = off");
  }

  if(db.lastError().isValid()) {
    qWarning() << "Could not set up database:" << db.lastError();
  }
  else {
    qDebug() << "Successfully configured database."; // << dbName << QFileInfo(dbName).fileName();
  }

  return db;
}

int main(int argc, char *argv[])
{
  QApplication app(argc, argv);

  FelgoApplication felgo;

  // Use platform-specific fonts instead of Felgo's default font
  felgo.setPreservePlatformFonts(true);

  QQmlApplicationEngine engine;
  felgo.initialize(&engine);

  // the database connection exists for the lifetime of the app:
  QSqlDatabase db(setupDatabase(engine));

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

  Utils::registerQml(QML_MODULE_NAME);

  qmlRegisterType<SlippiParser>(QML_MODULE_NAME, 1, 0, "SlippiParser");
  qmlRegisterUncreatableType<SlippiReplay>(QML_MODULE_NAME, 1, 0, "SlippiReplay", "Returned by SlippiParser");
  qmlRegisterUncreatableType<PlayerData>(QML_MODULE_NAME, 1, 0, "PlayerData", "Returned by SlippiParser");
  qmlRegisterUncreatableType<PunishData>(QML_MODULE_NAME, 1, 0, "PunishData", "Returned by SlippiParser");

  // bring back Felgo 3 / Qt 5 default font (Ms Shell Dlg 2 which defaults to Tahoma)
  QGuiApplication::setFont(QFont("Tahoma"));

#ifdef FELGO_LIVE
  FelgoLiveClient client (&engine);

  // load QML module:
  engine.addImportPath(client.cacheDirectory() + "/Slippipedia/qml");
#else
  engine.load(QUrl(felgo.mainQmlFileName()));
#endif

  return app.exec();
}
