#ifndef _VELIB_QT_VE_QITEMS_DBUS_HPP_
#define _VELIB_QT_VE_QITEMS_DBUS_HPP_

#include <QHash>
#include <QtDBus>
#include <QDBusServiceWatcher>
#include <velib/qt/ve_qitem.hpp>

class VBusItemProxy;
class VeQItemDbusProducer;
class VeDbusServicePrivate;

typedef QMap<QString,QString> StringMap;
typedef QMap<QString, QVariantMap> ItemMap;

Q_DECLARE_METATYPE(ItemMap)

// Implementation of a VeQItem over the dbus
class VeQItemDbus : public VeQItem, protected QDBusContext
{
	Q_OBJECT

public:
	VeQItemDbus(VeQItemDbusProducer *producer);
	bool introspect();
	virtual QVariant getValue() { return getValue(false); }
	virtual QString getText() { return getText(false); }
	virtual QVariant itemProperty(const char *name) { return itemProperty(name, false); }
	virtual int setValue(QVariant const &value);
	VeQItemDbusProducer *producer();
	void serviceRegistrationChanged(bool registered);
	void bulkInitValueDone();
	void bulkInitTextDone();
	virtual void produceValue(QVariant variant, State state = Synchronized, bool forceChanged = false);
	virtual void produceText(QString text, State state = Synchronized);

protected:
	virtual void setParent(QObject *parent);
	QString dbusPath();
	QString dbusServiceName();
	bool dbusIsServiceRegistered();
	QDBusConnection &dbusConnection();

private slots:
	void valueObtained(QDBusPendingCallWatcher *call);
	void textObtained(QDBusPendingCallWatcher *call);
#ifdef QT_XML_LIB
	void introspectObtained(QDBusPendingCallWatcher *call);
#endif
	void onPropertiesChanged(const QVariantMap &changes);
	void setValueDone(QDBusPendingCallWatcher *call);

	void maxObtained(QDBusPendingCallWatcher *call);
	void minObtained(QDBusPendingCallWatcher *call);
	void defaultObtained(QDBusPendingCallWatcher *call);

private:
	QVariant getValue(bool force);
	QString getText(bool force);
	QVariant itemProperty(const char *name, bool force);
	QDBusPendingCallWatcher *asyncCall(const QString &method, char const *returnMethod);

	void propertyObtained(const char *name, QDBusPendingCallWatcher *call);
	void demarshallVariantForQml(QVariant &variant, QString &signature);

	VeDbusServicePrivate *mDbusService;
	QString mSignature;
	QVariant mPendingSetValue;

	bool mRequestValueWhenOnline;
	bool mRequestTextWhenOnline;
	bool mRequestDefaultWhenOnline;
	bool mRequestMaxWhenOnline;
	bool mRequestMinWhenOnline;

	friend class VeDbusServicePrivate;
	friend class VeQItemDbusSettings;
};

class VeQItemDbusProducer : public VeQItemProducer, protected QDBusContext
{
	Q_OBJECT

public:
	VeQItemDbusProducer(VeQItem *root, QString id, bool findVictronServices = true,
						bool bulkInitOfNewService = true, QObject *parent = 0);

	virtual bool open(const QString &address = "session", const QString &qtDbusName = "qtdbus");
	virtual bool open(const QDBusConnection &dbusConnection);

	virtual VeQItem *createItem();
	QDBusConnection &dbusConnection() { return mDbus; }
	VeDbusServicePrivate *dbusServiceGetOrCreate(const QString serviceName, QString owner = QString());

	bool getAutoCreateItems() const { return mAutoCreateItems; }
	void setAutoCreateItems(bool v);

	bool getFindVictronServices() { return mFindVictronServices; }

private slots:
	void onServiceOwnerChanged(const QString &serviceName, const QString &oldOwner, const QString &newOwner);

public:
	bool getBulkInit() { return mBulkInitOfNewService; }

private:
	QHash<QString, VeDbusServicePrivate *> mServiceWatchers;

private:
	QDBusConnection mDbus;
	bool mFindVictronServices;
	bool mBulkInitOfNewService;
	bool mAutoCreateItems;
};


class VeDbusServicePrivate : QObject, protected QDBusContext
{
	Q_OBJECT

public:
	VeDbusServicePrivate(QString owner = QString(), QObject *parent = 0);
	~VeDbusServicePrivate();

	void attachRootItem(VeQItemDbus *serviceRoot);
	QString serviceName() { return mServiceRoot->id(); }
	QString owner() { return mOwner; }
	VeQItemDbusProducer *producer() { return mServiceRoot->producer(); }
	QDBusConnection &dbusConnection() { return producer()->dbusConnection(); }

	bool isRegistered() { return !mOwner.isEmpty(); }
	bool isBulkInitValueActive() { return mBulkInitValueActive; }
	void bulkInitValueDone(bool success);

	bool isBulkInitTextActive() { return mBulkInitTextActive; }
	void bulkInitTextDone(bool success);

protected:
	QString dbusPath(VeQItemDbus *item);

protected slots:
	void onPropertiesChanged(const QVariantMap &changes) { handleItemProperties(message().path(), changes); }
	void onItemsChanged(const ItemMap &items);
	void ownerChanged(const QString &oldOwner, const QString &newOwner);

private:
	void serviceRegistrationChanged(bool registered);
	void handleItemProperties(QString const &path, const QVariantMap &changes);

	QString mOwner;
	VeQItemDbus *mServiceRoot;
	bool mItemsChangedConnected;
	bool mBulkInitValueActive;
	bool mBulkInitTextActive;

	friend class VeQItemDbus;
	friend class VeQItemDbusProducer;
};

typedef QList<QVariantMap> QVariantMapList;
Q_DECLARE_METATYPE(QVariantMapList)

class VeQItemDbusSettings : public VeQItemSettings
{
public:
	VeQItemDbusSettings(VeQItem *parent, QString id);

	virtual bool addSettings(VeQItemSettingsInfo const &info);

private:
	QDBusMessage sendAddSettings(VeQItemSettingsInfo const &settingsInfo);
	bool handleAddSettingsReply(QDBusMessage &reply);

	QDBusConnection &mConn;
};

#endif
