/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "iochannelproxymodel.h"
#include "enums.h"
#include "backendconnection.h"

#include <veutil/qt/ve_qitem_table_model.hpp>

#include <QQmlInfo>

using namespace Victron::VenusOS;

QString IOChannelProxyModel::Entry::name() const
{
	const QString customName = customNameItem ? customNameItem->getValue().toString() : QString();
	const QString name = nameItem ? nameItem->getValue().toString() : QString();
	if (customName.length() > 0) {
		return QString("%1: %2").arg(name).arg(customName);
	} else {
		return name;
	}
}

bool IOChannelProxyModel::Entry::isUserConfigurable() const
{
	// If /GenericInput/x/Settings/DigitalInputMode = 0 or /SwitchableOutput/x/Settings/SwitchMode = 0,
	// consider the input/output to be disabled, and thus not user-configurable.
	const QVariant modeValue = modeItem ? modeItem->getValue() : QVariant();
	if (modeValue.isValid() && modeValue.toInt() == 0) {
		return false;
	}

	// If /SwitchableOutput/x/Settings/FuseDetection = 0 (disabled) and /Settings/SwitchMode is
	// absent/invalid or 1 (Permanent on) then the output is not user configurable.
	if (fuseDetectionItem
			&& fuseDetectionItem->getValue().isValid()
			&& fuseDetectionItem->getValue().toInt() == 0
			&& (!modeValue.isValid() || modeValue.toInt() == Enums::SwitchableOutput_SwitchMode_PermanentOn)) {
		return false;
	}
	return true;
}

void IOChannelProxyModel::Entry::disconnect(QObject *object)
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
	if (modeItem) {
		modeItem->disconnect(object);
	}
	if (fuseDetectionItem) {
		fuseDetectionItem->disconnect(object);
	}
}


IOChannelProxyModel::IOChannelProxyModel(QObject *parent)
	: QSortFilterProxyModel(parent)
{
	sort(0, Qt::AscendingOrder);

	connect(this, &IOChannelProxyModel::rowsInserted, this, &IOChannelProxyModel::updateCount);
	connect(this, &IOChannelProxyModel::rowsRemoved, this, &IOChannelProxyModel::updateCount);
	connect(this, &IOChannelProxyModel::modelReset, this, &IOChannelProxyModel::updateCount);
	connect(this, &IOChannelProxyModel::layoutChanged, this, &IOChannelProxyModel::updateCount);
}

IOChannelProxyModel::~IOChannelProxyModel()
{
	clearEntries();
}

void IOChannelProxyModel::setSourceModel(QAbstractItemModel *model)
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

	connect(model, &QAbstractItemModel::rowsInserted, this, &IOChannelProxyModel::sourceModelRowsInserted);
	connect(model, &QAbstractItemModel::rowsAboutToBeRemoved, this, &IOChannelProxyModel::sourceModelRowsAboutToBeRemoved);
	connect(model, &QAbstractItemModel::modelAboutToBeReset, this, &IOChannelProxyModel::clearEntries);

	QSortFilterProxyModel::setSourceModel(model);
}

int IOChannelProxyModel::count() const
{
	return m_count;
}

IOChannelProxyModel::FilterType IOChannelProxyModel::filterType() const
{
	return m_filterType;
}

void IOChannelProxyModel::setFilterType(FilterType filterType)
{
	if (m_filterType != filterType) {
		if (count() > 0) {
			qmlWarning(this) << "Filter cannot be changed after model is populated!";
			return;
		}

		m_filterType = filterType;
		if (m_filterType == UserConfigurable && !m_accessLevelItem) {
			m_accessLevelItem = VeQItems::getRoot()->itemGetOrCreate(BackendConnection::create()->serviceUidForType("settings") + "/Settings/System/AccessLevel");
			if (m_accessLevelItem) {
				connect(m_accessLevelItem, &VeQItem::valueChanged, this, &IOChannelProxyModel::invalidate);
			}
		}

		invalidate();
		emit filterTypeChanged();
	}
}

QVariant IOChannelProxyModel::data(const QModelIndex &index, int role) const
{
	if (!sourceModel()) {
		return QVariant();
	}

	const QString channelUid = sourceModel()->data(mapToSource(index), VeQItemTableModel::UniqueIdRole).toString();

	switch (role) {
	case UidRole:
		return channelUid;
	case NameRole:
		return m_entries.value(channelUid).name();
	}
	return QVariant();
}

QHash<int, QByteArray> IOChannelProxyModel::roleNames() const
{
	static QHash<int, QByteArray> roles = {
		{ UidRole, "uid" },
		{ NameRole, "name" },
	};
	return roles;
}

bool IOChannelProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &) const
{
	if (!sourceModel()) {
		return false;
	}

	const QString channelUid = sourceModel()->data(sourceModel()->index(sourceRow, 0), VeQItemTableModel::UniqueIdRole).toString();
	auto it = m_entries.constFind(channelUid);
	if (it == m_entries.constEnd()) {
		return false;
	}

	const Entry &entry = it.value();

	// If the /Name is not present or is an empty string, this channel is not valid (e.g. it may be
	// a system relay configured as an input), so do not show it in the list.
	if (!entry.nameItem || entry.nameItem->getValue().toString().isEmpty()) {
		return false;
	}

	// If the model requires manual relays, only show the channel if it is configured as one.
	if (m_filterType == ManualFunction
			&& (!entry.functionItem || entry.functionItem->getValue() != QVariant(VenusOS::Enums::SwitchableOutput_Function_Manual))) {
		return false;
	}

	// If the model should only show user-configurable channels, include the channel if the access
	// level is restricted to user-only and the channel is user-configurable.
	if (m_filterType == UserConfigurable
			&& m_accessLevelItem
			&& m_accessLevelItem->getValue().toInt() == Enums::User_AccessType_User
			&& !entry.isUserConfigurable()) {
	   return false;
	}

	return true;
}

bool IOChannelProxyModel::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const
{
	if (!sourceModel()) {
		return QSortFilterProxyModel::lessThan(sourceLeft, sourceRight);
	}

	const QString leftchannelUid = sourceModel()->data(sourceLeft, VeQItemTableModel::UniqueIdRole).toString();
	const QString rightchannelUid = sourceModel()->data(sourceRight, VeQItemTableModel::UniqueIdRole).toString();
	const Entry &leftEntry = m_entries.value(leftchannelUid);
	const Entry &rightEntry = m_entries.value(rightchannelUid);
	return leftEntry.name().localeAwareCompare(rightEntry.name()) < 0;
}

void IOChannelProxyModel::sourceModelRowsInserted(const QModelIndex &parent, int first, int last)
{
	if (!sourceModel()) {
		return;
	}
	for (int i = first; i <= last; ++i) {
		addEntry(sourceModel()->data(sourceModel()->index(i, 0), VeQItemTableModel::UniqueIdRole).toString());
	}
}

void IOChannelProxyModel::sourceModelRowsAboutToBeRemoved(const QModelIndex &parent, int first, int last)
{
	if (!sourceModel()) {
		return;
	}
	for (int i = first; i <= last; ++i) {
		const QString channelUid = sourceModel()->data(sourceModel()->index(i, 0), VeQItemTableModel::UniqueIdRole).toString();
		Entry entry = m_entries.take(channelUid);
		entry.disconnect(this);
	}
}

void IOChannelProxyModel::clearEntries()
{
	for (auto it = m_entries.begin(); it != m_entries.end(); ++it) {
		it.value().disconnect(this);
	}
	m_entries.clear();
}

void IOChannelProxyModel::addEntry(const QString &channelUid)
{
	// channelUid is e.g. "dbus/com.victronenergy.system/<GenericInput|SwitchableOutput>/<id>" or
	// "mqtt/system/0/<GenericInput|SwitchableOutput>/<id>"
	if (m_entries.contains(channelUid)) {
		return;
	}

	VeQItem *channelItem = VeQItems::getRoot()->itemGetOrCreate(channelUid);
	if (!channelItem) {
		qmlWarning(this) << "Cannot monitor " << channelUid << ", cannot find matching VeQItem!";
		return;
	}

	Entry entry;
	entry.nameItem = channelItem->itemGetOrCreate(QStringLiteral("Name"));
	if (entry.nameItem) {
		connect(entry.nameItem, &VeQItem::valueChanged, this, &IOChannelProxyModel::invalidate);
	}
	entry.customNameItem = channelItem->itemGetOrCreate(QStringLiteral("Settings/CustomName"));
	if (entry.customNameItem) {
		connect(entry.customNameItem, &VeQItem::valueChanged, this, &IOChannelProxyModel::invalidate);
	}
	entry.functionItem = channelItem->itemGetOrCreate(QStringLiteral("Settings/Function"));
	if (entry.functionItem) {
		connect(entry.functionItem, &VeQItem::valueChanged, this, &IOChannelProxyModel::invalidate);
	}

	const int lastSlashIndex = channelUid.lastIndexOf('/');
	if (lastSlashIndex >= 0) {
		const int secondLastSlashIndex = channelUid.lastIndexOf('/', lastSlashIndex - 1);
		if (secondLastSlashIndex >= 0) {
			const QString token = channelUid.mid(secondLastSlashIndex, lastSlashIndex - secondLastSlashIndex);
			if (token == QStringLiteral("/GenericInput")) {
				entry.modeItem = channelItem->itemGetOrCreate(QStringLiteral("Settings/DigitalInputMode"));
			} else if (token == QStringLiteral("/SwitchableOutput")) {
				entry.modeItem = channelItem->itemGetOrCreate(QStringLiteral("Settings/SwitchMode"));
				entry.fuseDetectionItem = channelItem->itemGetOrCreate(QStringLiteral("Settings/FuseDetection"));
				if (entry.fuseDetectionItem) {
					connect(entry.fuseDetectionItem, &VeQItem::valueChanged, this, &IOChannelProxyModel::invalidate);
				}
			}
			if (entry.modeItem) {
				connect(entry.modeItem, &VeQItem::valueChanged, this, &IOChannelProxyModel::invalidate);
			}
		}
	}

	m_entries.insert(channelUid, entry);

}

void IOChannelProxyModel::updateCount()
{
	const int count = rowCount();
	if (m_count != count) {
		m_count = count;
		emit countChanged();
	}
}
