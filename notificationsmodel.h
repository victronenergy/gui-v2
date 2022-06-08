#ifndef NOTIFICATIONSMODEL_H
#define NOTIFICATIONSMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QSortFilterProxyModel>
#include <QDateTime>
#include <QVariantList>
#include "enums.h"

namespace Victron {

namespace VenusOS {

class QQmlEngine;
class QJSEngine;
class Notification
{
public:
	Notification();
	Notification(const Notification& other);
	Notification(const bool acknowledged,
				 const bool active,
				 const Enums::Notification_Type type,
				 const QString &deviceName,
				 const QDateTime& dateTime,
				 const QString &description);
	bool acknowledged() const;
	void setAcknowledged(const bool acknowledged);
	bool active() const;
	void setActive(const bool active);
	Enums::Notification_Type type() const;
	void setType(Enums::Notification_Type type);
	QString serviceName() const;
	void setServiceName(const QString service);
	QDateTime dateTime() const;
	void setDateTime(const QDateTime date);
	QString description() const;
	void setDescription(const QString description);
	QString value() const;
	void setValue(const QString &value);

private:
	bool m_acknowledged;
	bool m_active;
	Enums::Notification_Type m_type;
	QString m_deviceName;
	QDateTime m_dateTime;
	QString m_description;
	QString m_value;
};

class NotificationsModel : public QAbstractListModel
{
	Q_OBJECT
	Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
	enum RoleNames {
		AcknowledgedRole = Qt::UserRole,
		ActiveRole,
		TypeRole,
		ServiceRole,
		DateTimeRole,
		DescriptionRole,
		ValueRole
	};

	virtual ~NotificationsModel() override = 0;

	virtual int count(const QModelIndex& parent = QModelIndex()) const;
	virtual int rowCount(const QModelIndex &parent) const override;
	virtual QVariant data(const QModelIndex& index, int role) const override;

	void insertByDate(const Victron::VenusOS::Notification& newNotification);
	Q_INVOKABLE void deactivateSingleAlarm(); // testing only
	Q_INVOKABLE void insertByDate(bool acknowledged,
							const bool active,
							const Enums::Notification_Type type,
							const QString &deviceName,
							const QDateTime& dateTime,
							const QString &description);
	Q_INVOKABLE void remove(int index);
	Q_INVOKABLE void reset();
	void insert(const int index, const Victron::VenusOS::Notification& newNotification);
	void append(const Victron::VenusOS::Notification& notification);

signals:
	void countChanged(int);

protected:
	explicit NotificationsModel(QObject *parent = nullptr);
	virtual QHash<int, QByteArray> roleNames() const override;

	QList<Notification>  m_data;
	const int m_maxNotifications;

private:
	QHash<int, QByteArray> m_roleNames;
};

class ActiveNotificationsModel : public NotificationsModel
{
	Q_OBJECT
	Q_PROPERTY(bool newNotifications READ newNotifications NOTIFY newNotificationsChanged) // when true, we display a red dot on the 'notifications' button in the nav bar
public:

	~ActiveNotificationsModel() override;
	static ActiveNotificationsModel* instance(QObject* parent = nullptr);
	virtual bool setData(const QModelIndex &index, const QVariant &value, int role) override;
	bool newNotifications() const;

public slots:
	void handleChanges();

signals:
	void newNotificationsChanged();

protected:
	explicit ActiveNotificationsModel(QObject *parent = nullptr);

private:
	void setNewNotifications(const bool newNotifications);
	bool m_newNotifications;
};

class HistoricalNotificationsModel : public NotificationsModel
{
	Q_OBJECT
public:
	~HistoricalNotificationsModel() override;
	static HistoricalNotificationsModel* instance(QObject* parent = nullptr);
	virtual bool setData(const QModelIndex &index, const QVariant &value, int role) override;

protected:
	explicit HistoricalNotificationsModel(QObject *parent = nullptr);
};

} /* VenusOS */

} /* Victron */
#endif // NOTIFICATIONSMODEL_H
