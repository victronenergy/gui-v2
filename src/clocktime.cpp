#include "clocktime.h"

using namespace Victron::VenusOS;

ClockTime::ClockTime(QObject *parent)
	: QObject(parent)
{
	updateTime();
	scheduleNextTimeCheck(m_currentDateTime.time());
}

QString ClockTime::formatTime(int hour, int minute)
{
	QTime t(hour, minute);
	return t.toString("hh:mm");
}

void ClockTime::timerEvent(QTimerEvent *)
{
	const QTime currentTime = QTime::currentTime();
	if (currentTime.minute() != m_currentDateTime.time().minute()) {
		updateTime();
	}
	scheduleNextTimeCheck(currentTime);
}

void ClockTime::updateTime()
{
	m_currentDateTime = QDateTime::currentDateTime();
	m_currentDateTimeUtc = m_currentDateTime.toUTC();
	m_currentTimeText = m_currentDateTime.toString("hh:mm");

	emit currentDateTimeChanged();
	emit currentDateTimeUtcChanged();
	emit currentTimeTextChanged();
}

void ClockTime::scheduleNextTimeCheck(const QTime &now)
{
	if (m_timerId > 0) {
		killTimer(m_timerId);
	}

	// Wait until just after the next clock minute, then update the time properties.
	const int secsUntilNextMin = 60 - now.second();
	m_timerId = startTimer((secsUntilNextMin + 1) * 1000);
}

ClockTime* ClockTime::instance(QObject* parent)
{
	return new ClockTime(parent);
}

