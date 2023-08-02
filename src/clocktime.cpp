#include "clocktime.h"

#if !defined(VENUS_WEBASSEMBLY_BUILD)
#include <QTimeZone>
#endif

using namespace Victron::VenusOS;

ClockTime::ClockTime(QObject *parent)
	: QObject(parent)
{
}

QString ClockTime::formatTime(int hour, int minute) const
{
	QTime t(hour, minute);
	return t.toString("hh:mm");
}

bool ClockTime::isDateValid(int year, int month, int day) const
{
	static const QCalendar calendar;
	return calendar.isDateValid(year, month, day);
}

void ClockTime::setClockTime(qint64 secondsSinceEpoch)
{
	if (m_secondsSinceEpoch == secondsSinceEpoch) {
		return;
	}
	m_secondsSinceEpoch = secondsSinceEpoch;
	updateTime();

	// Wait until just after the next clock minute, then update the time properties.
	const int secsUntilNextMin = 60 - m_currentDateTime.time().second();
	scheduleNextTimeCheck((secsUntilNextMin + 1) * 1000);
}

void ClockTime::timerEvent(QTimerEvent *)
{
	if (m_secondsSinceEpoch <= 0) {
		return;
	}
	m_secondsSinceEpoch += (m_timerInterval / 1000);
	updateTime();
	scheduleNextTimeCheck(60 * 1000);
}

void ClockTime::updateTime()
{
	if (m_secondsSinceEpoch <= 0) {
		return;
	}

	m_currentDateTimeUtc = QDateTime::fromSecsSinceEpoch(m_secondsSinceEpoch, Qt::UTC);

	if (m_systemTimeZone.compare(QStringLiteral("/UTC"), Qt::CaseInsensitive) == 0
			|| m_systemTimeZone.compare(QStringLiteral("UTC"), Qt::CaseInsensitive) == 0) {
		m_currentDateTime = m_currentDateTimeUtc;
	} else {
#if defined(VENUS_WEBASSEMBLY_BUILD)
		// Cannot use QTimeZone in Emscripten builds.
		// We thus cannot convert to the specified timezone offset.
		// The local time will be the local time of the browser.
		m_currentDateTime = m_currentDateTimeUtc.toLocalTime();
#else
		m_currentDateTime = m_currentDateTimeUtc.toTimeZone(QTimeZone(m_systemTimeZone.toUtf8()));
#endif
	}

	m_currentTimeText = m_currentDateTime.toString("hh:mm");
	m_currentTimeUtcText = m_currentDateTimeUtc.toString("yyyy-MM-dd hh:mm");

	emit currentDateTimeChanged();
	emit currentDateTimeUtcChanged();
	emit currentTimeTextChanged();
	emit currentTimeUtcTextChanged();
}

void ClockTime::scheduleNextTimeCheck(int interval)
{
	if (m_timerId > 0) {
		killTimer(m_timerId);
	}
	m_timerInterval = interval;
	m_timerId = startTimer(interval);
}

ClockTime* ClockTime::instance(QObject* parent)
{
	return new ClockTime(parent);
}

QString ClockTime::systemTimeZone() const
{
	return m_systemTimeZone;
}

void ClockTime::setSystemTimeZone(const QString &tz)
{
	if (m_systemTimeZone != tz) {
		m_systemTimeZone = tz;
		updateTime();
		emit systemTimeZoneChanged();
	}
}

