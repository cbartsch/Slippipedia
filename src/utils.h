#ifndef UTILS_H
#define UTILS_H

#include <QObject>
#include <QQmlEngine>
#include <QProcess>
#include <QJSValue>

class Utils : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

  Q_PROPERTY(QString offlineStoragePath READ offlineStoragePath CONSTANT)
  Q_PROPERTY(QString executablePath READ executablePath CONSTANT)

public:
  Utils(const QString &dbFileName);

  Q_INVOKABLE bool exploreToFile(const QString &filePath);

  Q_INVOKABLE void startCommand(const QString &command, const QStringList &arguments,
                                const QJSValue &finishCallback = QJSValue {},
                                const QJSValue &logCallback = QJSValue {});

  Q_INVOKABLE QStringList listFiles(const QString &folder, const QStringList &nameFilters, bool recursive);

  Q_INVOKABLE bool mkdirs(const QString &path);
  Q_INVOKABLE bool moveFile(const QString &from, const QString &to);
  Q_INVOKABLE qint64 fileSize(const QString &path);

  // execute SQL on the local DB without transaction (not possible in regular QML API)
  Q_INVOKABLE void executeSql(const QString &sql);

  QString offlineStoragePath() const;
  QString executablePath() const;

private:
  QString m_dbFileName;
};

#endif // UTILS_H
