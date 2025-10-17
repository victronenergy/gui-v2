/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_NOTIFICATIONMODEL_H
#define VICTRON_VENUSOS_GUI_V2_NOTIFICATIONMODEL_H

#include <veutil/qt/ve_qitem.hpp>

#include <QQmlEngine>
#include <QAbstractListModel>
#include <QObject>

namespace Victron {

namespace VenusOS {

// Model data entry structure.
// Because it's exposed to QML as a Q_GADGET/ValueType
// it needs to start with a lower-case letter...
class notificationData
{
	Q_GADGET
	QML_ELEMENT

	Q_PROPERTY(QString notificationId MEMBER notificationId FINAL)
	Q_PROPERTY(QString description MEMBER description FINAL)
	Q_PROPERTY(QString deviceName MEMBER deviceName FINAL)
	Q_PROPERTY(QString service MEMBER service FINAL)
	Q_PROPERTY(QString trigger MEMBER trigger FINAL)
	Q_PROPERTY(QVariant alarmValue MEMBER alarmValue FINAL)
	Q_PROPERTY(QVariant value MEMBER value FINAL)
	Q_PROPERTY(qint64 dateTime MEMBER dateTime FINAL)
	Q_PROPERTY(quint32 modelId MEMBER modelId FINAL)
	Q_PROPERTY(int type MEMBER type FINAL)
	Q_PROPERTY(bool acknowledged MEMBER acknowledged FINAL)
	Q_PROPERTY(bool active MEMBER active FINAL)
	Q_PROPERTY(bool silenced MEMBER silenced FINAL)

public:
	QString notificationId; // special: this is the id() of the notification slot associated with this entry.  Not role data.
	QString description;
	QString deviceName;
	QString service;
	QString trigger;
	QVariant alarmValue;
	QVariant value;
	qint64 dateTime = -1;
	quint32 modelId = 0; // special: this is a locally-generated id for this entry.  Used for toast linking etc.
	int type = -1;
	bool acknowledged = true;
	bool active = false;
	bool silenced = true;
};

// Backend object.  Don't expose this to QML.  All QML interactions should go via the model.
class NotificationSlot : public QObject
{
	Q_OBJECT

public:
	explicit NotificationSlot(VeQItem *notification, QObject *parent = nullptr);

	QString notificationId() const { return m_notification ? m_notification->id() : QString(); }
	QString description() const { return m_description ? m_description->getValue().toString() : QString(); }
	QString deviceName() const { return m_deviceName ? m_deviceName->getValue().toString() : QString(); }
	QString service() const { return m_service ? m_service->getValue().toString() : QString(); }
	QString trigger() const { return m_trigger ? m_trigger->getValue().toString() : QString(); }
	QVariant alarmValue() const { return m_alarmValue ? m_alarmValue->getValue() : QString(); }
	QVariant value() const { return m_value ? m_value->getValue() : QString(); }
	qint64 dateTime() const { return m_dateTime ? m_dateTime->getValue().value<qint64>() : -1; }
	int type() const { return m_type ? m_type->getValue().toInt() : -1; }
	bool acknowledged() const { return m_acknowledged ? m_acknowledged->getValue().toInt() > 0 : false; }
	bool active() const { return m_active ? m_active->getValue().toInt() > 0 : false; }
	bool silenced() const { return m_silenced ? m_silenced->getValue().toInt() > 0 : false; }

	Q_INVOKABLE void acknowledge();

Q_SIGNALS:
	// These are the only signals we need.
	// acknowledged, active, and silenced can all change values dynamically,
	// and we need to handle those changes by updating the associated NotificationData entry.
	// description cannot change dynamically, but we need to listen to it to determine
	// when the backend has "finished" setting data for a given notification,
	// as venus platform sets the description last, unfortunately.
	void acknowledgedChanged();
	void activeChanged();
	void silencedChanged();
	void descriptionChanged();

private:
	VeQItem *m_notification = nullptr; // the "index item", parent of the below value items.
	VeQItem *m_description = nullptr;
	VeQItem *m_deviceName = nullptr;
	VeQItem *m_service = nullptr;
	VeQItem *m_trigger = nullptr;
	VeQItem *m_alarmValue = nullptr;
	VeQItem *m_value = nullptr;
	VeQItem *m_dateTime = nullptr;
	VeQItem *m_type = nullptr;
	VeQItem *m_acknowledged = nullptr;
	VeQItem *m_active = nullptr;
	VeQItem *m_silenced = nullptr;
};

// The model of entries, and client-facing API.
class NotificationModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON

	Q_PROPERTY(int count READ rowCount NOTIFY countChanged FINAL)

	Q_PROPERTY(int activeAlarms READ activeAlarms NOTIFY activeAlarmsChanged FINAL)
	Q_PROPERTY(int activeWarnings READ activeWarnings NOTIFY activeWarningsChanged FINAL)
	Q_PROPERTY(int activeInfos READ activeInfos NOTIFY activeInfosChanged FINAL)
	Q_PROPERTY(int unacknowledgedAlarms READ unacknowledgedAlarms NOTIFY unacknowledgedAlarmsChanged FINAL)
	Q_PROPERTY(int unacknowledgedWarnings READ unacknowledgedWarnings NOTIFY unacknowledgedWarningsChanged FINAL)
	Q_PROPERTY(int unacknowledgedInfos READ unacknowledgedInfos NOTIFY unacknowledgedInfosChanged FINAL)

public:
	enum class NotificationRoles {
		Description = Qt::UserRole,
		DeviceName,
		Service,
		Trigger,
		AlarmValue,
		Value,
		DateTime,
		ModelId,
		Type,
		Acknowledged,
		Active,
		Silenced,
		// non-entry data.
		Section
	};
	Q_ENUM(NotificationRoles);

	static NotificationModel* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);
	explicit NotificationModel(QObject *parent);

	QVariant data(const QModelIndex& index, int role) const override;
	int rowCount(const QModelIndex &parent = QModelIndex()) const override;

	int activeAlarms() const { return m_activeAlarms; }
	int activeWarnings() const { return m_activeWarnings; }
	int activeInfos() const { return m_activeInfos; }
	int unacknowledgedAlarms() const { return m_unacknowledgedAlarms; }
	int unacknowledgedWarnings() const { return m_unacknowledgedWarnings; }
	int unacknowledgedInfos() const { return m_unacknowledgedInfos; }

	Q_INVOKABLE void acknowledge(quint32 modelId);
	Q_INVOKABLE void acknowledgeRow(int row);
	Q_INVOKABLE void acknowledgeType(int type);
	Q_INVOKABLE void acknowledgeAllInactive();
	Q_INVOKABLE void acknowledgeAll();

	Q_INVOKABLE bool removeRow(int row);

	notificationData at(int row) const;
	Q_INVOKABLE notificationData get(quint32 modelId) const;

	Q_INVOKABLE int getSection(quint32 modelId) const;

Q_SIGNALS:
	void countChanged();
	void activeAlarmsChanged();
	void activeWarningsChanged();
	void activeInfosChanged();
	void unacknowledgedAlarmsChanged();
	void unacknowledgedWarningsChanged();
	void unacknowledgedInfosChanged();

	// for toasts
	void added(quint32 modelId);
	void changed(quint32 modelId, QList<int> roles);
	void removed(quint32 modelId);

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	void init();
	void watchSlot(VeQItem *slot);
	void unwatchSlot(VeQItem *slot);
	void breakAssociation(NotificationSlot *slot);
	void addAssociatedEntry(NotificationSlot *slot, bool isNew);
	void updateAssociatedEntry(NotificationSlot *slot, NotificationRoles role);
	void handleActiveChanged(NotificationSlot *slot);
	void handleAcknowledgedChanged(NotificationSlot *slot);
	void handleSilencedChanged(NotificationSlot *slot);
	void handleDescriptionChanged(NotificationSlot *slot);
	QHash<int, QByteArray> m_roleNames;
	QVector<notificationData> m_data;
	QVector<NotificationSlot*> m_slots;
	VeQItem *m_notifications = nullptr;
	VeQItem *m_acknowledgeAll = nullptr;
	quint32 m_modelId = 0;
	int m_activeAlarms = 0;
	int m_activeWarnings = 0;
	int m_activeInfos = 0;
	int m_unacknowledgedAlarms = 0;
	int m_unacknowledgedWarnings = 0;
	int m_unacknowledgedInfos = 0;
	int const m_maximumRows = 200;
};

// Toast data.
// Note that not all toasts are Notification-backed toasts,
// they might simply be info toasts raised directly by the UI.
// Thus, they may not have a valid notificationModelId associated.
class toastData
{
	Q_GADGET
	QML_ELEMENT

	Q_PROPERTY(quint32 modelId MEMBER modelId FINAL)
	Q_PROPERTY(quint32 notificationModelId MEMBER notificationModelId FINAL)
	Q_PROPERTY(int type MEMBER type FINAL)
	Q_PROPERTY(QString description MEMBER description FINAL)
	Q_PROPERTY(int autoCloseInterval MEMBER autoCloseInterval FINAL)

public:
	quint32 modelId = 0;
	quint32 notificationModelId = 0;
	int type = -1;
	QString description;
	int autoCloseInterval = -1;
};

// The model of toast entries, and client-facing API.
// Only the first (index zero) toast is visible in the view.
class ToastModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON

	Q_PROPERTY(int count READ rowCount NOTIFY countChanged FINAL)

public:
	enum class ToastRoles {
		ModelId = Qt::UserRole,
		NotificationModelId,
		Type,
		Description,
		AutoCloseInterval
	};
	Q_ENUM(ToastRoles);

	static ToastModel* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);
	explicit ToastModel(QObject *parent);

	QVariant data(const QModelIndex& index, int role) const override;
	int rowCount(const QModelIndex &parent = QModelIndex()) const override;

	Q_INVOKABLE quint32 addNotification(quint32 notificationModelId, int type, const QString &text, int autoCloseInterval = -1);
	Q_INVOKABLE void updateNotification(quint32 notificationModelId, const QString &text);
	Q_INVOKABLE bool removeNotification(quint32 notificationModelId);

	Q_INVOKABLE quint32 add(int type, const QString &text, int autoCloseInterval = -1);
	Q_INVOKABLE bool remove(quint32 modelId);
	Q_INVOKABLE bool removeFirst();
	Q_INVOKABLE bool removeRow(int row);
	Q_INVOKABLE void removeAllInfoExcept(quint32 modelId);

	Q_INVOKABLE void requestDismiss(quint32 modelId);
	Q_INVOKABLE void requestClose(quint32 modelId);

Q_SIGNALS:
	void countChanged();
	void dismissRequested(quint32 modelId);
	void closeRequested(quint32 modelId);
	void removed(quint32 modelId);

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	QVector<toastData> m_data;
	quint32 m_modelId = 0;
};


} /* VenusOS */

} /* Victron */

#endif // VICTRON_VENUSOS_GUI_V2_NOTIFICATIONMODEL_H
