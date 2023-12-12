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
	Q_PROPERTY(QDateTime currentDateTime MEMBER m_currentDateTime NOTIFY currentDateTimeChanged)
	Q_PROPERTY(QDateTime currentDateTimeUtc MEMBER m_currentDateTimeUtc NOTIFY currentDateTimeUtcChanged)
	Q_PROPERTY(QString currentTimeText MEMBER m_currentTimeText NOTIFY currentTimeTextChanged)
	Q_PROPERTY(QString currentTimeUtcText MEMBER m_currentTimeUtcText NOTIFY currentTimeUtcTextChanged)
	Q_PROPERTY(QString systemTimeZone READ systemTimeZone WRITE setSystemTimeZone NOTIFY systemTimeZoneChanged)

public:
	static ClockTime* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);

	QString systemTimeZone() const;
	void setSystemTimeZone(const QString &tz); // "region/city" format.

public Q_SLOTS:
	QString formatTime(int hour, int minute) const;
	bool isDateValid(int year, int month, int day) const; // month is 1-12
	void setClockTime(qint64 secondsSinceEpoch);

Q_SIGNALS:
	void currentDateTimeChanged();
	void currentDateTimeUtcChanged();
	void currentTimeTextChanged();
	void currentTimeUtcTextChanged();
	void systemTimeZoneChanged();

protected:
	void timerEvent(QTimerEvent *) override;

private:
	ClockTime(QObject *parent);
	void updateTime();
	void scheduleNextTimeCheck(int interval);

	QDateTime m_currentDateTime;
	QDateTime m_currentDateTimeUtc;
	QString m_currentTimeText;
	QString m_currentTimeUtcText;
	QString m_systemTimeZone;
	qint64 m_secondsSinceEpoch = 0;
	int m_timerInterval = 0;
	int m_timerId = 0;
};

} /* VenusOS */

} /* Victron */

#endif // VICTRON_VENUSOS_CLOCKTIME_H

