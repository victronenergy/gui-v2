/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_CLOCKTIME_H
#define VICTRON_VENUSOS_CLOCKTIME_H

#include <QObject>
#include <QDateTime>
#include <QTime>
#include <qqmlintegration.h>

class QQmlEngine;
class QJSEngine;

namespace Victron {

namespace VenusOS {

class ClockTime : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON

	// Note: access in QML will result in conversion to JS Date
	// which may not retain timezone information (if the system time zone
	// doesn't match the QDateTime's timezone).
	// For CerboGX, `date` reports that the timezone is still UTC
	// after setting the DBus/MQTT platform/Device/Time setting,
	// so the system timezone will not usually match the Qt timezone.
	// For WebAssembly, QTBUG-91441 means that we can never guarantee
	// that the dateTime will be in the systemTimeZone.
	// In short: QML clients should not access this directly, in general.
	Q_PROPERTY(QDateTime dateTime READ dateTime NOTIFY dateTimeChanged FINAL)

	// Expose the needed data from the dateTime as ints.
	// The data will be in the "correct" timezone.
	Q_PROPERTY(int year READ year NOTIFY yearChanged FINAL)
	Q_PROPERTY(int month READ month NOTIFY monthChanged FINAL)
	Q_PROPERTY(int day READ day NOTIFY dayChanged FINAL)
	Q_PROPERTY(int hour READ hour NOTIFY hourChanged FINAL)
	Q_PROPERTY(int minute READ minute NOTIFY minuteChanged FINAL)
	Q_PROPERTY(int second READ second NOTIFY secondChanged FINAL)
	Q_PROPERTY(int msec READ msec NOTIFY msecChanged FINAL)

	Q_PROPERTY(qint64 clockTime READ clockTime WRITE setClockTime NOTIFY clockTimeChanged FINAL) // secsSinceEpoch.
	Q_PROPERTY(QString systemTimeZone READ systemTimeZone WRITE setSystemTimeZone NOTIFY systemTimeZoneChanged FINAL)

	Q_PROPERTY(QString currentDate READ currentDate NOTIFY currentDateChanged FINAL)
	Q_PROPERTY(QString currentTime READ currentTime NOTIFY currentTimeChanged FINAL)
	Q_PROPERTY(QString currentDateTimeUtc READ currentDateTimeUtc NOTIFY currentDateTimeUtcChanged FINAL)

public:
	static ClockTime* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);

	QDateTime dateTime() const;
	void setDateTime(const QDateTime &dt);

	int year() const;
	int month() const;
	int day() const;
	int hour() const;
	int minute() const;
	int second() const;
	int msec() const;

	qint64 clockTime() const;
	void setClockTime(qint64 secondsSinceEpoch);

	QString systemTimeZone() const;
	void setSystemTimeZone(const QString &tz); // "region/city" format.

	QString currentDate() const;
	QString currentTime() const;
	QString currentDateTimeUtc() const;

	Q_INVOKABLE QString formatTime(int hour, int minute) const; // as hh:mm
	Q_INVOKABLE QString formatDeltaDate(qint64 secondsDelta, const QString &format) const; // negative is in the past
	Q_INVOKABLE qint64 otherClockTime(int year, int month, int day, int hour, int minute) const;
	Q_INVOKABLE bool isDateValid(int year, int month, int day) const; // month is 1-12
	Q_INVOKABLE int daysInMonth(int month, int year) const;

Q_SIGNALS:
	void dateTimeChanged();
	void yearChanged();
	void monthChanged();
	void dayChanged();
	void hourChanged();
	void minuteChanged();
	void secondChanged();
	void msecChanged();
	void clockTimeChanged();
	void systemTimeZoneChanged();
	void currentDateChanged();
	void currentTimeChanged();
	void currentDateTimeUtcChanged();

protected:
	void timerEvent(QTimerEvent *) override;

private:
	ClockTime(QObject *parent);
	void updateTime(qint64 secsSinceEpoch);
	void scheduleNextTimeCheck(int interval);

	QDateTime m_dateTime;
	QString m_systemTimeZone;
	int m_timerInterval = 0;
	int m_timerId = 0;
};

} /* VenusOS */

} /* Victron */

#endif // VICTRON_VENUSOS_CLOCKTIME_H

