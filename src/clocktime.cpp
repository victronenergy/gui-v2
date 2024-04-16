/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "clocktime.h"

#if !defined(VENUS_WEBASSEMBLY_BUILD)
#include <QTimeZone>
#endif

using namespace Victron::VenusOS;

ClockTime::ClockTime(QObject *parent)
	: QObject(parent)
{
}

ClockTime* ClockTime::create(QQmlEngine *engine, QJSEngine *)
{
	static ClockTime* clockTime = new ClockTime(nullptr);
	return clockTime;
}

QDateTime ClockTime::dateTime() const
{
	return m_dateTime;
}

void ClockTime::setDateTime(const QDateTime &dt)
{
	if (m_dateTime != dt || m_dateTime.timeZoneAbbreviation() != dt.timeZoneAbbreviation()) {
		const QDateTime old = m_dateTime;
		m_dateTime = dt;
		emit dateTimeChanged();
		emit clockTimeChanged();
		if (old.date().year() != dt.date().year()) emit yearChanged();
		if (old.date().month() != dt.date().month()) emit monthChanged();
		if (old.date().day() != dt.date().day()) emit dayChanged();
		if (old.time().hour() != dt.time().hour()) emit hourChanged();
		if (old.time().minute() != dt.time().minute()) emit minuteChanged();
		if (old.time().second() != dt.time().second()) emit secondChanged();
		if (old.time().msec() != dt.time().msec()) emit msecChanged();
		if (old.date().year() != dt.date().year()
				|| old.date().month() != dt.date().month()
				|| old.date().day() != dt.date().day()) emit currentDateChanged();
		if (old.time().hour() != dt.time().hour()
				|| old.time().minute() != dt.time().minute()) emit currentTimeChanged();
		emit currentDateTimeUtcChanged();
	}
}

int ClockTime::year() const
{
	return m_dateTime.date().year();
}

int ClockTime::month() const
{
	return m_dateTime.date().month();
}

int ClockTime::day() const
{
	return m_dateTime.date().day();
}

int ClockTime::hour() const
{
	return m_dateTime.time().hour();
}

int ClockTime::minute() const
{
	return m_dateTime.time().minute();
}

int ClockTime::second() const
{
	return m_dateTime.time().second();
}

int ClockTime::msec() const
{
	return m_dateTime.time().msec();
}

qint64 ClockTime::clockTime() const
{
	return m_dateTime.toSecsSinceEpoch();
}

void ClockTime::setClockTime(qint64 secondsSinceEpoch)
{
	if (clockTime() == secondsSinceEpoch) {
		return;
	}

	updateTime(secondsSinceEpoch);

	// Wait until just after the next clock minute, then update the time properties.
	const int secsUntilNextMin = 60 - m_dateTime.time().second();
	scheduleNextTimeCheck((secsUntilNextMin + 1) * 1000);
}

QString ClockTime::systemTimeZone() const
{
	return m_systemTimeZone;
}

void ClockTime::setSystemTimeZone(const QString &tz)
{
	if (m_systemTimeZone != tz) {
		m_systemTimeZone = tz;
		updateTime(clockTime());
		emit systemTimeZoneChanged();
	}
}

QString ClockTime::currentDate() const
{
	return m_dateTime.toString("yyyy-MM-dd");
}

QString ClockTime::currentTime() const
{
	return m_dateTime.toString("hh:mm");
}

QString ClockTime::currentDateTimeUtc() const
{
	return m_dateTime.toUTC().toString("yyyy-MM-dd hh:mm");
}

QString ClockTime::formatTime(int hour, int minute) const
{
	QTime t(hour, minute);
	return t.toString("hh:mm");
}

QString ClockTime::formatDeltaDate(qint64 secondsDelta, const QString &format) const
{
	return m_dateTime.addSecs(secondsDelta).toString(format);
}

qint64 ClockTime::otherClockTime(int year, int month, int day, int hour, int minute) const
{
	// assume that the specified date/time is in our current clock time's timezone.
	QDateTime other = m_dateTime;
	QDate d = other.date();
	d.setDate(year, month, day);
	other.setDate(d);
	QTime t = other.time();
	t.setHMS(hour, minute, t.second(), t.msec());
	other.setTime(t);
	return other.toSecsSinceEpoch();
}

bool ClockTime::isDateValid(int year, int month, int day) const
{
	static const QCalendar calendar;
	return calendar.isDateValid(year, month, day);
}

int ClockTime::daysInMonth(int month, int year) const
{
	static const QCalendar calendar;
	return calendar.daysInMonth(month, year);
}

void ClockTime::timerEvent(QTimerEvent *)
{
	qint64 secsSinceEpoch = clockTime();
	if (secsSinceEpoch <= 0) {
		return;
	}

	secsSinceEpoch += (m_timerInterval / 1000);
	updateTime(secsSinceEpoch);
	scheduleNextTimeCheck(60 * 1000);
}

void ClockTime::updateTime(qint64 secsSinceEpoch)
{
	if (secsSinceEpoch <= 0) {
		return;
	}

	const QDateTime currentUtc = QDateTime::fromSecsSinceEpoch(secsSinceEpoch, Qt::UTC);

	if (m_systemTimeZone.compare(QStringLiteral("/UTC"), Qt::CaseInsensitive) == 0
			|| m_systemTimeZone.compare(QStringLiteral("UTC"), Qt::CaseInsensitive) == 0) {
		setDateTime(currentUtc);
	} else {
#if defined(VENUS_WEBASSEMBLY_BUILD)
		// Cannot use QTimeZone in Emscripten builds.
		// We thus cannot convert to the specified timezone offset.
		// The local time will be the local time of the browser.
		setDateTime(currentUtc.toLocalTime());
#else
		setDateTime(currentUtc.toTimeZone(QTimeZone(m_systemTimeZone.toUtf8())));
#endif
	}

}

void ClockTime::scheduleNextTimeCheck(int interval)
{
	if (m_timerId > 0) {
		killTimer(m_timerId);
	}
	m_timerInterval = interval;
	m_timerId = startTimer(interval);
}

