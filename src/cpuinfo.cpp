/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "cpuinfo.h"

using namespace Victron::VenusOS;

#ifdef Q_OS_LINUX
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int get_cpu_usage(unsigned long long &previousBusy, unsigned long long &previousIdle) {
	// Read CPU stats
	FILE *file = fopen("/proc/stat", "r");
	if (file == nullptr) {
		qWarning() << "Could not open /proc/stat";
		return -1;
	}

	unsigned long long user, nice, system, idleTotal, busyTotal;
	fscanf(file, "cpu %llu %llu %llu %llu", &user, &nice, &system, &idleTotal);
	busyTotal = user + nice + system;
	fclose(file);

	// Calculate CPU usage
	unsigned long long busy = busyTotal - previousBusy;
	unsigned long long idle = idleTotal - previousIdle;
	previousBusy = busyTotal;
	previousIdle = idleTotal;
	return qRound((busy * 100.0) / (busy + idle));
}
#endif

CpuInfo::CpuInfo(QObject *parent)
	: QObject(parent)
{
#ifdef Q_OS_LINUX
	m_worker = new CpuInfoWorker;
	m_worker->moveToThread(&m_thread);
	connect(&m_thread, &QThread::finished, m_worker, &QObject::deleteLater);
	connect(this, &CpuInfo::requestingCpuUsage, m_worker, &CpuInfoWorker::calculateCpuUsage);
	connect(m_worker, &CpuInfoWorker::calculatedCpuUsage, this, &CpuInfo::handleCpuUsage);

	m_timer.setInterval(5000);
	if (m_enabled) {
		m_timer.start();
	}

	connect(this, &CpuInfo::enabledChanged, this, [this] {
		if (m_enabled) {
			m_timer.start();
		} else {
			m_timer.stop();
		}
	});

	connect(&m_timer, &QTimer::timeout, this, [this] {
		emit requestingCpuUsage(m_previousBusy, m_previousIdle);
	});

	m_thread.start();
#endif
}

CpuInfo::~CpuInfo()
{
#ifdef Q_OS_LINUX
	m_thread.quit();
	m_thread.wait();
#endif
}

void CpuInfo::handleCpuUsage(int usage, unsigned long long busy, unsigned long long idle)
{
	m_previousBusy = busy;
	m_previousIdle = idle;
	if (m_usage != usage) {
		m_usage = usage;
		if (m_overLimit && usage < m_lowerLimit) {
			m_overLimit = false;
			emit overLimitChanged();
		} else if (!m_overLimit && usage > m_upperLimit) {
			m_overLimit = true;
			emit overLimitChanged();
		}
		emit usageChanged();
	}
}

CpuInfoWorker::CpuInfoWorker(QObject *parent)
	: QObject(parent)
{
}

#ifdef Q_OS_LINUX
void CpuInfoWorker::calculateCpuUsage(unsigned long long previousBusy , unsigned long long previousIdle)
#else
void CpuInfoWorker::calculateCpuUsage(unsigned long long, unsigned long long)
#endif
{
#ifdef Q_OS_LINUX
	unsigned long long busy = previousBusy;
	unsigned long long idle = previousIdle;
	const int usage = get_cpu_usage(busy, idle);
	emit calculatedCpuUsage(usage, busy, idle);
#endif
}
