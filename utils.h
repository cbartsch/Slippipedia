#ifndef UTILS_H
#define UTILS_H

#include <QObject>

class Utils : public QObject
{
  Q_OBJECT

  Utils();
public:
  static void registerQml();


  Q_INVOKABLE QStringList listFiles(const QString &folder, const QStringList &nameFilters, bool recursive);
};

#endif // UTILS_H
