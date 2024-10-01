/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "phasemodel.h"

using namespace Victron::VenusOS;

PhaseModel::PhaseModel(QObject *parent)
	: QAbstractListModel(parent)
{
}

int PhaseModel::count() const
{
	return m_modelCount;
}

int PhaseModel::phaseCount() const
{
	return m_phaseCount;
}

void PhaseModel::setPhaseCount(int phaseCount)
{
	if (phaseCount != m_phaseCount) {
		m_phaseCount = phaseCount;
		resetModel();
		emit phaseCountChanged();
	}
}

bool PhaseModel::l2AndL1OutSummed() const
{
	return m_l2AndL1OutSummed;
}

void PhaseModel::setL2AndL1OutSummed(bool l2AndL1OutSummed)
{
	if (m_l2AndL1OutSummed != l2AndL1OutSummed) {
		m_l2AndL1OutSummed = l2AndL1OutSummed;
		resetModel();
		emit l2AndL1OutSummedChanged();
	}
}

void PhaseModel::setValue(int index, Role role, const qreal value)
{
	if (index < 0) {
		return;
	}

	if (index >= m_phases.count()) {
		m_phases.resize(index + 1, Phase{});
	}

	Phase &phase = m_phases[index];
	switch (role)
	{
	case PowerRole:
		phase.power = value;
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { PowerRole });
		break;
	case CurrentRole:
		phase.current = value;
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { CurrentRole });
		break;
	default:
		break;
	}
}

QVariant PhaseModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();
	if (row < 0 || row >= m_phases.count()) {
		return QVariant();
	}

	const Phase &phase = m_phases.at(row);
	switch (role)
	{
	case NameRole:
		if (m_l2AndL1OutSummed && (row == 0 || row == 1)) {
			return QStringLiteral("L1 + L2");
		} else {
			return QStringLiteral("L%1").arg(row + 1);
		}
	case PowerRole:
		return phase.power;
	case CurrentRole:
		return phase.current;
	default:
		return QVariant();
	}
}

int PhaseModel::rowCount(const QModelIndex &) const
{
	return count();
}

void PhaseModel::resetModel()
{
	const int prevModelCount = count();

	beginResetModel();

	// If l2AndL1OutSummed=true, then there is only one phase, which is a combination of L1+L2.
	// Otherwise, use the phase count from the system as the model count.
	m_modelCount = m_l2AndL1OutSummed ? 1 : m_phaseCount;

	endResetModel();

	if (prevModelCount != count()) {
		emit countChanged();
	}
}

QHash<int, QByteArray> PhaseModel::roleNames() const
{
	static QHash<int, QByteArray> roles = {
		{ NameRole, "name" },
		{ PowerRole, "power" },
		{ CurrentRole, "current" }
	};
	return roles;
}

