/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "mockconsumptioncalculator.h"
#include "mockmanager.h"

#include <atomic>

using namespace Victron::VenusOS;

MockConsumptionCalculator::MockConsumptionCalculator(QObject *parent)
	: QObject(parent)
{
}

MockConsumptionCalculator::~MockConsumptionCalculator()
{
	replaceWatches({});
	MockTimerWorker *worker = MockManager::create()->timerWorker();
	if (worker) {
		QMetaObject::invokeMethod(worker, "clearConsumptionConfig", Qt::QueuedConnection);
	}
}

void MockConsumptionCalculator::setSystemUidPrefix(const QString &v)
{
	if (m_systemUidPrefix != v) {
		m_systemUidPrefix = v;
		if (m_complete && m_active) {
			postConfigToWorker();
		}
		Q_EMIT systemUidPrefixChanged();
	}
}

void MockConsumptionCalculator::setActive(bool v)
{
	if (m_active != v) {
		m_active = v;
		if (m_complete) {
			if (m_active) {
				postConfigToWorker();
			} else {
				replaceWatches({});
				MockTimerWorker *worker = MockManager::create()->timerWorker();
				if (worker) {
					QMetaObject::invokeMethod(worker, "clearConsumptionConfig", Qt::QueuedConnection);
				}
			}
		}
		Q_EMIT activeChanged();
	}
}

void MockConsumptionCalculator::setGaugesAutoMax(bool v)
{
	if (m_gaugesAutoMax != v) {
		m_gaugesAutoMax = v;
		if (m_complete && m_active) {
			postConfigToWorker();
		}
		Q_EMIT gaugesAutoMaxChanged();
	}
}

void MockConsumptionCalculator::setGaugesUidPrefix(const QString &v)
{
	if (m_gaugesUidPrefix != v) {
		m_gaugesUidPrefix = v;
		if (m_complete && m_active) {
			postConfigToWorker();
		}
		Q_EMIT gaugesUidPrefixChanged();
	}
}

void MockConsumptionCalculator::addService(const QString &uid, const QString &serviceType, int index)
{
	m_services.append({uid, serviceType, index});
	if (m_complete && m_active) {
		postConfigToWorker();
	}
}

void MockConsumptionCalculator::removeService(const QString &uid)
{
	for (qsizetype i = 0; i < m_services.size(); ++i) {
		if (m_services[i].uid == uid) {
			m_services.remove(i);
			break;
		}
	}
	if (m_complete && m_active) {
		postConfigToWorker();
	}
}

void MockConsumptionCalculator::componentComplete()
{
	m_complete = true;
	if (m_active && !m_services.isEmpty()) {
		postConfigToWorker();
	}
}

void MockConsumptionCalculator::replaceWatches(const QStringList &uids)
{
	if (m_watchedSources == uids) {
		return;
	}
	MockManager *manager = MockManager::create();
	manager->unwatchUids(m_watchedSources, MockWatchRole::CalculatorSource);
	manager->watchUids(uids, MockWatchRole::CalculatorSource);
	m_watchedSources = uids;
}

QStringList MockConsumptionCalculator::sourceUids() const
{
	QStringList uids;
	for (const auto &svc : m_services) {
		const QString uid = normalizedMockUid(svc.uid);
		appendPhaseMeasureUids(uids, consumptionAcInPrefix(uid, svc.serviceType, svc.index));
		appendPhaseMeasureUids(uids, consumptionAcOutPrefix(uid, svc.serviceType));
		if (svc.serviceType == QLatin1String("vebus") || svc.serviceType == QLatin1String("acsystem")) {
			uids.append(uid + QStringLiteral("/Ac/NumberOfPhases"));
		}
	}
	if (m_gaugesAutoMax && !m_gaugesUidPrefix.isEmpty()) {
		const QString prefix = normalizedMockUid(m_gaugesUidPrefix);
		const QStringList paths = consumptionGaugePaths();
		for (const QString &path : paths) {
			uids.append(prefix + path);
		}
	}
	return uids;
}

void MockConsumptionCalculator::postConfigToWorker()
{
	MockTimerWorker *worker = MockManager::create()->timerWorker();
	if (!worker) {
		return;
	}

	const QStringList sources = sourceUids();
	replaceWatches(sources);

	MockValueCache currentValues;
	MockManager *manager = MockManager::create();
	for (const QString &uid : sources) {
		currentValues.insert(uid, manager->value(uid));
	}

	MockConsumptionConfig config;
	config.reserve(m_services.size());
	for (const auto &svc : m_services) {
		config.append({svc.uid, svc.serviceType, svc.index});
	}

	QMetaObject::invokeMethod(worker, "setConsumptionConfig",
		Qt::QueuedConnection,
		Q_ARG(QString, m_systemUidPrefix),
		Q_ARG(Victron::VenusOS::MockConsumptionConfig, config),
		Q_ARG(bool, m_gaugesAutoMax),
		Q_ARG(QString, m_gaugesUidPrefix),
		Q_ARG(MockValueCache, currentValues));
}

// --- MockPhaseSumCalculator ---

int MockPhaseSumCalculator::nextRuleId()
{
	static std::atomic<int> s_id{1};
	return s_id.fetch_add(1);
}

MockPhaseSumCalculator::MockPhaseSumCalculator(QObject *parent)
	: QObject(parent)
	, m_ruleId(nextRuleId())
{
}

MockPhaseSumCalculator::~MockPhaseSumCalculator()
{
	replaceWatches({});
	MockTimerWorker *worker = MockManager::create()->timerWorker();
	if (worker) {
		QMetaObject::invokeMethod(worker, "clearPhaseSumConfig",
			Qt::QueuedConnection, Q_ARG(int, m_ruleId));
	}
}

void MockPhaseSumCalculator::setTargetPrefix(const QString &v)
{
	if (m_targetPrefix != v) {
		m_targetPrefix = v;
		if (m_complete) postConfigToWorker();
		Q_EMIT targetPrefixChanged();
	}
}

void MockPhaseSumCalculator::setSourcePhasePattern(const QString &v)
{
	if (m_sourcePhasePattern != v) {
		m_sourcePhasePattern = v;
		if (m_complete) postConfigToWorker();
		Q_EMIT sourcePhasePatternChanged();
	}
}

void MockPhaseSumCalculator::setSourceCurrentPattern(const QString &v)
{
	if (m_sourceCurrentPattern != v) {
		m_sourceCurrentPattern = v;
		if (m_complete) postConfigToWorker();
		Q_EMIT sourceCurrentPatternChanged();
	}
}

void MockPhaseSumCalculator::addService(const QString &uid)
{
	m_serviceUids.append(uid);
	if (m_complete) postConfigToWorker();
}

void MockPhaseSumCalculator::removeService(const QString &uid)
{
	m_serviceUids.removeOne(uid);
	if (m_complete) postConfigToWorker();
}

void MockPhaseSumCalculator::componentComplete()
{
	m_complete = true;
	if (!m_serviceUids.isEmpty()) {
		postConfigToWorker();
	}
}

void MockPhaseSumCalculator::replaceWatches(const QStringList &uids)
{
	if (m_watchedSources == uids) {
		return;
	}
	MockManager *manager = MockManager::create();
	manager->unwatchUids(m_watchedSources, MockWatchRole::CalculatorSource);
	manager->watchUids(uids, MockWatchRole::CalculatorSource);
	m_watchedSources = uids;
}

void MockPhaseSumCalculator::postConfigToWorker()
{
	MockTimerWorker *worker = MockManager::create()->timerWorker();
	if (!worker) {
		return;
	}

	// Treat empty targetPrefix, sourcePhasePattern, or service list as "disabled"
	if (m_targetPrefix.isEmpty() || m_sourcePhasePattern.isEmpty() || m_serviceUids.isEmpty()) {
		replaceWatches({});
		QMetaObject::invokeMethod(worker, "clearPhaseSumConfig",
			Qt::QueuedConnection, Q_ARG(int, m_ruleId));
		return;
	}

	QStringList sources;
	appendPhaseSumSourceUids(sources, m_serviceUids, m_sourcePhasePattern, m_sourceCurrentPattern);
	for (QString &uid : sources) {
		uid = normalizedMockUid(uid);
	}
	replaceWatches(sources);

	MockValueCache currentValues;
	MockManager *manager = MockManager::create();
	for (const QString &uid : sources) {
		currentValues.insert(uid, manager->value(uid));
	}

	QMetaObject::invokeMethod(worker, "setPhaseSumConfig",
		Qt::QueuedConnection,
		Q_ARG(int, m_ruleId),
		Q_ARG(QString, m_targetPrefix),
		Q_ARG(QStringList, m_serviceUids),
		Q_ARG(QString, m_sourcePhasePattern),
		Q_ARG(QString, m_sourceCurrentPattern),
		Q_ARG(MockValueCache, currentValues));
}
