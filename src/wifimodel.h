/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_WIFIMODEL_H
#define VICTRON_GUIV2_WIFIMODEL_H

#include <QAbstractListModel>
#include <qqmlintegration.h>
#include <qsortfilterproxymodel.h>

class VeQItem;

namespace Victron {
namespace VenusOS {

/*
    A model of all wifi networks known to the system. This information
    is sourced from "/Network/Services"

    Following config is provided for each network item:

    "Victron": {
        "Service": "/net/connman/service/wifi_5cc5633c7cfa_56696374726f6e_managed_ieee8021x",
        "State": "Disconnected",
        ...
        "Mac": "5C:C5:63:3C:7C:FA",
        "Nameservers": ["193.12.34.56", "193.12.34.57"]
    }
*/
class WifiModel : public QAbstractListModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(bool valid READ valid NOTIFY validChanged FINAL)
	Q_PROPERTY(QString connectedNetworkName READ connectedNetworkName NOTIFY connectedNetworkNameChanged FINAL)

public:
	enum Role {
		NetworkRole = Qt::UserRole,
		ServiceRole,
		StateRole,
		FavoriteRole,
		StrengthRole
	};
	Q_ENUM(Role)

	explicit WifiModel(QObject *parent = nullptr);

	bool valid() const;
	QString connectedNetworkName() const;

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex &index, int role) const override;

Q_SIGNALS:
	void validChanged();
	void connectedNetworkNameChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	struct WifiNetwork {
		QString network;
		QString service;
		QString state;
		bool favorite = false;
		int strength = 0;
	};

	void update();
	void updateConnectedNetworkName();

	VeQItem *m_servicesItem = nullptr;
	VeQItem *m_scanItem = nullptr;
	VeQItem *m_accessPointItem = nullptr;
	QList<WifiNetwork> m_networks;
	bool m_valid = false;
	QString m_connectedNetworkName;
};


/*
    Provides a sorted WifiModel.
*/
class SortedWifiModel : public QSortFilterProxyModel
{
	Q_OBJECT
	QML_ELEMENT
public:
	explicit SortedWifiModel(QObject *parent = nullptr);

protected:
	bool lessThan(const QModelIndex &leftIndex, const QModelIndex &rightIndex) const override;
};


} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_WIFIMODEL_H
