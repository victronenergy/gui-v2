/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_ALLSERVICESMODEL_H
#define VICTRON_GUIV2_ALLSERVICESMODEL_H

#include <QAbstractListModel>
#include <QQmlEngine>
#include <QPointer>
#include <qqmlintegration.h>

#include <veutil/qt/ve_qitem.hpp>

namespace Victron {
namespace VenusOS {

/*
	A model of all services that are available on the current backend (D-Bus, MQTT or Mock).
*/
class AllServicesModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON
	Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
	enum Role {
		UidRole = Qt::UserRole,
		ServiceTypeRole
	};
	Q_ENUM(Role)

	int count() const;
	VeQItem *itemAt(int index) const;

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

	Q_INVOKABLE int indexOf(const QString &uid);

	static AllServicesModel* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);

Q_SIGNALS:
	void countChanged();

	// These VeQItem* pointers are owned by the VeQItem producers and should not be deleted.
	void serviceAdded(VeQItem *item);
	void serviceAboutToBeRemoved(VeQItem *item);

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	class ServiceInfo
	{
	public:
		QString serviceType;
		QPointer<VeQItem> item;
	};

	explicit AllServicesModel(QObject *parent);
	void backendProducerChanged();
	void serviceItemDiscovered(VeQItem *item);
	void removeServiceItem(VeQItem *item);
	void addServicesFromChildrenOf(VeQItem *parentItem);
	int indexOf(const QString &uid) const;
	void clear();

	QList<ServiceInfo> m_services;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_ALLSERVICESMODEL_H
