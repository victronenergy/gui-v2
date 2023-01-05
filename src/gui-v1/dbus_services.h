#ifndef DBUS_SERVICES_H
#define DBUS_SERVICES_H

#include <QObject>

#include <veutil/qt/ve_qitem.hpp>
#include <veutil/qt/ve_qitem_table_model.hpp>

class DBusService;

class DBusServices : public VeQItemTableModel
{
	Q_OBJECT
	Q_PROPERTY(int count READ getCount)

public:
	DBusServices(VeQItem *services, QObject *parent = 0) :
		VeQItemTableModel(VeQItemTableModel::AddNonLeaves, parent),
		mQItemServices(services)
	{
	}

	void initialScan();
	int getCount() { return static_cast<int>(mServices.count()); }
	Q_INVOKABLE DBusService *at(int i) { return mServices.values()[i]; }
	Q_INVOKABLE DBusService *get(QString const &name);

signals:
	// note: found is called once, while connected / disconnected can
	// occur multiple times. The service is only announced after the
	// basic properties, like its description are obtained.
	void dbusServiceFound(DBusService *service);

	void dbusServiceConnected(DBusService *service);
	void dbusServiceDisconnected(DBusService *service);

private slots:
	void onServiceAdded(VeQItem *serviceItem);
	void onServiceDestoyed();
	void onConnectedChanged(DBusService *service);
	void onServiceInitialized();

private:
	QHash<QString, DBusService *> mServices;
	VeQItem *mQItemServices;
};

#endif
