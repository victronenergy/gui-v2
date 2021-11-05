#ifndef _VELIB_QT_V_BUSITEMS_H_
#define _VELIB_QT_V_BUSITEMS_H_

#include <QObject>
#include <QString>
#include <QDBusConnection>

class VBusItems : public QObject {
	Q_OBJECT

public:
	VBusItems(QObject* parent = 0);

	static QDBusConnection& getConnection();
	static QDBusConnection getConnection(const QString &name);

	static void setConnectionType(QDBusConnection::BusType type);
	static void setDBusAddress(const QString &address);
	static const QString getDBusAddress();

signals:

public slots:

private:
	static QDBusConnection::BusType mBusType;
	static QString mDBusAddress;
};

#endif

