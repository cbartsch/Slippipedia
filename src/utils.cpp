#include "utils.h"

#include <QQmlEngine>

#include <QApplication>
#include <QDir>
#include <QProcess>
#include <QtDebug>

#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>

#ifdef Q_OS_WIN
#include <shlobj.h>
#endif

Utils::Utils(const QString &dbFileName) : m_dbFileName(dbFileName)
{
}

#ifdef Q_OS_WIN
bool Utils::exploreToFile(const QString &filePath)
{
  // convert to 16bit string with native backslashes
  WCHAR filePathW[256];
  mbstowcs(filePathW, QDir::toNativeSeparators(filePath).toLocal8Bit(), filePath.length() + 1);

  // get native reference to file
  PIDLIST_ABSOLUTE pidl;
  auto ret = SHParseDisplayName(filePathW, nullptr, &pidl, 0, nullptr);

  if(ret < 0) {
    return false;
  }

  // show in explorer
  ret = SHOpenFolderAndSelectItems(pidl, 0, nullptr, 0);
  ILFree(pidl);

  return ret >= 0;
}
#endif

#ifdef Q_OS_UNIX
bool Utils::exploreToFile(const QString &filePath)
{
  // show the directory with xdg-open
  // TODO how to also pre-select the specified file?

  QFileInfo fileInfo(filePath);
  startCommand("xdg-open", {fileInfo.dir().path()});

  return true;
}
#endif

void Utils::startCommand(const QString &command, const QStringList &arguments,
                         const QJSValue &finishCallback, const QJSValue &logCallback)
{
  QSharedPointer<QProcess> p(new QProcess(this));

  connect(p.data(), &QProcess::readyReadStandardOutput, this, [p, logCallback]() {
    if(logCallback.isCallable()) {
      auto ret = logCallback.call({ QString(p->readAllStandardOutput()) });

      if(ret.isError()) {
        qWarning().noquote() << ret.toString();
      }
    }
    else {
      qDebug().noquote() << p->readAllStandardOutput();
    }
  });

  connect(p.data(), &QProcess::readyReadStandardError, this, [p, logCallback]() {
    if(logCallback.isCallable()) {
      auto ret = logCallback.call({ QString(p->readAllStandardError()) });

      if(ret.isError()) {
        qWarning().noquote() << ret.toString();
      }
    }
    else {
      qWarning().noquote() << p->readAllStandardError();
    }
  });

  connect(p.data(), &QProcess::finished, this, [p, finishCallback, command]() {
    if(finishCallback.isCallable()) {
      auto ret = finishCallback.call({ true, command });

      if(ret.isError()) {
        qWarning().noquote() << ret.toString();
      }
    }
    else {
      qDebug() << "Process" << command << "finished";
    }

    p->disconnect();
  });

  connect(p.data(), &QProcess::errorOccurred, this, [p, finishCallback, command]() {
    if(finishCallback.isCallable()) {
      auto ret = finishCallback.call({ false, command, p->errorString() });

      if(ret.isError()) {
        qWarning().nospace() << ret.toString();
      }
    }
    else {
      qWarning() << "Process" << command << "error:" << p->errorString();
    }

    // deleting the object crashes on mac and linux with Qt 6.4 and 6.8 - TODO check with later version
#if !defined(Q_OS_MAC) && !defined(Q_OS_UNIX)
    p->disconnect();
#endif
  });

  p->start(command, arguments);
}

QStringList Utils::listFiles(const QString &folder, const QStringList &nameFilters, bool recursive)
{
  if(folder.isNull() || folder.isEmpty()) {
    return {};
  }

  QDir dir(folder);

  if(!dir.exists()) {
    return {};
  }

  QStringList files;

  dir.setNameFilters(nameFilters);
  auto fileList = dir.entryInfoList(QDir::Filter::Files);

  for(auto &subFile : fileList) {
    files << subFile.filePath();
  }

  if(recursive) {
    for(auto &subDir : dir.entryInfoList(QDir::Filter::AllDirs | QDir::Filter::NoDotAndDotDot)) {
      files << listFiles(subDir.filePath(), nameFilters, recursive);
    }
  }

  return files;
}

bool Utils::mkdirs(const QString &path)
{
  QDir info(path);
  return info.exists() || info.mkpath(path);
}

bool Utils::moveFile(const QString &from, const QString &to)
{
  QFile file(from);
  return file.exists() && file.rename(to);
}

qint64 Utils::fileSize(const QString &path)
{
  QFile file(path);
  return file.exists() ? file.size() : -1;
}

void Utils::executeSql(const QString &sql)
{
  auto path = qmlEngine(this)->offlineStorageDatabaseFilePath("SlippiStatsDB");
  auto db = QSqlDatabase::database(QFileInfo(path).fileName());

  QSqlQuery query(db);
  query.exec(sql);
  auto error = query.lastError();
  if(error.isValid()) {
    qWarning().noquote() << "SQL query error:" << error.text();
  }
}

QString Utils::offlineStoragePath() const
{
  return m_dbFileName;
}

QString Utils::executablePath() const
{
  return qApp->applicationDirPath();
}
