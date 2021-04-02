#ifndef UTILS_H
#define UTILS_H

#include <QObject>
#include <QProcess>

class Utils : public QObject
{
  Q_OBJECT

  Utils();
public:
  static void registerQml(const char *qmlModuleName);

  Q_INVOKABLE bool exploreToFile(const QString &filePath);

  Q_INVOKABLE void startCommand(const QString &command, const QStringList &arguments);

  Q_INVOKABLE QStringList listFiles(const QString &folder, const QStringList &nameFilters, bool recursive);
};

#endif // UTILS_H
