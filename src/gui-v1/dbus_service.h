#ifndef DBUS_SERVICE_H
#define DBUS_SERVICE_H

#include <QObject>
#include <QString>

#include <veutil/qt/ve_qitem.hpp>

class DBusService : public QObject
{
	Q_OBJECT
	Q_DISABLE_COPY(DBusService)
	Q_PROPERTY(QString description READ getDescription NOTIFY descriptionChanged)
	Q_PROPERTY(QString name READ getName CONSTANT)
	Q_PROPERTY(DbusServiceType type READ getType CONSTANT)
	Q_ENUMS(DbusServiceType)
	Q_PROPERTY(bool connected READ getConnected NOTIFY connectedChanged)

public:
	enum DbusServiceType {
		DBUS_SERVICE_MULTI,
		DBUS_SERVICE_BATTERY,
		DBUS_SERVICE_SOLAR_CHARGER,
		DBUS_SERVICE_PV_INVERTER,
		DBUS_SERVICE_AC_CHARGER,
		DBUS_SERVICE_TANK,
		DBUS_SERVICE_GRIDMETER,
		DBUS_SERVICE_GENSET,
		DBUS_SERVICE_MOTOR_DRIVE,
		DBUS_SERVICE_INVERTER,
		DBUS_SERVICE_SYSTEM_CALC,
		DBUS_SERVICE_TEMPERATURE_SENSOR,
		DBUS_SERVICE_GENERATOR_STARTSTOP,
		DBUS_SERVICE_DIGITAL_INPUT,
		DBUS_SERVICE_PULSE_COUNTER,
		DBUS_SERVICE_UNSUPPORTED,
		DBUS_SERVICE_METEO,
		DBUS_SERVICE_VECAN,
		DBUS_SERVICE_EVCHARGER,
		DBUS_SERVICE_HUB4,
		DBUS_SERVICE_ACLOAD,
		DBUS_SERVICE_FUELCELL,
		DBUS_SERVICE_DCSOURCE,
		DBUS_SERVICE_ALTERNATOR,
		DBUS_SERVICE_DCLOAD,
		DBUS_SERVICE_DCSYSTEM,
		DBUS_SERVICE_MULTI_RS,
	};

	DBusService(VeQItem *serviceItem, DbusServiceType serviceType, QObject *parent = 0);
	~DBusService();

	QString getName() const
	{
		return mServiceItem->id();
	}

	QString getDescription() const {return mDescription;}

	static DBusService *createInstance(VeQItem *serviceItem);

	DbusServiceType getType() const {return mServiceType; }

	Q_INVOKABLE QString path(QString str) {
		return getName() + str;
	}
	inline VeQItem *item(const QString &id = QString()) {
		if (id.isEmpty())
			return mServiceItem;
		return mServiceItem->itemGetOrCreate(id);
	}

	bool getConnected() { return mServiceItem->getState() != VeQItem::Offline; }

signals:
	void descriptionChanged();
	void connectedChanged();
	void serviceDestroyed();
	void initialized();

private slots:
	virtual void updateDescription(QVariant);
	void updateDescription();

protected:
	void setDescription(const QString &description);
	virtual void checkInitDone();

private:
	DbusServiceType mServiceType;
	QString mDescription;
	VeQItem *mServiceItem;
	bool mInitDone;
};

class DBusTankService : public DBusService
{
	Q_OBJECT
	Q_DISABLE_COPY(DBusTankService)

public:
	DBusTankService(VeQItem *serviceItem, QObject *parent = 0);

	void updateDescription(QVariant);

private:
	static const std::vector<QString> &knownFluidTypes();
	static const QString fluidTypeName(unsigned int type);
};

Q_DECLARE_METATYPE(DBusService *)

#endif
