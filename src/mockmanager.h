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
	// Inject a timer batch into the paced applier. Used by tst_mockworker.
	Q_INVOKABLE void applyWorkerUpdatesForTest(const QVariantList &updates);
	// Add an update to the timer batch that has not been flushed yet. Used by tst_mockworker.
	Q_INVOKABLE void queueTimerUpdateForTest(const QString &uid, const QVariant &value);
	// Run one tick of every registered animator, without flushing it. Used by tst_mockworker.
	Q_INVOKABLE void tickAnimatorsForTest();
	// Register a stepper with no QML item. Used by tst_mockworker.
	Q_INVOKABLE void registerStepperForTest(const QString &uid, qreal interval);

	// Access the timer worker (for animator registration)
	MockTimerWorker *timerWorker() const;
	MockValueApplier *valueApplier() const;

	// A write to one of these uids from outside the timers reruns the
	// consumption and phase-sum calculators.
	void watchCalculatorSources(const QStringList &uids);
	void unwatchCalculatorSources(const QStringList &uids);

	static MockManager* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);

Q_SIGNALS:
	void timersActiveChanged();
	void addDummyNotification(bool isAlarm);

private:
	explicit MockManager(QObject *parent = nullptr);
	~MockManager() override;

	bool setValuesFromJson(const QString &fileName);
	void setServiceValues(const QJsonObject &object);
	void setPropertyValues(const QString &path, const QJsonObject &properties);
	VeQItemMockProducer *producer() const;
	void onExternalWrite(const QString &uid);

	QString m_confFileName;
	bool m_timersActive = false;
	QHash<QString, int> m_calculatorSources; // uid -> number of calculators reading it
	MockTimerWorker *m_timerWorker = nullptr;
	MockValueApplier *m_valueApplier = nullptr;
};

}
}

#endif // VICTRON_GUIV2_MOCKMANAGER_H
