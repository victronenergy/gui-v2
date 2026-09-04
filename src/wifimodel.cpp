/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "wifimodel.h"
#include "backendconnection.h"

#include <veutil/qt/ve_qitem.hpp>

#include <QCoreApplication>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>

using namespace Victron::VenusOS;

WifiModel::WifiModel(QObject *parent)
	: QAbstractListModel(parent)
{
	const QString serviceUid = BackendConnection::create()->serviceUidForType(QStringLiteral("platform"));

	m_servicesItem = VeQItems::getRoot()->itemGetOrCreate(serviceUid + QStringLiteral("/Network/Services"));
	m_scanItem = VeQItems::getRoot()->itemGetOrCreate(serviceUid + QStringLiteral("/Network/Wifi/Scan"));
	m_accessPointItem = VeQItems::getRoot()->itemGetOrCreate(serviceUid + QStringLiteral("/Services/AccessPoint/Enabled"));

	m_servicesItem->getValueAndChanges(this, &WifiModel::update);
	m_scanItem->getValueAndChanges(this, &WifiModel::update);
	m_accessPointItem->getValueAndChanges(this, &WifiModel::update);
}

bool WifiModel::valid() const
{
	return m_valid;
}

QString WifiModel::connectedNetworkName() const
{
	return m_connectedNetworkName;
}

int WifiModel::rowCount(const QModelIndex &) const
{
	return m_networks.count();
}

QVariant WifiModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();

	if (row < 0 || row >= m_networks.count()) {
		return QVariant();
	}

	const WifiNetwork &wifiNetwork = m_networks.at(row);
	switch (role) {
	case NetworkRole:
		return wifiNetwork.network;
	case ServiceRole:
		return wifiNetwork.service;
	case StateRole:
		return wifiNetwork.state;
	case FavoriteRole:
		return wifiNetwork.favorite;
	case StrengthRole:
		return wifiNetwork.strength;
	default:
		return QVariant();
	}
}

QHash<int, QByteArray> WifiModel::roleNames() const
{
	static const QHash<int, QByteArray> roles = {
		{ NetworkRole, "network" },
		{ ServiceRole, "service" },
		{ StateRole, "state" },
		{ FavoriteRole, "favorite" },
		{ StrengthRole, "strength" }
	};
	return roles;
}

void WifiModel::update()
{
	const bool wasValid = m_valid;
	m_valid = m_servicesItem->getValue().isValid() && m_scanItem->getValue().isValid();
	if (wasValid != m_valid) {
		emit validChanged();
	}

	if (!m_valid) {
		if (!m_networks.isEmpty()) {
			beginResetModel();
			m_networks.clear();
			endResetModel();
		}
		updateConnectedNetworkName();
		return;
	}

	/*
		Following config is provided for each network item:

		"Victron": {
			"Service": "/net/connman/service/wifi_5cc5633c7cfa_56696374726f6e_managed_ieee8021x",
			"State": "Disconnected",
			"Strength": "45",
			"Secured": "yes",
			"Favorite": "yes",
			"Address": "192.168.68.62",
			"Gateway": "",
			"Method": "manual",
			"Netmask": "255.255.252.0",
			"Mac": "5C:C5:63:3C:7C:FA",
			"Nameservers": ["193.12.34.56", "193.12.34.57"]
		}
	*/
	QJsonParseError parseError;
	const QJsonDocument doc = QJsonDocument::fromJson(m_servicesItem->getValue().toString().toUtf8(), &parseError);
	if (parseError.error != QJsonParseError::NoError || !doc.isObject()) {
		return;
	}
	const QJsonObject wifis = doc.object().value(QStringLiteral("wifi")).toObject();

	// Remove networks that have been dropped.
	QStringList services;
	for (auto it = wifis.constBegin(); it != wifis.constEnd(); ++it) {
		if (it.value().isObject()) {
			services.append(it.value().toObject().value(QStringLiteral("Service")).toString());
		}
	}
	for (int i = m_networks.count() - 1; i >= 0; --i) {
		if (!services.contains(m_networks.at(i).service)) {
			beginRemoveRows(QModelIndex(), i, i);
			m_networks.removeAt(i);
			endRemoveRows();
		}
	}

	// Update existing networks, and insert newly discovered networks.
	for (auto it = wifis.constBegin(); it != wifis.constEnd(); ++it) {
		const QString network = it.key();
		const QJsonObject details = it.value().toObject();
		const QString service = details.value(QStringLiteral("Service")).toString();
		const int strength = details.value(QStringLiteral("Strength")).toVariant().toInt();

		bool found = false;
		for (int j = 0; j < m_networks.count(); ++j) {
			if (!service.isEmpty() && service == m_networks.at(j).service) {
				found = true;
				m_networks[j].network = network;
				m_networks[j].state = details.value(QStringLiteral("State")).toString();
				m_networks[j].favorite = details.value(QStringLiteral("Favorite")).toString() == QStringLiteral("yes");
				m_networks[j].strength = strength;
				emit dataChanged(index(j), index(j), { NetworkRole, StateRole, FavoriteRole, StrengthRole });
				break;
			}
		}

		if (!found) {
			const int insertPos = m_networks.count();
			beginInsertRows(QModelIndex(), insertPos, insertPos);
			m_networks.insert(insertPos, WifiNetwork {
				network,
				service,
				details.value(QStringLiteral("State")).toString(),
				details.value(QStringLiteral("Favorite")).toString() == QStringLiteral("yes"),
				strength
			});
			endInsertRows();
		}
	}

	updateConnectedNetworkName();
}

void WifiModel::updateConnectedNetworkName()
{
	QString name;
	bool found = false;
	for (const WifiNetwork &wifiNetwork : std::as_const(m_networks)) {
		if (wifiNetwork.state == QStringLiteral("ready") || wifiNetwork.state == QStringLiteral("online")) {
			name = wifiNetwork.network;
			found = true;
			break;
		}
	}

	if (!found) {
		if (m_accessPointItem->getValue().isValid()) {
			name = m_accessPointItem->getValue().toInt() == 1
				//% "Disconnected | AP On"
				? qtTrId("wifimodel_disconnected_ap_on")
				//% "Disconnected | AP Off"
				: qtTrId("wifimodel_disconnected_ap_off");
		} else {
			//% "Disconnected"
			name = qtTrId("wifimodel_disconnected");
		}
	}

	if (name != m_connectedNetworkName) {
		m_connectedNetworkName = name;
		emit connectedNetworkNameChanged();
	}
}

SortedWifiModel::SortedWifiModel(QObject *parent)
	: QSortFilterProxyModel(parent)
{
	sort(0, Qt::DescendingOrder);
}

bool SortedWifiModel::lessThan(const QModelIndex &leftIndex, const QModelIndex &rightIndex) const
{
	// Sort by:
	// 1. Connection status (connected first)
	// 2. Signal strength (strongest first)

	const bool isLeftConnected = (sourceModel()->data(leftIndex, WifiModel::StateRole).toString() == QStringLiteral("ready"))
			|| (sourceModel()->data(leftIndex, WifiModel::StateRole).toString() == QStringLiteral("online"));
	const bool isRightConnected = (sourceModel()->data(rightIndex, WifiModel::StateRole).toString() == QStringLiteral("ready"))
			|| (sourceModel()->data(rightIndex, WifiModel::StateRole).toString() == QStringLiteral("online"));

	if (isLeftConnected != isRightConnected) {
		return isRightConnected;
	}

	const int leftStrength = sourceModel()->data(leftIndex, WifiModel::StrengthRole).toInt();
	const int rightStrength = sourceModel()->data(rightIndex, WifiModel::StrengthRole).toInt();

	return leftStrength < rightStrength;
}
