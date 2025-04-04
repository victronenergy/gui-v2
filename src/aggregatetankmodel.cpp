/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "aggregatetankmodel.h"
#include "aggregatedevicemodel.h"

#include <QQmlInfo>

using namespace Victron::VenusOS;


AggregateTankModel::AggregateTankModel(QObject *parent)
	: QAbstractListModel(parent),
	m_model(new AggregateDeviceModel(this))
{
	m_model->setRetainDevices(false);
	m_model->setSortBy(AggregateDeviceModel::SortBySourceModel | AggregateDeviceModel::SortByDeviceName);
	connect(m_model, &AggregateDeviceModel::modelReset, this, &AggregateTankModel::reload);
	connect(m_model, &AggregateDeviceModel::rowsInserted, this, &AggregateTankModel::modelRowsInserted);
	connect(m_model, &AggregateDeviceModel::rowsAboutToBeRemoved, this, &AggregateTankModel::modelRowsAboutToBeRemoved);
	connect(m_model, &AggregateDeviceModel::rowsAboutToBeMoved, this, &AggregateTankModel::modelRowsAboutToBeMoved);

	m_roleNames[IsGroupRole] = "isGroup";
	m_roleNames[TankRole] = "tank";
	m_roleNames[TankModelRole] = "tankModel";
}

AggregateTankModel::~AggregateTankModel()
{
}

QVariantList AggregateTankModel::tankModels() const
{
	return m_model->sourceModels();
}

void AggregateTankModel::setTankModels(const QVariantList &models)
{
	m_model->setSourceModels(models);
	emit tankModelsChanged();
}

int AggregateTankModel::count() const
{
	return static_cast<int>(m_entries.count());
}

int AggregateTankModel::mergeThreshold() const
{
	return m_mergeThreshold;
}

void AggregateTankModel::setMergeThreshold(int mergeThreshold)
{
	if (m_mergeThreshold != mergeThreshold) {
		m_mergeThreshold = mergeThreshold;
		reload();
		emit mergeThresholdChanged();
	}
}

QVariant AggregateTankModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();
	if (row < 0 || row >= m_entries.count()) {
		return QVariant();
	}
	const Entry& entry = m_entries.at(row);
	switch (role)
	{
	case IsGroupRole:
		return entry.isGroup;
	case TankRole:
		return QVariant::fromValue<BaseTankDevice *>(entry.tank.data());
	case TankModelRole:
		return QVariant::fromValue<BaseTankDeviceModel *>(entry.tankModel.data());
	default:
		return QVariant();
	}
}

int AggregateTankModel::rowCount(const QModelIndex &) const
{
	return static_cast<int>(m_entries.count());
}

QHash<int, QByteArray> AggregateTankModel::roleNames() const
{
	return m_roleNames;
}

BaseTankDevice *AggregateTankModel::tankAt(int index) const
{
	if (index < 0 || index >= m_entries.count()) {
		return nullptr;
	}
	return m_entries.at(index).tank;
}

BaseTankDeviceModel *AggregateTankModel::tankModelAt(int index) const
{
	if (index < 0 || index >= m_entries.count()) {
		return nullptr;
	}
	return m_entries.at(index).tankModel;
}

void AggregateTankModel::reload()
{
	const bool wasEmpty = count() == 0;
	beginResetModel();

	m_entries.clear();

	if (m_model->count() == 0) {
		// Nothing to do here
	} else if (m_mergeThreshold == 0 || m_model->count() < m_mergeThreshold) {
		// The total number of tanks is less than the merge threshold, so merging is not required.
		for (int i = 0; i < m_model->count(); ++i) {
			m_entries.append({
				qobject_cast<BaseTankDevice*>(m_model->deviceAt(i)),
				qobject_cast<BaseTankDeviceModel*>(m_model->sourceModelAt(i)),
				false
			});
		}
	} else {
		int entryCountIfMerged = m_model->count();
		bool belowMergeThreshold = false;
		const QVariantList tankModels = m_model->sourceModels();
		for (const QVariant &modelVariant : tankModels) {
			if (BaseTankDeviceModel *tankModel = modelVariant.value<BaseTankDeviceModel*>()) {
				if (tankModel->count() == 0) {
					continue;
				}
				if (tankModel->count() > 1 && !belowMergeThreshold) {
					// There are multiple tanks, so merge the tanks of this type into a single entry.
					entryCountIfMerged = entryCountIfMerged - tankModel->count() + 1;
					m_entries.append({ nullptr, tankModel, true});

					if (entryCountIfMerged < m_mergeThreshold) {
						// Have merged into enough groups to fall below the merge threshold reached,
						// so do not merge any more tanks.
						belowMergeThreshold = true;
					}
				} else {
					// Add all tanks from this tank model into the aggregate model.
					for (int i = 0; i < tankModel->count(); ++i) {
						m_entries.append({ tankModel->tankAt(i), tankModel, false});
					}
				}
			}
		}
	}

	endResetModel();
	if (wasEmpty) {
		emit countChanged();
	}
}

int AggregateTankModel::insertionIndex(const Entry &entry) const
{
	int index = m_entries.count();
	for (int i = 0; i < m_entries.count(); ++i) {
		if (lessThan(entry, m_entries[i])) {
			index = i;
			break;
		}
	}
	return index;
}

bool AggregateTankModel::lessThan(const Entry &a, const Entry &b) const
{
	const int modelAIndex = m_model->sourceModels().indexOf(QVariant::fromValue<BaseTankDeviceModel *>(a.tankModel));
	const int modelBIndex = a.tankModel == b.tankModel
			? modelAIndex
			: m_model->sourceModels().indexOf(QVariant::fromValue<BaseTankDeviceModel *>(b.tankModel));
	if (modelAIndex < modelBIndex) {
		return true;
	} else if (modelAIndex == modelBIndex) {
		const QString tankAName = a.tank ? a.tank->name() : QString();
		const QString tankBName = b.tank ? b.tank->name() : QString();
		return tankAName.localeAwareCompare(tankBName) < 0;
	} else {
		return false;
	}
}

int AggregateTankModel::indexOfTankOrGroup(BaseTankDevice *tank, BaseTankDeviceModel *tankModel) const
{
	for (int i = 0; i < m_entries.count(); ++i) {
		if (m_entries[i].tankModel && m_entries[i].tankModel == tankModel) {
			if (m_entries[i].isGroup) {
				// The tanks for this model have been merged into a single group, so return the
				// index of the group.
				return i;
			} else if (m_entries[i].tank == tank) {
				return i;
			}
		}
	}
	return -1;
}

/*
	Using the tank type at the given index, returns the index of the last consecutive entry that has
	the same tank type.
*/
int AggregateTankModel::indexOfLastConsecutiveTankType(int fromIndex) const
{
	int consecutiveMatches = 0;
	if (fromIndex >= 0 && fromIndex < m_entries.count() && m_entries[fromIndex].tankModel) {
		const int typeToMatch = m_entries[fromIndex].tankModel->type();
		for (int i = fromIndex + 1; i < m_entries.count(); ++i) {
			if (m_entries[i].tankModel && m_entries[i].tankModel->type() == typeToMatch) {
				consecutiveMatches++;
			} else {
				break;
			}
		}
	}
	return fromIndex + consecutiveMatches;
}

void AggregateTankModel::convertToGroup(int index)
{
	if (index >= 0 && index < m_entries.count()) {
		m_entries[index].isGroup = true;
		m_entries[index].tank.clear();
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { TankRole, IsGroupRole });
	}
}

void AggregateTankModel::convertToNonGroup(int index, BaseTankDevice *tank)
{
	if (index >= 0 && index < m_entries.count()) {
		m_entries[index].isGroup = false;
		m_entries[index].tank = tank;
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { TankRole, IsGroupRole });
	}
}

void AggregateTankModel::modelRowsInserted(const QModelIndex &, int first, int last)
{
	for (int i = first; i <= last; ++i) {
		modelTankAdded(qobject_cast<BaseTankDevice*>(m_model->deviceAt(i)),
				 qobject_cast<BaseTankDeviceModel*>(m_model->sourceModelAt(i)));
	}
}

void AggregateTankModel::modelTankAdded(BaseTankDevice *tank, BaseTankDeviceModel *tankModel)
{
	for (int i = 0; i < m_entries.count(); ++i) {
		if (m_entries[i].isGroup
				&& m_entries[i].tankModel
				&& m_entries[i].tankModel->type() == tank->type()) {
			// The new tank belongs to an existing merge group, so no model changes are necessary.
			return;
		}
	}

	int prevCount = count();
	bool needsTankInsertion = true;
	if (m_mergeThreshold != 0 && m_entries.count() + 1 >= m_mergeThreshold) {
		// Merging is required; find a tank type that can be merged into a group. Note that only one
		// set of tanks needs to be merged for the model to fall under the merge threshold, because
		// only one tank is being added.
		for (int i = 0; i < m_entries.count(); ++i) {
			if (m_entries[i].tankModel && !m_entries[i].isGroup) {
				const int lastConsecutiveTypeIndex = indexOfLastConsecutiveTankType(i);
				if (lastConsecutiveTypeIndex > i) {
					// Found a set of consecutive entries of the same tank type. Merge these into a
					// single group, by converting this entry into a group, and removing the
					// following entries of the same tank type.
					const int removalIndex = i + 1;
					const int removalCount = lastConsecutiveTypeIndex - removalIndex + 1;
					beginRemoveRows(QModelIndex(), removalIndex, removalIndex + removalCount - 1);
					m_entries.remove(removalIndex, removalCount);
					endRemoveRows();
					convertToGroup(i);
					if (m_entries[i].tankModel->type() == tank->type()) {
						// If the new tank belongs to this group, it does not need to be added as a
						// separate entry.
						needsTankInsertion = false;
					}
					break;
				} else if (m_entries[i].tankModel->type() == tank->type()) {
					// This entry has the same type as the new tank, thus adding the new tank would
					// create a set of consecutive entries; so, convert this entry into a group.
					convertToGroup(i);
					needsTankInsertion = false;
					break;
				}
			}
		}
	}

	if (needsTankInsertion) {
		Entry newEntry = { tank, tankModel, false };
		const int newEntryIndex = insertionIndex(newEntry);
		beginInsertRows(QModelIndex(), newEntryIndex, newEntryIndex);
		m_entries.insert(newEntryIndex, newEntry);
		endInsertRows();
	}

	if (prevCount != count()) {
		emit countChanged();
	}
}

void AggregateTankModel::modelRowsAboutToBeRemoved(const QModelIndex &, int first, int last)
{
	for (int i = last; i >= first; --i) {
		modelAboutToRemoveTank(qobject_cast<BaseTankDevice*>(m_model->deviceAt(i)),
							   qobject_cast<BaseTankDeviceModel*>(m_model->sourceModelAt(i)));
	}
}

void AggregateTankModel::modelAboutToRemoveTank(BaseTankDevice *tankToRemove, BaseTankDeviceModel *tankModelToRemove)
{
	if (!tankToRemove || !tankModelToRemove) {
		qmlWarning(this) << "Cannot remove entry, invalid tankToRemove or model!";
		return;
	}

	const int entryIndex = indexOfTankOrGroup(tankToRemove, tankModelToRemove);
	if (entryIndex < 0) {
		qWarning() << "Entry not found! Cannot remove tankToRemove" << tankToRemove << "and model" << tankModelToRemove;
		return;
	}

	const int prevCount = count();

	// Remove the tankToRemove from the group or index.
	if (m_entries[entryIndex].isGroup) {
		if (m_entries[entryIndex].tankModel && m_entries[entryIndex].tankModel->count() <= 2) {
			// There will only be one tankToRemove left in the group. Convert the entry into a non-group,
			// using the remaining tank.
			for (int i = 0; i < m_model->count(); ++i) {
				if (m_model->sourceModelAt(i) == tankModelToRemove && m_model->deviceAt(i) != tankToRemove) {
					BaseTankDevice *remainingTank = qobject_cast<BaseTankDevice*>(m_model->deviceAt(i));
					convertToNonGroup(entryIndex, remainingTank);
					break;
				}
			}
		}
	} else {
		beginRemoveRows(QModelIndex(), entryIndex, entryIndex);
		m_entries.remove(entryIndex);
		endRemoveRows();
	}

	// Starting from the end of the list, if a group can be separated and the model would still
	// be under the threshold, then do the separation.
	for (int i = m_entries.count() - 1; i >= 0; --i) {
		if (!m_entries[i].isGroup || !m_entries[i].tankModel) {
			continue;
		}
		const int tankModelCount = m_entries[i].tankModel == tankModelToRemove
				? m_entries[i].tankModel->count() - 1   // account for tank that is about to be removed
				: m_entries[i].tankModel->count();
		const int modelCountIfMerged = m_entries.count()
				+ tankModelCount
				- 1; // account for the group entry that will disappear
		if (modelCountIfMerged < m_mergeThreshold) {
			BaseTankDeviceModel *groupModel = m_entries[i].tankModel;
			BaseTankDevice *firstTank = nullptr;

			QList<Entry> subsequentTanks;
			for (int tankModelIndex = 0; tankModelIndex < groupModel->count(); ++tankModelIndex) {
				BaseTankDevice *tank = groupModel->tankAt(tankModelIndex);
				if (tank != tankToRemove) {
					if (!firstTank) {
						firstTank = tank;
					} else {
						subsequentTanks.append({ tank, groupModel });
					}
				}
			}

			// Use the first tank to convert the existing group entry into a non-group entry, then
			// insert the subsequent tanks as new entries to this model.
			if (firstTank) {
				convertToNonGroup(i, firstTank);
			}
			if (subsequentTanks.count() > 0) {
				int start = i + 1;
				beginInsertRows(QModelIndex(), start, start + subsequentTanks.count() - 1);
				for (const Entry &entry : subsequentTanks) {
					m_entries.insert(start++, entry);
				}
				endInsertRows();
			}

			if (m_entries.count() == m_mergeThreshold - 1) {
				// Doing further group separations would go over the threshold, so stop here.
				break;
			}
		}
	}

	if (count() != prevCount) {
		emit countChanged();
	}
}

void AggregateTankModel::modelRowsAboutToBeMoved(const QModelIndex &, int sourceStart, int sourceEnd, const QModelIndex &, int destinationRow)
{
	if (sourceStart != sourceEnd) {
		// Normally only a single row will be moved, due to a device being renamed. If multiple
		// moves have occurred, reload the model.
		reload();
		return;
	}

	BaseTankDevice *movedTank = qobject_cast<BaseTankDevice *>(m_model->deviceAt(sourceStart));
	BaseTankDeviceModel *movedTankModel = qobject_cast<BaseTankDeviceModel *>(m_model->sourceModelAt(sourceStart));
	const int fromIndex = indexOfTankOrGroup(movedTank, movedTankModel);
	if (fromIndex < 0 || fromIndex >= m_entries.count()) {
		qWarning() << "Cannot find moved tank and model!";
		return;
	}

	if (m_entries[fromIndex].isGroup) {
		// The tank that was moved is inside a group, so no action is needed.
		return;
	}

	const int moveBy = destinationRow - sourceStart;
	const int toIndex = fromIndex + moveBy;
	beginMoveRows(QModelIndex(), fromIndex, fromIndex, QModelIndex(), toIndex);
	m_entries.move(fromIndex, toIndex > fromIndex ? toIndex - 1 : toIndex);
	endMoveRows();
}
