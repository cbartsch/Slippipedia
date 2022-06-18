#ifndef UTILS_H
#define UTILS_H

#include <QObject>
#include <QProcess>
#include <QJSValue>

class Utils : public QObject
{
  Q_OBJECT

  Utils();
public:
  static void registerQml(const char *qmlModuleName);

  Q_INVOKABLE bool exploreToFile(const QString &filePath);

  Q_INVOKABLE void startCommand(const QString &command, const QStringList &arguments,
                                const QJSValue &finishCallback = QJSValue {},
                                const QJSValue &logCallback = QJSValue {});

  Q_INVOKABLE QStringList listFiles(const QString &folder, const QStringList &nameFilters, bool recursive);

  Q_INVOKABLE bool mkdirs(const QString &path);
};

#endif // UTILS_H
