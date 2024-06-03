/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef CPUINFO_H
#define CPUINFO_H

#include <QObject>
#include <QQmlEngine>
#include <QTimer>
#include <QThread>

namespace Victron {
namespace VenusOS {

class CpuInfoWorker : public QObject
{
	Q_OBJECT
public:
	explicit CpuInfoWorker(QObject *parent = nullptr);
public Q_SLOTS:
	void calculateCpuUsage(unsigned long long busy, unsigned long long idle);
Q_SIGNALS:
	void calculatedCpuUsage(int usage, unsigned long long previousBusy, unsigned long long previousIdle);
};

class CpuInfo : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int usage MEMBER m_usage NOTIFY usageChanged FINAL)
	Q_PROPERTY(bool enabled MEMBER m_enabled NOTIFY enabledChanged FINAL)
	Q_PROPERTY(int upperLimit MEMBER m_upperLimit NOTIFY upperLimitChanged FINAL)
	Q_PROPERTY(int lowerLimit MEMBER m_lowerLimit NOTIFY lowerLimitChanged FINAL)
	Q_PROPERTY(bool overLimit MEMBER m_overLimit NOTIFY overLimitChanged FINAL)
public:
	explicit CpuInfo(QObject *parent = nullptr);
	~CpuInfo();
Q_SIGNALS:
	void usageChanged();
	void enabledChanged();
	void upperLimitChanged();
	void lowerLimitChanged();
	void overLimitChanged();
	void requestingCpuUsage(unsigned long long previousBusy, unsigned long long previousIdle);
private:
	void handleCpuUsage(int usage, unsigned long long busy, unsigned long long idle);
	int m_usage = 0;
	int m_lowerLimit = 0;
	int m_upperLimit = 100;
	bool m_overLimit = false;
	bool m_enabled = true;
	unsigned long long m_previousBusy = 0;
	unsigned long long m_previousIdle = 0;
	QTimer m_timer;
	QThread m_thread;
	CpuInfoWorker *m_worker = nullptr;
};

}
}

#endif // CPUINFO_H
