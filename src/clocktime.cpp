#include "clocktime.h"

#if !defined(VENUS_WEBASSEMBLY_BUILD)
#include <QTimeZone>
#endif

using namespace Victron::VenusOS;

ClockTime::ClockTime(QObject *parent)
	: QObject(parent)
{
	updateTime();
	scheduleNextTimeCheck(m_currentDateTime.time());
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
	if (m_systemTimeZone.compare(QStringLiteral("/UTC"), Qt::CaseInsensitive) == 0
			|| m_systemTimeZone.compare(QStringLiteral("UTC"), Qt::CaseInsensitive) == 0) {
		m_currentDateTime = QDateTime::currentDateTimeUtc();
	} else {
#if defined(VENUS_WEBASSEMBLY_BUILD)
		// Cannot use QTimeZone in Emscripten builds.
		// We thus cannot convert to the specified timezone offset.
		// The local time will be the local time of the browser.
		m_currentDateTime = QDateTime::currentDateTime();
#else
		m_currentDateTime = QDateTime::currentDateTime().toTimeZone(QTimeZone(m_systemTimeZone.toUtf8()));
#endif
	}
	m_currentDateTimeUtc = QDateTime::currentDateTimeUtc();
	m_currentTimeText = m_currentDateTime.toString("hh:mm");
	m_currentTimeUtcText = m_currentDateTimeUtc.toString("yyyy-MM-dd hh:mm");

	emit currentDateTimeChanged();
	emit currentDateTimeUtcChanged();
	emit currentTimeTextChanged();
	emit currentTimeUtcTextChanged();
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

