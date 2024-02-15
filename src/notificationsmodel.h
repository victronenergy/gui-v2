/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef NOTIFICATIONSMODEL_H
#define NOTIFICATIONSMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QSortFilterProxyModel>
#include <QDateTime>
#include <QVariantList>
#include "enums.h"

class QQmlEngine;
class QJSEngine;

class AlarmMonitor;

namespace Victron {

namespace VenusOS {


class BaseNotification : public QObject
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(int notificationId READ notificationId WRITE setNotificationId NOTIFY notificationIdChanged)
	Q_PROPERTY(bool acknowledged READ acknowledged WRITE setAcknowledged NOTIFY acknowledgedChanged)
	Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)
	Q_PROPERTY(int type READ type WRITE setType NOTIFY typeChanged)
	Q_PROPERTY(QDateTime dateTime READ dateTime WRITE setDateTime NOTIFY dateTimeChanged)
	Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged)
	Q_PROPERTY(QString deviceName READ deviceName WRITE setDeviceName NOTIFY deviceNameChanged)
	Q_PROPERTY(QString value READ value WRITE setValue NOTIFY valueChanged)

public:
	int notificationId() const;
	void setNotificationId(int notificationId);

	bool acknowledged() const;
	void setAcknowledged(bool acknowledged);

	bool active() const;
	void setActive(bool active);

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
	void typeChanged();
	void dateTimeChanged();
	void descriptionChanged();
	void deviceNameChanged();
	void valueChanged();

private:
	friend class NotificationsModel;

	int m_notificationId = -1;
	bool m_acknowledged = false;
	bool m_active = false;
	int m_type = -1;
	QDateTime m_dateTime;
	QString m_description;
	QString m_deviceName;
	QString m_value;
};

class NotificationsModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
	enum Role {
		NotificationRole = Qt::UserRole,
	};

	explicit NotificationsModel(QObject *parent = nullptr);

	int count(const QModelIndex& parent = QModelIndex()) const;
	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

	Q_INVOKABLE void insertByDate(Victron::VenusOS::BaseNotification *notification);
	Q_INVOKABLE void removeNotification(int notificationId);
	Q_INVOKABLE void reset();

	void insert(const int index, BaseNotification *newNotification);
	void remove(int index);

signals:
	void countChanged(int);

protected:
	QHash<int, QByteArray> roleNames() const override;

	QVector<QPointer<BaseNotification> > m_data;

private:
	QHash<int, QByteArray> m_roleNames;
};

} /* VenusOS */

} /* Victron */
#endif // NOTIFICATIONSMODEL_H
