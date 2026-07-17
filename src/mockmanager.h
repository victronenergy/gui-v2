/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_MOCKMANAGER_H
#define VICTRON_GUIV2_MOCKMANAGER_H

#include <QHash>
#include <QQmlEngine>
#include <QStringList>
#if QT_CONFIG(thread)
#include <QThread>
#endif

namespace Victron {
namespace VenusOS {

class MockTimerWorker;
class MockValueApplier;
class VeQItemMockProducer;

// Animator inputs are cached so the next tick continues from external writes.
// Calculator sources also schedule a consumption/phase-sum flush.
enum class MockWatchRole {
	AnimatorInput,
	CalculatorSource
};

class MockManager : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON
	Q_PROPERTY(bool timersActive READ timersActive WRITE setTimersActive NOTIFY timersActiveChanged FINAL)

public:
	bool timersActive() const;
	void setTimersActive(bool active);

	bool loadConfiguration(const QString &fileName);
	QString configurationFileName() const;

	Q_INVOKABLE void setValue(const QString &uid, const QVariant &value);
	Q_INVOKABLE QVariant value(const QString &uid) const;
	Q_INVOKABLE void setProperty(const QString &uid, const QString &name, const QVariant &value);
	Q_INVOKABLE void removeValue(const QString &uid);
	Q_INVOKABLE void removeServices(const QString &serviceType);
	Q_INVOKABLE void dumpValues();

	// Access the worker thread (for animator registration)
	MockTimerWorker *timerWorker() const;
	MockValueApplier *valueApplier() const;

	// Forward producer changes for these uids into the worker cache. JSON load
	// happens before anything registers, so unwatched setValue calls stay local.
	void watchUids(const QStringList &uids, MockWatchRole role);
	void unwatchUids(const QStringList &uids, MockWatchRole role);
	void setSuppressWorkerSync(bool suppress);

	static MockManager* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);

Q_SIGNALS:
	void timersActiveChanged();
	void addDummyNotification(bool isAlarm);

private:
	explicit MockManager(QObject *parent = nullptr);
	~MockManager() override;

	void initWorkerThread();

	bool setValuesFromJson(const QString &fileName);
	void setServiceValues(const QJsonObject &object);
	void setPropertyValues(const QString &path, const QJsonObject &properties);
	VeQItemMockProducer *producer() const;
	void onWatchedValueChanged(const QString &uid, const QVariant &value);

	struct UidWatch {
		int animatorRefs = 0;
		int calculatorRefs = 0;
		QMetaObject::Connection connection;
	};

	QString m_confFileName;
	bool m_timersActive = false;
	int m_suppressWorkerSync = 0;
	QHash<QString, UidWatch> m_watches;
#if QT_CONFIG(thread)
	QThread *m_workerThread = nullptr;
#endif
	MockTimerWorker *m_timerWorker = nullptr;
	MockValueApplier *m_valueApplier = nullptr;
};

}
}

#endif // VICTRON_GUIV2_MOCKMANAGER_H
