/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "plugindatapathmodel.h"

#include "backendconnection.h"
#include "devicewatcher.h"

#include <veutil/qt/ve_qitem.hpp>

#include <QSet>

#include <algorithm>
#include <chrono>

namespace Victron {
namespace GuiPlugins {

/*
	The model lists the children of the backend item at uid. The tree of backend items also has
	items that were created only because something asked for that path, whether the system has
	that path or not. So a child is listed only once the system has given it, or one of its
	descendants, a value, as the item's state shows. A child such as "Dc" has no value of its
	own, so every descendant of the item at uid is watched.

	The model reads only the state of an item, never its value: reading the value would ask the
	system for it.

	The model is never reset: rows are inserted and removed, so that a view keeps the delegates of
	the rows that stay.

	Changes often come in bursts, such as when the GUI connects and the system sends every path.
	So a change starts a short timer, and the list is updated once when it fires. Later changes
	do not restart the timer, so a steady stream of changes still updates the list.

	serviceType, deviceInstance and path name a uid as on a PluginDataItem, and a DeviceWatcher
	finds the service uid of the device. uid is empty while only one of serviceType and path is
	set, so nothing is listed while QML assigns them, and it is empty until the device becomes
	available. When serviceType and path are empty and deviceInstance is unset, uid is left alone,
	so that the plugin can set it.

	The childPath role is the path of a child on its service, so that it can be given to a
	PluginDataItem with the same serviceType and deviceInstance. It is empty when the plugin sets
	uid itself, because a uid does not show where its service ends.

	The role names start with "child", so that they differ from the uid and path properties. In a
	delegate, a nested model's "uid: uid" would bind its uid to itself.

	The D-Bus and MQTT backends never delete items, but the mock backend deletes the items of a
	device that it removes. If the item at uid is deleted, the model creates it again, so that it
	sees the paths if they come back.
*/

namespace {

bool isListed(const VeQItem *item)
{
	switch (item->getState()) {
	case VeQItem::Synchronized:
	case VeQItem::Storing:
	case VeQItem::Preview:
		return true;
	default:
		break;
	}
	const VeQItem::Children &children = item->itemChildren();
	for (auto it = children.constBegin(); it != children.constEnd(); ++it) {
		if (isListed(it.value())) {
			return true;
		}
	}
	return false;
}

bool nameLessThan(const QString &left, const QString &right)
{
	bool leftIsNumber = false;
	bool rightIsNumber = false;
	const qulonglong leftNumber = left.toULongLong(&leftIsNumber);
	const qulonglong rightNumber = right.toULongLong(&rightIsNumber);
	if (leftIsNumber != rightIsNumber) {
		return leftIsNumber;
	}
	if (leftIsNumber && leftNumber != rightNumber) {
		return leftNumber < rightNumber;
	}
	const int compared = left.compare(right, Qt::CaseInsensitive);
	return compared != 0 ? compared < 0 : left < right;
}

} // namespace

PluginDataPathModel::PluginDataPathModel(QObject *parent)
	: QAbstractListModel(parent)
{
	m_updateTimer.setSingleShot(true);
	m_updateTimer.setInterval(std::chrono::milliseconds(100));
	connect(&m_updateTimer, &QTimer::timeout, this, &PluginDataPathModel::update);
}

QString PluginDataPathModel::uid() const
{
	return m_uid;
}

void PluginDataPathModel::setUid(const QString &uid)
{
	if (m_uid == uid) {
		return;
	}
	m_uid = uid;
	m_updateTimer.stop();

	if (m_root) {
		unwatchItem(m_root);
	}
	findRoot();

	const int previous = m_names.count();
	beginResetModel();
	m_names = listedNames();
	endResetModel();
	emit uidChanged();
	if (m_names.count() != previous) {
		emit countChanged();
	}
}

void PluginDataPathModel::findRoot()
{
	QString rootUid = m_uid;
	while (rootUid.endsWith('/')) {
		rootUid.chop(1);
	}
	// Create the item if it does not exist yet, as a VeQuickItem does, so that new children are seen.
	m_root = rootUid.isEmpty() ? nullptr : VeQItems::getRoot()->itemGetOrCreate(rootUid, true, false);
	m_rootUid = m_root ? m_root->uniqueId() : QString();
	if (m_root) {
		watchItem(m_root);
		connect(m_root, &QObject::destroyed, this, &PluginDataPathModel::rootDestroyed);
	}
}

QString PluginDataPathModel::serviceType() const
{
	return m_serviceType;
}

void PluginDataPathModel::setServiceType(const QString &serviceType)
{
	if (m_serviceType != serviceType) {
		m_serviceType = serviceType;
		emit serviceTypeChanged();
		updateResolvedUid();
	}
}

int PluginDataPathModel::deviceInstance() const
{
	return m_deviceInstance;
}

void PluginDataPathModel::setDeviceInstance(int deviceInstance)
{
	if (m_deviceInstance != deviceInstance) {
		m_deviceInstance = deviceInstance;
		emit deviceInstanceChanged();
		updateResolvedUid();
	}
}

QString PluginDataPathModel::path() const
{
	return m_path;
}

void PluginDataPathModel::setPath(const QString &path)
{
	if (m_path != path) {
		m_path = path;
		emit pathChanged();
		updateResolvedUid();
	}
}

void PluginDataPathModel::updateResolvedUid()
{
	if (m_serviceType.isEmpty() && m_path.isEmpty() && m_deviceInstance < 0) {
		if (m_watcher) {
			m_watcher->stop();
		}
		return;
	}

	if (m_deviceInstance >= 0 && !m_serviceType.isEmpty()) {
		if (!m_watcher) {
			m_watcher = new DeviceWatcher(this);
			connect(m_watcher, &DeviceWatcher::serviceUidChanged, this, &PluginDataPathModel::applyResolvedUid);
		}
		m_watcher->watch(m_serviceType, m_deviceInstance);
	} else if (m_watcher) {
		m_watcher->stop();
	}
	applyResolvedUid();
}

void PluginDataPathModel::applyResolvedUid()
{
	if (m_serviceType.isEmpty() || m_path.isEmpty()) {
		setUid(QString());
		return;
	}
	QString serviceUid;
	if (m_deviceInstance < 0) {
		serviceUid = VenusOS::BackendConnection::create()->serviceUidForType(m_serviceType);
	} else {
		serviceUid = m_watcher ? m_watcher->serviceUid() : QString();
	}
	if (serviceUid.isEmpty()) {
		setUid(QString());
		return;
	}
	const QString relativePath = m_path.startsWith('/') ? m_path.mid(1) : m_path;
	setUid(relativePath.isEmpty() ? serviceUid : serviceUid + '/' + relativePath);
}

int PluginDataPathModel::count() const
{
	return m_names.count();
}

QString PluginDataPathModel::childNameAt(int index) const
{
	return index >= 0 && index < m_names.count() ? m_names.at(index) : QString();
}

QString PluginDataPathModel::childPathAt(int index) const
{
	if (index < 0 || index >= m_names.count() || m_serviceType.isEmpty() || m_path.isEmpty()) {
		return QString();
	}
	QString parentPath = m_path.startsWith('/') ? m_path : '/' + m_path;
	while (parentPath.endsWith('/')) {
		parentPath.chop(1);
	}
	return parentPath + '/' + m_names.at(index);
}

QString PluginDataPathModel::childUidAt(int index) const
{
	return index >= 0 && index < m_names.count() ? m_rootUid + '/' + m_names.at(index) : QString();
}

int PluginDataPathModel::rowCount(const QModelIndex &parent) const
{
	return parent.isValid() ? 0 : m_names.count();
}

QVariant PluginDataPathModel::data(const QModelIndex &index, int role) const
{
	if (index.column() != 0 || index.row() < 0 || index.row() >= m_names.count()) {
		return QVariant();
	}
	switch (role) {
	case ChildNameRole:
		return childNameAt(index.row());
	case ChildPathRole:
		return childPathAt(index.row());
	case ChildUidRole:
		return childUidAt(index.row());
	default:
		return QVariant();
	}
}

QHash<int, QByteArray> PluginDataPathModel::roleNames() const
{
	return {
		{ ChildNameRole, "childName" },
		{ ChildPathRole, "childPath" },
		{ ChildUidRole, "childUid" },
	};
}

void PluginDataPathModel::watchItem(VeQItem *item)
{
	connect(item, &VeQItem::childAdded, this, &PluginDataPathModel::childAdded, Qt::UniqueConnection);
	connect(item, &VeQItem::childRemoved, this, &PluginDataPathModel::scheduleUpdate, Qt::UniqueConnection);
	connect(item, &VeQItem::stateChanged, this, &PluginDataPathModel::scheduleUpdate, Qt::UniqueConnection);
	const VeQItem::Children &children = item->itemChildren();
	for (auto it = children.constBegin(); it != children.constEnd(); ++it) {
		watchItem(it.value());
	}
}

void PluginDataPathModel::unwatchItem(VeQItem *item)
{
	item->disconnect(this);
	const VeQItem::Children &children = item->itemChildren();
	for (auto it = children.constBegin(); it != children.constEnd(); ++it) {
		unwatchItem(it.value());
	}
}

void PluginDataPathModel::childAdded(VeQItem *child)
{
	watchItem(child);
	scheduleUpdate();
}

void PluginDataPathModel::scheduleUpdate()
{
	if (!m_updateTimer.isActive()) {
		m_updateTimer.start();
	}
}

void PluginDataPathModel::rootDestroyed()
{
	m_updateTimer.stop();
	if (!m_names.isEmpty()) {
		beginResetModel();
		m_names.clear();
		endResetModel();
		emit countChanged();
	}
	// Wait until the backend has finished deleting the items.
	QMetaObject::invokeMethod(this, &PluginDataPathModel::findDeletedRoot, Qt::QueuedConnection);
}

void PluginDataPathModel::findDeletedRoot()
{
	// If uid changed meanwhile, setUid() found its root already.
	if (m_root) {
		return;
	}
	findRoot();
	scheduleUpdate();
}

QStringList PluginDataPathModel::listedNames() const
{
	QStringList names;
	if (m_root) {
		const VeQItem::Children &children = m_root->itemChildren();
		for (auto it = children.constBegin(); it != children.constEnd(); ++it) {
			if (isListed(it.value())) {
				names.append(it.key());
			}
		}
	}
	std::sort(names.begin(), names.end(), nameLessThan);
	return names;
}

void PluginDataPathModel::update()
{
	const int previous = m_names.count();
	const QStringList names = listedNames();
	const QSet<QString> listed(names.cbegin(), names.cend());
	for (int row = m_names.count() - 1; row >= 0; --row) {
		if (!listed.contains(m_names.at(row))) {
			beginRemoveRows(QModelIndex(), row, row);
			m_names.removeAt(row);
			endRemoveRows();
		}
	}
	// The rows left are in the same order as in names, so each missing name is inserted at its
	// index in names.
	for (int row = 0; row < names.count(); ++row) {
		if (row < m_names.count() && m_names.at(row) == names.at(row)) {
			continue;
		}
		beginInsertRows(QModelIndex(), row, row);
		m_names.insert(row, names.at(row));
		endInsertRows();
	}
	if (m_names.count() != previous) {
		emit countChanged();
	}
}

} // namespace GuiPlugins
} // namespace Victron
