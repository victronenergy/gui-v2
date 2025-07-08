/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "switchableoutputmodel.h"
#include "enums.h"

#include <veutil/qt/ve_qitem_table_model.hpp>

#include <QQmlInfo>

using namespace Victron::VenusOS;

QString SwitchableOutputModel::Entry::name() const
{
	const QString customName = customNameItem ? customNameItem->getValue().toString() : QString();
	const QString name = nameItem ? nameItem->getValue().toString() : QString();
	if (customName.length() > 0) {
		return QString("%1: %2").arg(name).arg(customName);
	} else {
		return name;
	}
}

void SwitchableOutputModel::Entry::disconnect(QObject *object)
{
	if (nameItem) {
		nameItem->disconnect(object);
	}
	if (customNameItem) {
		customNameItem->disconnect(object);
	}
	if (functionItem) {
		functionItem->disconnect(object);
	}
}


SwitchableOutputModel::SwitchableOutputModel(QObject *parent)
	: QSortFilterProxyModel(parent)
{
	sort(0, Qt::AscendingOrder);

	connect(this, &SwitchableOutputModel::rowsInserted, this, &SwitchableOutputModel::updateCount);
	connect(this, &SwitchableOutputModel::rowsRemoved, this, &SwitchableOutputModel::updateCount);
	connect(this, &SwitchableOutputModel::modelReset, this, &SwitchableOutputModel::updateCount);
	connect(this, &SwitchableOutputModel::layoutChanged, this, &SwitchableOutputModel::updateCount);
}

SwitchableOutputModel::~SwitchableOutputModel()
{
	clearEntries();
}

void SwitchableOutputModel::setSourceModel(QAbstractItemModel *model)
{
	if (sourceModel()) {
		sourceModel()->disconnect(this);
	}
	if (!qobject_cast<VeQItemTableModel *>(model)) {
		qmlWarning(this) << "Expected VeQItemTableModel for source model!";
		QSortFilterProxyModel::setSourceModel(nullptr);
		return;
	}

	for (int i = 0; i < model->rowCount(); ++i) {
		addEntry(model->data(model->index(i, 0), VeQItemTableModel::UniqueIdRole).toString());
	}

	connect(model, &QAbstractItemModel::rowsInserted, this, &SwitchableOutputModel::sourceModelRowsInserted);
	connect(model, &QAbstractItemModel::rowsAboutToBeRemoved, this, &SwitchableOutputModel::sourceModelRowsAboutToBeRemoved);
	connect(model, &QAbstractItemModel::modelAboutToBeReset, this, &SwitchableOutputModel::clearEntries);

	QSortFilterProxyModel::setSourceModel(model);
}

int SwitchableOutputModel::count() const
{
	return m_count;
}

SwitchableOutputModel::FilterType SwitchableOutputModel::filterType() const
{
	return m_filterType;
}

void SwitchableOutputModel::setFilterType(FilterType filterType)
{
	if (m_filterType != filterType) {
		if (count() > 0) {
			qmlWarning(this) << "Filter cannot be changed after model is populated!";
			return;
		}

		m_filterType = filterType;
		emit filterTypeChanged();
	}
}

QVariant SwitchableOutputModel::data(const QModelIndex &index, int role) const
{
	if (!sourceModel()) {
		return QVariant();
	}

	const QString outputUid = sourceModel()->data(mapToSource(index), VeQItemTableModel::UniqueIdRole).toString();

	switch (role) {
	case UidRole:
		return outputUid;
	case NameRole:
		return m_entries.value(outputUid).name();
	}
	return QVariant();
}

QHash<int, QByteArray> SwitchableOutputModel::roleNames() const
{
	static QHash<int, QByteArray> roles = {
		{ UidRole, "uid" },
		{ NameRole, "name" },
	};
	return roles;
}

bool SwitchableOutputModel::filterAcceptsRow(int sourceRow, const QModelIndex &) const
{
	if (!sourceModel()) {
		return false;
	}

	const QString outputUid = sourceModel()->data(sourceModel()->index(sourceRow, 0), VeQItemTableModel::UniqueIdRole).toString();
	auto it = m_entries.constFind(outputUid);
	if (it == m_entries.constEnd()) {
		return false;
	}

	const Entry &entry = it.value();

	// If the /Name is not present, this output is not valid (e.g. it may be a system relay
	// configured as an input), so do not show it in the list.
	if (!entry.nameItem || !entry.nameItem->getValue().isValid()) {
		return false;
	}

	// If the model requires manual relays, only show this output if it is configured as one.
	if (m_filterType == ManualFunction
			&& (!entry.functionItem || entry.functionItem->getValue() != QVariant(VenusOS::Enums::Relay_Function_Manual))) {
		return false;
	}

	return true;
}

bool SwitchableOutputModel::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const
{
	if (!sourceModel()) {
		return QSortFilterProxyModel::lessThan(sourceLeft, sourceRight);
	}

	const QString leftOutputUid = sourceModel()->data(sourceLeft, VeQItemTableModel::UniqueIdRole).toString();
	const QString rightOutputUid = sourceModel()->data(sourceRight, VeQItemTableModel::UniqueIdRole).toString();
	const Entry &leftEntry = m_entries.value(leftOutputUid);
	const Entry &rightEntry = m_entries.value(rightOutputUid);
	return leftEntry.name().localeAwareCompare(rightEntry.name()) < 0;
}

void SwitchableOutputModel::sourceModelRowsInserted(const QModelIndex &parent, int first, int last)
{
	if (!sourceModel()) {
		return;
	}
	for (int i = first; i <= last; ++i) {
		addEntry(sourceModel()->data(sourceModel()->index(i, 0), VeQItemTableModel::UniqueIdRole).toString());
	}
}

void SwitchableOutputModel::sourceModelRowsAboutToBeRemoved(const QModelIndex &parent, int first, int last)
{
	if (!sourceModel()) {
		return;
	}
	for (int i = first; i <= last; ++i) {
		const QString outputUid = sourceModel()->data(sourceModel()->index(i, 0), VeQItemTableModel::UniqueIdRole).toString();
		Entry entry = m_entries.take(outputUid);
		entry.disconnect(this);
	}
}

void SwitchableOutputModel::clearEntries()
{
	for (auto it = m_entries.begin(); it != m_entries.end(); ++it) {
		it.value().disconnect(this);
	}
	m_entries.clear();
}

void SwitchableOutputModel::addEntry(const QString &outputUid)
{
	// outputUid is e.g. "dbus/com.victronenergy.system/SwitchableOutput/<output-id>" or
	// "mqtt/system/0/SwitchableOutput/<output-id>"
	if (m_entries.contains(outputUid)) {
		return;
	}

	VeQItem *outputItem = VeQItems::getRoot()->itemGet(outputUid);
	if (!outputItem) {
		qmlWarning(this) << "Cannot monitor output " << outputUid << ", cannot find matching VeQItem!";
		return;
	}

	Entry entry;
	entry.nameItem = outputItem->itemGet(QStringLiteral("/Name"));
	if (entry.nameItem) {
		connect(entry.nameItem, &VeQItem::valueChanged, this, &SwitchableOutputModel::invalidate);
	}
	entry.customNameItem = outputItem->itemGet(QStringLiteral("/Settings/CustomName"));
	if (entry.customNameItem) {
		connect(entry.customNameItem, &VeQItem::valueChanged, this, &SwitchableOutputModel::invalidate);
	}
	entry.functionItem = outputItem->itemGet(QStringLiteral("/Settings/Function"));
	if (entry.functionItem) {
		connect(entry.functionItem, &VeQItem::valueChanged, this, &SwitchableOutputModel::invalidateFilter);
	}

	m_entries.insert(outputUid, entry);

}

void SwitchableOutputModel::updateCount()
{
	const int count = rowCount();
	if (m_count != count) {
		m_count = count;
		emit countChanged();
	}
}
