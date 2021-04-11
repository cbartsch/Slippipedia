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

bool Utils::exploreToFile(const QString &filePath)
{
#ifdef Q_OS_WIN
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

#endif
  // TODO other OS implementations
  return false;
}

void Utils::startCommand(const QString &command, const QStringList &arguments)
{
  QProcess *p = new QProcess(this);

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
