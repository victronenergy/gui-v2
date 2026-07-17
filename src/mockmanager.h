/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_MOCKMANAGER_H
#define VICTRON_GUIV2_MOCKMANAGER_H

#include <QHash>
#include <QQmlEngine>
#include <QStringList>
#include <QVariantList>

class QThread;

namespace Victron {
namespace VenusOS {

class MockTimerWorker;
class MockValueApplier;
class VeQItemMockProducer;

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
	// Inject a worker batch into the paced applier. Used by tst_mockworker.
	Q_INVOKABLE void applyWorkerUpdatesForTest(const QVariantList &updates);
	// Register a stepper with no QML item. Used by tst_mockworker.
	Q_INVOKABLE void registerStepperForTest(const QString &uid, qreal interval);
	Q_INVOKABLE void queueTimerUpdateForTest(const QString &uid, const QVariant &value);
	Q_INVOKABLE void tickAnimatorsForTest();
	// Wait until queued GUI writes have been stored by the worker.
	Q_INVOKABLE void finishExternalWritesForTest();
	// Apply values still queued for the GUI. The next test must not wait behind them.
	Q_INVOKABLE void finishAppliesForTest();

	// Access the timer engine (for animator registration)
	MockTimerWorker *timerWorker() const;
	MockValueApplier *valueApplier() const;

	// Remember calculator inputs by uid. A write to one of them reruns the calculation.
	// This does not create a missing item.
	void watchCalculatorSources(const QStringList &uids);
	void unwatchCalculatorSources(const QStringList &uids);

	static MockManager* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);

	~MockManager() override;

Q_SIGNALS:
	void timersActiveChanged();
	void addDummyNotification(bool isAlarm);

private:
	explicit MockManager(QObject *parent = nullptr);

	void initWorker();

	bool setValuesFromJson(const QString &fileName);
	void setServiceValues(const QJsonObject &object);
	void setPropertyValues(const QString &path, const QJsonObject &properties);
	VeQItemMockProducer *producer() const;
	void onExternalWrite(const QString &uid);

	QString m_confFileName;
	bool m_timersActive = false;
	// JSON load writes the producer only. Registration copies those values later.
	int m_suppressExternalSync = 0;
	QHash<QString, int> m_calculatorSources;
	QThread *m_workerThread = nullptr;
	MockTimerWorker *m_timerWorker = nullptr;
	MockValueApplier *m_valueApplier = nullptr;
};

}
}

#endif // VICTRON_GUIV2_MOCKMANAGER_H
