#include "utils.h"

#include <QQmlEngine>

#include <QDir>
#include <QtDebug>

Utils::Utils()
{

}

void Utils::registerQml() {
  qmlRegisterSingletonType<Utils>("Slippi", 1, 0, "Utils", [](QQmlEngine*, QJSEngine*) -> QObject* {
    return new Utils();
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
