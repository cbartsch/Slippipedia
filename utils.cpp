#include "utils.h"

#include <QQmlEngine>

#include <QDir>
#include <QProcess>
#include <QtDebug>


Utils::Utils()
{

}

void Utils::registerQml() {
  qmlRegisterSingletonType<Utils>("Slippi", 1, 0, "Utils", [](QQmlEngine*, QJSEngine*) -> QObject* {
    return new Utils();
  });
}

bool Utils::exploreToFile(const QString &filePath)
{
#ifdef Q_OS_WIN
  QString mod = filePath;

  QString arg = "/select," + mod.replace("/", "\\");

  QProcess::execute("explorer.exe", {arg});

  return true;
#endif
  return false;
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
