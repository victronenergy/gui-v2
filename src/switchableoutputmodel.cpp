/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "switchableoutputmodel.h"
#include "enums.h"

#include <veutil/qt/ve_qitem.hpp>
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

SwitchableOutputModel::SwitchableOutputModel(QObject *parent)
	: QSortFilterProxyModel(parent)
	// , m_model(new VeQItemTableModel(VeQItemTableModel::AddChildren | VeQItemTableModel::AddNonLeaves | VeQItemTableModel::DontAddItem, this))
{
	// connect(m_model, &VeQItemTableModel::rowsInserted, this, &SwitchableOutputModel::sourceModelRowsInserted);
	// setSourceModel(m_model);
	sort(0, Qt::AscendingOrder);

}

void SwitchableOutputModel::setSourceModel(QAbstractItemModel *model)
{
	// qWarning() << "setSourceModel() ignored, model is set internally";
	qWarning() << "+++++++++++++ model count:" << model->rowCount();
	const int prevCount = rowCount();

	m_model = qobject_cast<VeQItemTableModel *>(model);
	if (!m_model) {
		qmlWarning(this) << "Expected VeQItemTableModel for source model!";
		return;
	}
	for (int i = 0; i < m_model->rowCount(); ++i) {
		addEntry(m_model->data(m_model->index(i, 0), VeQItemTableModel::UniqueIdRole).toString());
	}
	connect(model, &QAbstractItemModel::rowsInserted, this, &SwitchableOutputModel::sourceModelRowsInserted);
	connect(model, &QAbstractItemModel::rowsAboutToBeRemoved, this, &SwitchableOutputModel::sourceModelRowsAboutToBeRemoved);

	QSortFilterProxyModel::setSourceModel(model);

	if (prevCount != count()) {
		emit countChanged();
	}
}

int SwitchableOutputModel::count() const
{
	return rowCount(QModelIndex());
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
	if (!m_model) {
		return QVariant();
	}
	const QString outputUid = m_model->data(mapToSource(index), VeQItemTableModel::UniqueIdRole).toString();

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
	if (!m_model) {
		return false;
	}

	const QString outputUid = m_model->data(m_model->index(sourceRow, 0), VeQItemTableModel::UniqueIdRole).toString();
	qWarning() << "...filterAcceptsRow" << outputUid;
	auto it = m_entries.constFind(outputUid);
	if (it != m_entries.constEnd()) {
		const Entry &entry = it.value();
		if (!entry.nameItem || !entry.nameItem->getValue().isValid()) {
			qWarning() << "name not accepted" << it.key();
			return false;
		}

		if (m_filterType == ManualFunction) {
			return entry.functionItem && entry.functionItem->getValue() == QVariant(VenusOS::Enums::Relay_Function_Manual);
		} else {
			return true;
		}
	}
	return false;
}

bool SwitchableOutputModel::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const
{
	if (!m_model) {
		return QSortFilterProxyModel::lessThan(sourceLeft, sourceRight);
	}

	const QString leftOutputUid = m_model->data(sourceLeft, VeQItemTableModel::UniqueIdRole).toString();
	const QString rightOutputUid = m_model->data(sourceRight, VeQItemTableModel::UniqueIdRole).toString();
	const Entry &leftEntry = m_entries.value(leftOutputUid);
	const Entry &rightEntry = m_entries.value(rightOutputUid);
	return leftEntry.name().localeAwareCompare(rightEntry.name()) < 0;
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
		// connect(entry.functionItem, &VeQItem::valueChanged, this, &SwitchableOutputModel::outputValueChanged);
		connect(entry.functionItem, &VeQItem::valueChanged, [this]() {
			if (m_filterType != NoFilter) {
				invalidateFilter();
			}
		});
	}

	qWarning() << "...added" << outputUid << entry.functionItem << entry.customNameItem;
	m_entries.insert(outputUid, entry);
}

void SwitchableOutputModel::removeEntry(const QString &outputUid)
{
	qWarning() << "+++++++++ removeEntry" << outputUid;
	m_entries.remove(outputUid);
}

void SwitchableOutputModel::sourceModelRowsInserted(const QModelIndex &parent, int first, int last)
{
	qWarning() << "+++++++++ insert" << first << last << m_model;
	for (int i = first; i <= last; ++i) {
		addEntry(m_model->data(m_model->index(i, 0), VeQItemTableModel::UniqueIdRole).toString());
	}
	emit countChanged();

	// invalidate();
	// sort(0);
}

void SwitchableOutputModel::sourceModelRowsAboutToBeRemoved(const QModelIndex &parent, int first, int last)
{
	qWarning() << "+++++++++ remove" << first << last;
	for (int i = first; i <= last; ++i) {
		removeEntry(m_model->data(m_model->index(i, 0), VeQItemTableModel::UniqueIdRole).toString());
	}
	emit countChanged();
}
