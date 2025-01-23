/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "solarinputmodel.h"

using namespace Victron::VenusOS;

SolarInputModel::SolarInputModel(QObject *parent)
	: QAbstractListModel(parent)
{
}

int SolarInputModel::count() const
{
	return m_inputs.count();
}

int SolarInputModel::insertionIndex(const Input &input) const
{
	for (int i = 0; i < m_inputs.count(); ++i) {
		if (m_inputs.at(i).group > input.group) {
			return i;
		} else if (m_inputs.at(i).group == input.group) {
			if (m_inputs.at(i).name.localeAwareCompare(input.name) > 0) {
				return i;
			}
		}
	}
	return m_inputs.count();
}

void SolarInputModel::addInput(const QString &serviceUid, const QVariantMap &values, int trackerIndex)
{
	const int removalIndex = indexOf(serviceUid, trackerIndex);
	if (removalIndex >= 0) {
		// The input is already in the list, so remove and and re-insert it, to preserve the sort
		// order without re-sorting the entire list.
		removeAt(removalIndex);
	}

	Input input = {
		.serviceUid = serviceUid,
		.group = values["group"].toString(),
		.name = values["name"].toString(),
		.todaysYield = values["todaysYield"].value<qreal>(),
		.energy = values["energy"].value<qreal>(),
		.power = values["power"].value<qreal>(),
		.current = values["current"].value<qreal>(),
		.voltage = values["voltage"].value<qreal>(),
		.trackerIndex = trackerIndex,
	};

	// Add the input in a sorted order, based on the name and group.
	const int index = insertionIndex(input);
	beginInsertRows(QModelIndex(), index, index);
	m_inputs.insert(index, input);
	endInsertRows();
	emit countChanged();
}

void SolarInputModel::setInputValue(const QString &serviceUid, Role role, const QVariant &value, int trackerIndex)
{
	const int index = indexOf(serviceUid, trackerIndex);
	if (index < 0) {
		return;
	}

	Input &input = m_inputs[index];
	switch (role)
	{
	case ServiceUidRole:
		qWarning() << "serviceUid is read-only";
		break;
	case GroupRole:
		input.group = value.toString();
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { GroupRole });
		break;
	case NameRole:
		input.name = value.toString();
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { NameRole });
		break;
	case TodaysYieldRole:
		input.todaysYield = value.value<qreal>();
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { TodaysYieldRole });
		break;
	case EnergyRole:
		input.energy = value.value<qreal>();
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { EnergyRole });
		break;
	case PowerRole:
		input.power = value.value<qreal>();
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { PowerRole });
		break;
	case CurrentRole:
		input.current = value.value<qreal>();
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { CurrentRole });
		break;
	case VoltageRole:
		input.voltage = value.value<qreal>();
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { VoltageRole });
		break;
	default:
		break;
	}
}

int SolarInputModel::indexOf(const QString &serviceUid, int trackerIndex) const
{
	for (int i = 0; i < m_inputs.count(); ++i) {
		const Input &input = m_inputs.at(i);
		if (input.serviceUid == serviceUid && input.trackerIndex == trackerIndex) {
			return i;
		}
	}
	return -1;
}

void SolarInputModel::removeAt(int index)
{
	if (index >= 0 && index < count()) {
		beginRemoveRows(QModelIndex(), index, index);
		m_inputs.removeAt(index);
		endRemoveRows();
		emit countChanged();
	}
}

QVariant SolarInputModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();
	if (row < 0 || row >= m_inputs.count()) {
		return QVariant();
	}

	const Input &input = m_inputs.at(row);
	switch (role)
	{
	case ServiceUidRole:
		return input.serviceUid;
	case GroupRole:
		return input.group;
	case NameRole:
		return input.name;
	case TodaysYieldRole:
		return input.todaysYield;
	case EnergyRole:
		return input.energy;
	case PowerRole:
		return input.power;
	case CurrentRole:
		return input.current;
	case VoltageRole:
		return input.voltage;
	default:
		return QVariant();
	}
}

int SolarInputModel::rowCount(const QModelIndex &) const
{
	return count();
}

QHash<int, QByteArray> SolarInputModel::roleNames() const
{
	static QHash<int, QByteArray> roles = {
		{ ServiceUidRole, "serviceUid" },
		{ GroupRole, "group" },
		{ NameRole, "name" },
		{ TodaysYieldRole, "todaysYield" },
		{ EnergyRole, "energy" },
		{ PowerRole, "power" },
		{ CurrentRole, "current" },
		{ VoltageRole, "voltage" },
	};
	return roles;
}
