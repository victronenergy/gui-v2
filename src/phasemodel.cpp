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

qreal PhaseModel::singlePhaseCurrent() const
{
	return m_singlePhaseCurrent;
}

qreal PhaseModel::singlePhaseVoltage() const
{
	return m_singlePhaseVoltage;
}

// If we have ONLY a single phase with valid data,
// expose its current+voltage via separate properties.
void PhaseModel::updateSinglePhaseData()
{
	qreal current = qQNaN();
	qreal voltage = qQNaN();
	for (const Phase &phase : std::as_const(m_phases)) {
		if (!qIsNaN(phase.current) || !qIsNaN(phase.voltage)) {
			// have valid current and/or voltage data for this phase.
			if (qIsNaN(current) && qIsNaN(voltage)) {
				// we found a phase with valid data, and no prior
				// phases had valid data.  Possibly expose this
				// phase's data as the singlePhase data properties
				// (unless we later find another phase also with data).
				current = phase.current;
				voltage = phase.voltage;
			} else {
				// we already found a phase with valid data,
				// so we do NOT have valid single-phase data
				// (as we cannot sum multiple phases of current/voltage).
				current = qQNaN();
				voltage = qQNaN();
				break;
			}
		}
	}

	if (qIsNaN(current) || qIsNaN(voltage)) {
		if (!qIsNaN(m_singlePhaseCurrent) || !qIsNaN(m_singlePhaseVoltage)) {
			m_singlePhaseCurrent = qQNaN();
			m_singlePhaseVoltage = qQNaN();
			emit singlePhaseCurrentChanged();
			emit singlePhaseVoltageChanged();
		}
	} else {
		if (m_singlePhaseCurrent != current) {
			m_singlePhaseCurrent = current;
			emit singlePhaseCurrentChanged();
		}
		if (m_singlePhaseVoltage != voltage) {
			m_singlePhaseVoltage = voltage;
			emit singlePhaseVoltageChanged();
		}
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
		updateSinglePhaseData();
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { CurrentRole });
		break;
	case VoltageRole:
		phase.voltage = value;
		updateSinglePhaseData();
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { VoltageRole });
		break;
	case EnergyRole:
		phase.energy = value;
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { EnergyRole });
		break;
	default:
		break;
	}
}

QVariantMap PhaseModel::get(int index) const
{
	QVariantMap map;
	static const auto roleNames = this->roleNames();
	for (auto it = roleNames.constBegin(); it != roleNames.constEnd(); ++it) {
		map.insert(it.value(), data(this->index(index, 0), it.key()));
	}
	return map;
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
	case VoltageRole:
		return phase.voltage;
	case EnergyRole:
		return phase.energy;
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

	if (m_modelCount >= m_phases.count()) {
		m_phases.resize(m_modelCount, Phase{});
	}

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
		{ CurrentRole, "current" },
		{ VoltageRole, "voltage" },
		{ EnergyRole, "energy" }
	};
	return roles;
}

