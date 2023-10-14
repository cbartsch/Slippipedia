#include <QtQml/QtQml>
#include <QApplication>
#include <FelgoApplication>

#include <QGuiApplication>
#include <QFont>

#include <QQmlApplicationEngine>

#include "utils.h"

#include <QtDebug>

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>

#ifdef FELGO_LIVE
#include <FelgoLiveClient>
#endif

// use this to create separate test DBs
const QString DB_TEST_ID = "";

// cannot configure DB pragmas in QML (error:
// so do it here:
QSqlDatabase setupDatabase(QQmlEngine& engine) {
  auto dbName = engine.offlineStorageDatabaseFilePath("SlippiStatsDB");
  auto dbFileName = dbName + ".sqlite";
  auto dbConfigName = dbName + ".ini";

  if(!DB_TEST_ID.isEmpty()) {
    dbFileName = dbName + "_test" + DB_TEST_ID + ".sqlite";
  }

#ifdef Q_OS_WINDOWS
  // Felgo 3 / Qt 5 had the database in AppData/Local, Felgo 4 / Qt 6 has it in AppData/Roaming
  // -> check if local exists from an older version, if yes, use that one:
  QFileInfo dbFile(dbFileName);
  QFileInfo dbConfigFile(dbConfigName);
  QString localName(dbName.replace("Roaming", "Local"));

  if(!dbFile.exists()) {
    // use old DB file
    QFileInfo localFile(localName + ".sqlite");
    if(localFile.exists()) {
      dbFileName = localFile.absoluteFilePath();
    }
  }
  if(!dbConfigFile.exists()) {
    // copy config from old to new location (cannot override config file location)
    QFile localConfig(localName + ".ini");
    if(localConfig.exists()) {
      localConfig.copy(dbConfigName);
    }
  }
#endif

  QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", QFileInfo(dbName).fileName());
  db.setDatabaseName(dbFileName);

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
    qDebug().nospace().noquote() << "Successfully configured database. Name: " << QFileInfo(dbName).fileName() << ", full path:" << dbFileName;
  }

  return db;
}

static QtMessageHandler origMessageHandler;
static QFileInfo logFileInfo;

void logMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
  static QMutex mutex;
  QMutexLocker lock(&mutex);

  // skip useless logs from Qt bugs
  if(msg.startsWith("qrc:/qt-project.org/imports/QtQuick/Controls/macOS/") ||
      msg.contains("MeleeData is not defined")) {
    return;
  }

  QFile logFile(logFileInfo.absoluteFilePath());

  if (logFile.open(QIODevice::Append | QIODevice::Text)) {
    logFile.write(qFormatLogMessage(type, context, msg).toUtf8() + '\n');
    logFile.flush();
  }

  origMessageHandler(type, context, msg);
}

int main(int argc, char *argv[])
{
  QApplication app(argc, argv);

  FelgoApplication felgo;

  // Use platform-specific fonts instead of Felgo's default font
  felgo.setPreservePlatformFonts(true);

  QQmlApplicationEngine engine;
  felgo.initialize(&engine);

  // find applications in user path for Utils::startCommand()
#ifdef Q_OS_MAC
  const char *userPath = "/usr/local/bin";
  QString path = qgetenv("PATH");
  if(!path.contains(userPath)) {
    path += QString(":") + userPath;
    qputenv("PATH", path.toUtf8());
  }
#endif

  QFileInfo logFileDir(qApp->applicationFilePath());
#ifdef Q_OS_MAC
  // on Mac the executable is at Slippipedia.app/Contents/MacOS/Slippipedia -> remove those paths for the log file:
  logFileDir = QFileInfo(logFileDir.dir(), "../../../..");
#endif

  logFileInfo = QFileInfo(logFileDir.dir(), "log.txt");
  qDebug() << "Logging to external file:" << logFileInfo.absoluteFilePath();

  origMessageHandler = qInstallMessageHandler(logMessageHandler);

  qDebug().noquote() << "\n\nSlippipedia started at" << QDateTime::currentDateTime().toString(Qt::DateFormat::ISODate);
  qDebug() << "------------------------------------------\n";

  // the database connection exists for the lifetime of the app:
  QSqlDatabase db(setupDatabase(engine));

  // Set an optional license key from project file
  // This does not work if using Felgo Live, only for Felgo Cloud Builds and local builds
  felgo.setLicenseKey(PRODUCT_LICENSE_KEY);

  felgo.setMainQmlFileName(QStringLiteral("qml/Main.qml"));

  Utils utils(db.databaseName());
  qmlRegisterSingletonInstance(QML_MODULE_NAME, 1, 0, "Utils", &utils);

  // bring back Felgo 3 / Qt 5 default font (Ms Shell Dlg 2 which defaults to Tahoma)
  QGuiApplication::setFont(QFont("Tahoma"));

  // import app's QML module from root resources:
  engine.addImportPath("qrc:/");

#ifdef FELGO_LIVE
  FelgoLiveClient client (&engine);
#else
  engine.load(felgo.mainQmlFileName());
#endif

  return app.exec();
}
