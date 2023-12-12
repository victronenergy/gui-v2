#ifndef CMMANAGER_H
#define CMMANAGER_H

#include <QObject>
#include <qqmlintegration.h>
#include "cmmananger_interface.h"
#include "cmtechnology.h"
#include "cmservice.h"
#include "cmagent.h"

class QQmlEngine;
class QJSEngine;

class CmManager : public QObject
{
	Q_OBJECT
	QML_NAMED_ELEMENT(Connman)
	QML_SINGLETON
	Q_PROPERTY(QString state READ getState NOTIFY stateChanged)
	Q_PROPERTY(QStringList technologyList READ getTechnologyList NOTIFY technologyListChanged)
	Q_PROPERTY(QStringList serviceList READ getServiceList NOTIFY serviceListChanged)

public:
	static CmManager* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);

	Q_INVOKABLE CmTechnology* getTechnology(const QString &type) const;
	Q_INVOKABLE QStringList getServiceList(const QString &type) const;
	Q_INVOKABLE CmService* getService(const QString &path) const;
	Q_INVOKABLE CmAgent* registerAgent(const QString &path);
	Q_INVOKABLE void unRegisterAgent(const QString &path);

	const QString getState() const { return mProperties[State].toString(); }
	const QStringList getTechnologyList() const;
	const QStringList getServiceList() const;
	const QString getFavoriteService() const;

public slots:

private slots:
	void connmanRegistered(const QString& serviceName);
	void connmanUnregistered(const QString& serviceName);
	void propertyChanged(const QString& name, const QDBusVariant& value);
	void technologyAdded(const QDBusObjectPath &objectPath, const QVariantMap &properties);
	void technologyRemoved(const QDBusObjectPath &objectPath);
	void servicesChanged(const ConnmanObjectList &changed, const QList<QDBusObjectPath> &removed);
	void dbusReply(QDBusPendingCallWatcher *call);

signals:
	void stateChanged();
	void technologyListChanged();
	void serviceListChanged();
	void serviceChanged(const QString &path, const QVariantMap &properties);
	void serviceAdded(const QString &path);
	void serviceRemoved(const QString &path);

private:
	CmManager(QObject *parent);
	~CmManager();
	void addTechnology(const QString &path, const QVariantMap &properties);
	void addService(const QString &objectPath, const QVariantMap &properties);
	void connect();
	void connectTechnologies();
	void connectServices();
	void disconnect();
	void disconnectTechnologies();
	void disconnectServices();
	bool getProperties();
	bool getTechnologies();
	bool getServices();

	static const QString State;
	static const QString OfflineMode;
	static const QString SessionMode;

	bool connected;
	CmManangerInterface mManager;
	QDBusServiceWatcher mWatcher;

	CmAgent mAgent;
	QVariantMap mProperties;
	QMap<QString, CmTechnology *> mTechnologies;
	QMap<QString, CmService *> mServices;
	QStringList mServicesOrderList;
};

#endif // CMMANAGER_H
