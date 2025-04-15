/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef BASENOTIFICATION_H
#define BASENOTIFICATION_H

#include <QObject>
#include <qqmlintegration.h>
#include <QDateTime>

namespace Victron {

namespace VenusOS {

class BaseNotification : public QObject
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(int notificationId READ notificationId WRITE setNotificationId NOTIFY notificationIdChanged FINAL)
	Q_PROPERTY(bool acknowledged READ acknowledged WRITE setAcknowledged NOTIFY acknowledgedChanged FINAL)
	Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged FINAL)
	Q_PROPERTY(bool activeOrUnAcknowledged READ activeOrUnAcknowledged NOTIFY activeOrUnAcknowledgedChanged FINAL)
	Q_PROPERTY(int type READ type WRITE setType NOTIFY typeChanged FINAL)
	Q_PROPERTY(QDateTime dateTime READ dateTime WRITE setDateTime NOTIFY dateTimeChanged FINAL)
	Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged FINAL)
	Q_PROPERTY(QString deviceName READ deviceName WRITE setDeviceName NOTIFY deviceNameChanged FINAL)
	Q_PROPERTY(QString value READ value WRITE setValue NOTIFY valueChanged FINAL)

public:
	int notificationId() const;
	void setNotificationId(int notificationId);

	bool acknowledged() const;
	void setAcknowledged(bool acknowledged);

	bool active() const;
	void setActive(bool active);

	bool activeOrUnAcknowledged() const;

	int type() const;
	void setType(int type);

	QDateTime dateTime() const;
	void setDateTime(const QDateTime &dateTime);

	QString description() const;
	void setDescription(const QString &description);

	QString deviceName() const;
	void setDeviceName(const QString &deviceName);

	QString value() const;
	void setValue(const QString &value);

signals:
	void notificationIdChanged();
	void acknowledgedChanged();
	void activeChanged();
	void activeOrUnAcknowledgedChanged();
	void typeChanged();
	void dateTimeChanged();
	void descriptionChanged();
	void deviceNameChanged();
	void valueChanged();

private:
	int m_notificationId = -1;
	bool m_acknowledged = false;
	bool m_active = false;
	int m_type = -1;
	QDateTime m_dateTime;
	QString m_description;
	QString m_deviceName;
	QString m_value;
};

} /* VenusOS */

} /* Victron */
#endif // BASENOTIFICATION_H
