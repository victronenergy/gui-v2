/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_MOCKCONSUMPTIONCALCULATOR_H
#define VICTRON_GUIV2_MOCKCONSUMPTIONCALCULATOR_H

#include "mocktimerworker.h"

#include <QObject>
#include <QQmlEngine>
#include <QQmlParserStatus>
#include <QStringList>

namespace Victron {
namespace VenusOS {

/*
	MockConsumptionCalculator is a QML_ELEMENT that lives on the GUI thread.
	It manages a list of AC service UIDs (added/removed dynamically via Instantiator)
	and posts the configuration to MockTimerWorker, which evaluates consumption
	entirely on the worker thread.

	The worker computes:
	  - ConsumptionOnInput/L{1,2,3}/{Power,Current}
	  - ConsumptionOnOutput/L{1,2,3}/{Power,Current}
	  - Consumption/L{1,2,3}/{Power,Current}
	  - NumberOfPhases for each category
	and emits the results in the same batch as other animator outputs.
*/
class MockConsumptionCalculator : public QObject, public QQmlParserStatus
{
	Q_OBJECT
	QML_ELEMENT
	Q_INTERFACES(QQmlParserStatus)

	// The system UID prefix (e.g. "mock/com.victronenergy.system")
	Q_PROPERTY(QString systemUidPrefix READ systemUidPrefix WRITE setSystemUidPrefix NOTIFY systemUidPrefixChanged FINAL)
	Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged FINAL)

public:
	explicit MockConsumptionCalculator(QObject *parent = nullptr);
	~MockConsumptionCalculator() override;

	QString systemUidPrefix() const { return m_systemUidPrefix; }
	void setSystemUidPrefix(const QString &v);

	bool active() const { return m_active; }
	void setActive(bool v);

	// Called from QML when services are added/removed
	Q_INVOKABLE void addService(const QString &uid, const QString &serviceType, int index);
	Q_INVOKABLE void removeService(const QString &uid);

Q_SIGNALS:
	void systemUidPrefixChanged();
	void activeChanged();

protected:
	void classBegin() override {}
	void componentComplete() override;

private:
	void postConfigToWorker();

	struct ServiceInfo {
		QString uid;
		QString serviceType;
		int index = 0;
	};

	QVector<ServiceInfo> m_services;
	QString m_systemUidPrefix;
	bool m_active = true;
	bool m_complete = false;
};

/*
	MockPhaseSumCalculator sums per-phase power/current from a dynamic set of
	services and writes the totals to target paths. All computation runs on the
	worker thread.

	Usage in QML:
		MockPhaseSumCalculator {
			targetPrefix: "mock/com.victronenergy.system/Ac/PvOnOutput"
			sourcePhasePattern: "/Ac/L%1/Power"
			sourceCurrentPattern: "/Ac/L%1/Current"
		}
		// call addService(uid) / removeService(uid) dynamically
*/
class MockPhaseSumCalculator : public QObject, public QQmlParserStatus
{
	Q_OBJECT
	QML_ELEMENT
	Q_INTERFACES(QQmlParserStatus)

	Q_PROPERTY(QString targetPrefix READ targetPrefix WRITE setTargetPrefix NOTIFY targetPrefixChanged FINAL)
	Q_PROPERTY(QString sourcePhasePattern READ sourcePhasePattern WRITE setSourcePhasePattern NOTIFY sourcePhasePatternChanged FINAL)
	Q_PROPERTY(QString sourceCurrentPattern READ sourceCurrentPattern WRITE setSourceCurrentPattern NOTIFY sourceCurrentPatternChanged FINAL)

public:
	explicit MockPhaseSumCalculator(QObject *parent = nullptr);
	~MockPhaseSumCalculator() override;

	QString targetPrefix() const { return m_targetPrefix; }
	void setTargetPrefix(const QString &v);

	QString sourcePhasePattern() const { return m_sourcePhasePattern; }
	void setSourcePhasePattern(const QString &v);

	QString sourceCurrentPattern() const { return m_sourceCurrentPattern; }
	void setSourceCurrentPattern(const QString &v);

	Q_INVOKABLE void addService(const QString &uid);
	Q_INVOKABLE void removeService(const QString &uid);

Q_SIGNALS:
	void targetPrefixChanged();
	void sourcePhasePatternChanged();
	void sourceCurrentPatternChanged();

protected:
	void classBegin() override {}
	void componentComplete() override;

private:
	void postConfigToWorker();
	static int nextRuleId();

	int m_ruleId;
	QStringList m_serviceUids;
	QString m_targetPrefix;
	QString m_sourcePhasePattern;
	QString m_sourceCurrentPattern;
	bool m_complete = false;
};

} // namespace VenusOS
} // namespace Victron

#endif // VICTRON_GUIV2_MOCKCONSUMPTIONCALCULATOR_H
