/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "combinedlistmodel.h"

#include <QQmlInfo>

#include <algorithm>

using namespace Victron::VenusOS;

CombinedListModel::CombinedListModel(QObject *parent)
	: QAbstractListModel(parent)
{
	updateRoles();
}

QAbstractItemModel *CombinedListModel::firstModel() const
{
	return m_first.model;
}

void CombinedListModel::setFirstModel(QAbstractItemModel *model)
{
	if (m_first.model != model) {
		setModel(m_first, model);
		emit firstModelChanged();
	}
}

QAbstractItemModel *CombinedListModel::secondModel() const
{
	return m_second.model;
}

void CombinedListModel::setSecondModel(QAbstractItemModel *model)
{
	if (m_second.model != model) {
		setModel(m_second, model);
		emit secondModelChanged();
	}
}

int CombinedListModel::count() const
{
	return m_first.rowCount + m_second.rowCount;
}

int CombinedListModel::rowCount(const QModelIndex &parent) const
{
	return parent.isValid() ? 0 : count();
}

QVariant CombinedListModel::data(const QModelIndex &index, int role) const
{
	if (!checkIndex(index, CheckIndexOption::IndexIsValid | CheckIndexOption::ParentIsInvalid)) {
		return QVariant();
	}

	const bool fromSecondModel = index.row() >= m_first.rowCount;
	if (role == FromSecondModelRole) {
		return fromSecondModel;
	}

	const Source &source = fromSecondModel ? m_second : m_first;
	const auto sourceRole = source.roles.constFind(role);
	if (!source.model || sourceRole == source.roles.constEnd()) {
		return QVariant();
	}
	return source.model->data(source.model->index(index.row() - rowOffset(source), 0), *sourceRole);
}

QHash<int, QByteArray> CombinedListModel::roleNames() const
{
	return m_roleNames;
}

void CombinedListModel::setModel(Source &source, QAbstractItemModel *model)
{
	const int oldCount = count();
	const bool modelsWereSame = modelsAreSame();
	beginResetModel();
	source.model = model;
	reconnectModel(source);
	if (&source == &m_first && modelsAreSame() != modelsWereSame) {
		reconnectModel(m_second);
	}
	updateRoles();
	endResetModel();
	if (count() != oldCount) {
		emit countChanged();
	}
}

bool CombinedListModel::modelsAreSame() const
{
	return m_second.model && m_second.model == m_first.model;
}

void CombinedListModel::reconnectModel(Source &source)
{
	for (const QMetaObject::Connection &connection : std::as_const(source.connections)) {
		disconnect(connection);
	}
	source.connections.clear();
	source.rowCount = 0;
	source.layoutChange = LayoutChange::None;
	if (!source.model) {
		return;
	}

	if (&source == &m_second && modelsAreSame()) {
		// Each change to the model would start a change to the rows of both models before either
		// one ends, which cannot be passed on correctly. So the rows of the second model are left
		// out while it is the same as the first model. secondModel is still cleared if the model
		// is destroyed.
		qmlWarning(this) << "firstModel and secondModel are the same model, so its rows are only included once";
		source.connections = {
			connect(source.model, &QObject::destroyed, this, [this, &source]() {
				sourceDestroyed(source);
			}),
		};
		return;
	}

	source.rowCount = source.model->rowCount();
	connectModel(source);
}

void CombinedListModel::connectModel(Source &source)
{
	QAbstractItemModel *model = source.model;
	source.connections = {
		connect(model, &QAbstractItemModel::rowsAboutToBeInserted, this,
				[this, &source](const QModelIndex &parent, int first, int last) {
			sourceRowsAboutToBeInserted(source, parent, first, last);
		}),
		connect(model, &QAbstractItemModel::rowsInserted, this,
				[this, &source](const QModelIndex &parent, int first, int last) {
			sourceRowsInserted(source, parent, first, last);
		}),
		connect(model, &QAbstractItemModel::rowsAboutToBeRemoved, this,
				[this, &source](const QModelIndex &parent, int first, int last) {
			sourceRowsAboutToBeRemoved(source, parent, first, last);
		}),
		connect(model, &QAbstractItemModel::rowsRemoved, this,
				[this, &source](const QModelIndex &parent, int first, int last) {
			sourceRowsRemoved(source, parent, first, last);
		}),
		connect(model, &QAbstractItemModel::rowsAboutToBeMoved, this,
				[this, &source](const QModelIndex &sourceParent, int sourceStart, int sourceEnd,
						const QModelIndex &destinationParent, int destinationRow) {
			sourceRowsAboutToBeMoved(source, sourceParent, sourceStart, sourceEnd, destinationParent,
					destinationRow);
		}),
		connect(model, &QAbstractItemModel::rowsMoved, this,
				[this, &source](const QModelIndex &sourceParent, int sourceStart, int sourceEnd,
						const QModelIndex &destinationParent, int destinationRow) {
			sourceRowsMoved(source, sourceParent, sourceStart, sourceEnd, destinationParent, destinationRow);
		}),
		connect(model, &QAbstractItemModel::dataChanged, this,
				[this, &source](const QModelIndex &topLeft, const QModelIndex &bottomRight,
						const QList<int> &roles) {
			sourceDataChanged(source, topLeft, bottomRight, roles);
		}),
		connect(model, &QAbstractItemModel::layoutAboutToBeChanged, this,
				[this, &source](const QList<QPersistentModelIndex> &parents,
						QAbstractItemModel::LayoutChangeHint hint) {
			sourceLayoutAboutToBeChanged(source, parents, hint);
		}),
		connect(model, &QAbstractItemModel::layoutChanged, this, [this, &source]() {
			sourceLayoutChanged(source);
		}),
		connect(model, &QAbstractItemModel::modelAboutToBeReset, this, [this, &source]() {
			sourceModelAboutToBeReset(source);
		}),
		connect(model, &QAbstractItemModel::modelReset, this, [this, &source]() {
			sourceModelReset(source);
		}),
		connect(model, &QObject::destroyed, this, [this, &source]() {
			sourceDestroyed(source);
		}),
	};
}

// Gives each role name of the two models a role number in this model.
void CombinedListModel::updateRoles()
{
	const QByteArray fromSecondModelName = QByteArrayLiteral("fromSecondModel");
	m_roleNames = { { FromSecondModelRole, fromSecondModelName } };
	QHash<QByteArray, int> roleNumbers = { { fromSecondModelName, FromSecondModelRole } };
	int nextRole = FromSecondModelRole + 1;

	for (Source *source : { &m_first, &m_second }) {
		source->roleNames = source->model ? source->model->roleNames() : QHash<int, QByteArray>();
		source->sourceRoles.clear();
		source->roles.clear();

		// Number the roles in the same order each time.
		QList<int> sourceRoles = source->roleNames.keys();
		std::sort(sourceRoles.begin(), sourceRoles.end());
		for (const int sourceRole : std::as_const(sourceRoles)) {
			const QByteArray name = source->roleNames.value(sourceRole);
			int role = roleNumbers.value(name, -1);
			if (role == FromSecondModelRole) {
				// The model's own role replaces a source role with the same name.
				continue;
			}
			if (role < 0) {
				role = nextRole++;
				roleNumbers.insert(name, role);
				m_roleNames.insert(role, name);
			}
			source->sourceRoles.insert(sourceRole, role);
			source->roles.insert(role, sourceRole);
		}
	}
}

bool CombinedListModel::roleNamesChanged(const Source &source) const
{
	return source.model && source.model->roleNames() != source.roleNames;
}

void CombinedListModel::resetIfRoleNamesChanged(const Source &source)
{
	if (roleNamesChanged(source)) {
		beginResetModel();
		updateRoles();
		endResetModel();
	}
}

int CombinedListModel::rowOffset(const Source &source) const
{
	return &source == &m_second ? m_first.rowCount : 0;
}

void CombinedListModel::removeAllRows(Source &source)
{
	if (source.rowCount > 0) {
		const int offset = rowOffset(source);
		beginRemoveRows(QModelIndex(), offset, offset + source.rowCount - 1);
		source.rowCount = 0;
		endRemoveRows();
		emit countChanged();
	}
}

void CombinedListModel::insertAllRows(Source &source)
{
	const int rowCount = source.model ? source.model->rowCount() : 0;
	if (rowCount > 0) {
		const int offset = rowOffset(source);
		beginInsertRows(QModelIndex(), offset, offset + rowCount - 1);
		source.rowCount = rowCount;
		endInsertRows();
		emit countChanged();
	}
}

void CombinedListModel::sourceRowsAboutToBeInserted(Source &source, const QModelIndex &parent, int first, int last)
{
	if (!parent.isValid()) {
		const int offset = rowOffset(source);
		beginInsertRows(QModelIndex(), offset + first, offset + last);
	}
}

void CombinedListModel::sourceRowsInserted(Source &source, const QModelIndex &parent, int first, int last)
{
	if (!parent.isValid()) {
		source.rowCount += last - first + 1;
		endInsertRows();
		emit countChanged();
		resetIfRoleNamesChanged(source);
	}
}

void CombinedListModel::sourceRowsAboutToBeRemoved(Source &source, const QModelIndex &parent, int first, int last)
{
	if (!parent.isValid()) {
		const int offset = rowOffset(source);
		beginRemoveRows(QModelIndex(), offset + first, offset + last);
	}
}

void CombinedListModel::sourceRowsRemoved(Source &source, const QModelIndex &parent, int first, int last)
{
	if (!parent.isValid()) {
		source.rowCount -= last - first + 1;
		endRemoveRows();
		emit countChanged();
	}
}

// Rows moved into or out of the top level are inserted or removed in this model.
void CombinedListModel::sourceRowsAboutToBeMoved(Source &source, const QModelIndex &sourceParent, int sourceStart,
		int sourceEnd, const QModelIndex &destinationParent, int destinationRow)
{
	const int offset = rowOffset(source);
	if (!sourceParent.isValid() && !destinationParent.isValid()) {
		beginMoveRows(QModelIndex(), offset + sourceStart, offset + sourceEnd, QModelIndex(), offset + destinationRow);
	} else if (!sourceParent.isValid()) {
		beginRemoveRows(QModelIndex(), offset + sourceStart, offset + sourceEnd);
	} else if (!destinationParent.isValid()) {
		beginInsertRows(QModelIndex(), offset + destinationRow, offset + destinationRow + sourceEnd - sourceStart);
	}
}

void CombinedListModel::sourceRowsMoved(Source &source, const QModelIndex &sourceParent, int sourceStart,
		int sourceEnd, const QModelIndex &destinationParent, int)
{
	if (!sourceParent.isValid() && !destinationParent.isValid()) {
		endMoveRows();
	} else if (!sourceParent.isValid()) {
		source.rowCount -= sourceEnd - sourceStart + 1;
		endRemoveRows();
		emit countChanged();
	} else if (!destinationParent.isValid()) {
		source.rowCount += sourceEnd - sourceStart + 1;
		endInsertRows();
		emit countChanged();
	}
}

void CombinedListModel::sourceDataChanged(Source &source, const QModelIndex &topLeft, const QModelIndex &bottomRight,
		const QList<int> &roles)
{
	if (topLeft.parent().isValid() || topLeft.column() > 0) {
		return;
	}

	QList<int> changedRoles;
	for (const int sourceRole : roles) {
		const auto role = source.sourceRoles.constFind(sourceRole);
		if (role != source.sourceRoles.constEnd()) {
			changedRoles.append(*role);
		}
	}
	if (roles.isEmpty() || !changedRoles.isEmpty()) {
		const int offset = rowOffset(source);
		emit dataChanged(index(offset + topLeft.row()), index(offset + bottomRight.row()), changedRoles);
	}
	resetIfRoleNamesChanged(source);
}

void CombinedListModel::sourceLayoutAboutToBeChanged(Source &source, const QList<QPersistentModelIndex> &parents,
		QAbstractItemModel::LayoutChangeHint hint)
{
	// Ignore a change to the children of the top-level rows only.
	const bool topLevelChanged = parents.isEmpty()
			|| std::any_of(parents.cbegin(), parents.cend(),
					[](const QPersistentModelIndex &parent) { return !parent.isValid(); });
	if (!topLevelChanged) {
		source.layoutChange = LayoutChange::None;
		return;
	}

	if (hint == QAbstractItemModel::VerticalSortHint) {
		source.layoutChange = LayoutChange::Sort;
		emit layoutAboutToBeChanged({}, QAbstractItemModel::VerticalSortHint);

		// Remember the source row of each persistent index, to find its new row afterwards.
		m_layoutChangeIndexes.clear();
		const QModelIndexList indexes = persistentIndexList();
		for (const QModelIndex &index : indexes) {
			const bool fromSecondModel = index.row() >= m_first.rowCount;
			const Source &indexSource = fromSecondModel ? m_second : m_first;
			const QModelIndex sourceIndex = indexSource.model
					? indexSource.model->index(index.row() - rowOffset(indexSource), 0)
					: QModelIndex();
			m_layoutChangeIndexes.append({ index, sourceIndex, fromSecondModel });
		}
	} else {
		// The layout change may also remove or insert rows, so remove all the rows of the model
		// now, and insert them again when it ends.
		source.layoutChange = LayoutChange::Rebuild;
		removeAllRows(source);
	}
}

void CombinedListModel::sourceLayoutChanged(Source &source)
{
	const LayoutChange layoutChange = source.layoutChange;
	source.layoutChange = LayoutChange::None;

	if (layoutChange == LayoutChange::Sort) {
		const int oldCount = count();
		source.rowCount = source.model->rowCount();

		QModelIndexList from;
		QModelIndexList to;
		for (const LayoutChangeIndex &changed : std::as_const(m_layoutChangeIndexes)) {
			from.append(changed.index);
			if (changed.sourceIndex.isValid() && !changed.sourceIndex.parent().isValid()) {
				const Source &indexSource = changed.fromSecondModel ? m_second : m_first;
				to.append(index(rowOffset(indexSource) + changed.sourceIndex.row()));
			} else {
				to.append(QModelIndex());
			}
		}
		m_layoutChangeIndexes.clear();
		changePersistentIndexList(from, to);

		// Sorting does not change the number of rows. If it has, the view must not keep its
		// delegates as they are.
		const bool rowCountChanged = count() != oldCount;
		emit layoutChanged({}, rowCountChanged
				? QAbstractItemModel::NoLayoutChangeHint
				: QAbstractItemModel::VerticalSortHint);
		if (rowCountChanged) {
			emit countChanged();
		}
	} else if (layoutChange == LayoutChange::Rebuild) {
		insertAllRows(source);
	}
}

void CombinedListModel::sourceModelAboutToBeReset(Source &source)
{
	removeAllRows(source);
}

void CombinedListModel::sourceModelReset(Source &source)
{
	if (roleNamesChanged(source)) {
		// Reset the whole model, so that the view reads the new role names.
		const int oldCount = count();
		beginResetModel();
		source.rowCount = source.model->rowCount();
		updateRoles();
		endResetModel();
		if (count() != oldCount) {
			emit countChanged();
		}
	} else {
		insertAllRows(source);
	}
}

void CombinedListModel::sourceDestroyed(Source &source)
{
	setModel(source, nullptr);
	if (&source == &m_first) {
		emit firstModelChanged();
	} else {
		emit secondModelChanged();
	}
}
