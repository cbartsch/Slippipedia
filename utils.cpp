#include "utils.h"

#include <QQmlEngine>

#include <QDir>
#include <QProcess>
#include <QtDebug>

#ifdef Q_OS_WIN
#include <shlobj.h>
#endif

Utils::Utils()
{

}

void Utils::registerQml(const char *qmlModuleName) {
  qmlRegisterSingletonType<Utils>(qmlModuleName, 1, 0, "Utils", [](QQmlEngine*, QJSEngine*) -> QObject* {
    return new Utils();
  });
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

void Utils::startCommand(const QString &command, const QStringList &arguments,
                         const QJSValue &finishCallback, const QJSValue &logCallback)
{
  QProcess *p = new QProcess(this);

  p->start(command, arguments);

  connect(p, &QProcess::readyReadStandardOutput, this, [p, logCallback]() {
    if(logCallback.isCallable()) {
      logCallback.call({ QString(p->readAllStandardError()) });
    }
    else {
      qDebug().noquote() << p->readAllStandardError();
    }
  });

  connect(p, &QProcess::readyReadStandardError, this, [p, logCallback]() {
    if(logCallback.isCallable()) {
      logCallback.call({ QString(p->readAllStandardError()) });
    }
    else {
      qWarning().noquote() << p->readAllStandardError();
    }
  });

  connect(p, &QProcess::finished, this, [p, finishCallback, command]() {
    qDebug() << "Process" << command << "finished";

    if(finishCallback.isCallable()) {
      finishCallback.call({ command });
    }

    delete p;
  });

  connect(p, &QProcess::errorOccurred, this, [p, finishCallback, command]() {
    qWarning() << "Process" << command << "error:" << p->errorString();

//    if(finishCallback.isCallable()) {
//      finishCallback.call({ command });
//    }

//    delete p;
  });
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

  for(auto subFile : fileList) {
    files << subFile.filePath();
  }

  if(recursive) {
    for(auto subDir : dir.entryInfoList(QDir::Filter::AllDirs | QDir::Filter::NoDotAndDotDot)) {
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
