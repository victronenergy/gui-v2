/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "solaryieldmodel.h"
#include "alldevicesmodel.h"
#include "device.h"

#include <QQmlInfo>

using namespace Victron::VenusOS;

SolarYieldModel::SolarYieldModel(QObject *parent)
	: QAbstractListModel(parent)
{
}

int SolarYieldModel::count() const
{
	return m_dailyYields.count();
}

qreal SolarYieldModel::maximumYield() const
{
	return m_maximumYield;
}

int SolarYieldModel::firstDay() const
{
	return m_firstDay;
}

void SolarYieldModel::setFirstDay(int firstDay)
{
	if (m_firstDay != firstDay) {
		m_firstDay = firstDay;
		if (m_completed) {
			resetYields();
		}
		emit firstDayChanged();
	}
}

int SolarYieldModel::lastDay() const
{
	return m_lastDay;
}

void SolarYieldModel::setLastDay(int lastDay)
{
	if (m_lastDay != lastDay) {
		m_lastDay = lastDay;
		if (m_completed) {
			resetYields();
		}
		emit lastDayChanged();
	}
}

QString SolarYieldModel::serviceUid() const
{
	return m_serviceUid;
}

void SolarYieldModel::setServiceUid(const QString &serviceUid)
{
	if (m_serviceUid != serviceUid) {
		m_serviceUid = serviceUid;
		if (m_completed) {
			resetYields();
		}
		emit serviceUidChanged();
	}
}

void SolarYieldModel::classBegin()
{
}

void SolarYieldModel::componentComplete()
{
	m_completed = true;
	resetYields();
}

QVariant SolarYieldModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();
	if (row < 0 || row >= m_dailyYields.count()) {
		return QVariant();
	}

	switch (role)
	{
	case DayRole:
		return m_firstDay + row;
	case YieldKwhRole:
		return m_dailyYields.at(row).yieldKwh;
	default:
		return QVariant();
	}
}

int SolarYieldModel::rowCount(const QModelIndex &) const
{
	return count();
}

QHash<int, QByteArray> SolarYieldModel::roleNames() const
{
	static QHash<int, QByteArray> roles = {
		{ DayRole, "day" },
		{ YieldKwhRole, "yieldKwh" },
	};
	return roles;
}

void SolarYieldModel::sourceDeviceAdded(const QModelIndex &parent, int first, int last)
{
	Q_UNUSED(parent)

	for (int row = first; row <= last; ++row) {
		maybeAddHistoryForDevice(AllDevicesModel::create()->deviceAt(row));
	}
	refreshMaximumYield();
}

void SolarYieldModel::sourceDeviceAboutToBeRemoved(const QModelIndex &parent, int first, int last)
{
	Q_UNUSED(parent)

	bool entriesRemoved = false;

	for (int row = first; row <= last; ++row) {
		if (Device *device = AllDevicesModel::create()->deviceAt(row)) {
			if (shouldMonitorDevice(device)) {
				// Stop monitoring /DaysAvailable for this device.
				const QString uid = device->serviceUid() + QStringLiteral("/History/Overall/DaysAvailable");
				if (auto it = m_daysAvailableItems.constFind(uid); it != m_daysAvailableItems.constEnd()) {
					if (it.value()) {
						it.value()->disconnect(this);
					}
					m_daysAvailableItems.erase(it);
				}
				// Remove entries from this device from all days.
				for (int i = 0; i < m_dailyYields.count(); ++i) {
					const QString yieldItemUid = device->serviceUid() + QStringLiteral("/History/Daily/%1/Yield").arg(i - m_firstDay);
					if (VeQItem *yieldItem = m_dailyYields[i].yieldItems.take(yieldItemUid)) {
						yieldItem->disconnect(this);
						updateDayAt(i);
					}
				}
				entriesRemoved = true;
			}
		}
	}

	if (entriesRemoved) {
		refreshMaximumYield();
	}
}

void SolarYieldModel::sourceDevicesAboutToBeReset()
{
	resetYields();
}

void SolarYieldModel::resetYields()
{
	if (!m_completed) {
		return;
	}

	const int prevCount = count();
	beginResetModel();

	AllDevicesModel::create()->disconnect(this);

	// Clear the daily yield values
	for (int i = 0; i < m_dailyYields.count(); ++i) {
		DailyYield *dailyYield = &m_dailyYields[i];
		for (auto it = dailyYield->yieldItems.begin(); it != dailyYield->yieldItems.end(); ++it) {
			if (it.value()) {
				it.value()->disconnect(this);
			}
		}
		dailyYield->yieldItems.clear();
		dailyYield->yieldKwh = 0;
	}

	// Clear the DaysAvailable items
	for (auto it = m_daysAvailableItems.begin(); it != m_daysAvailableItems.end(); ++it) {
		if (it.value()) {
			it.value()->disconnect(this);
		}
	}
	m_daysAvailableItems.clear();

	// Clear the max yield
	m_maximumYield = 0;

	// Populate the model.
	m_dailyYields.resize(std::max(0, m_lastDay - m_firstDay + 1));
	for (int i = 0; i < AllDevicesModel::create()->count(); ++i) {
		maybeAddHistoryForDevice(AllDevicesModel::create()->deviceAt(i));
	}
	connect(AllDevicesModel::create(), &AllDevicesModel::rowsInserted,
			this, &SolarYieldModel::sourceDeviceAdded);
	connect(AllDevicesModel::create(), &AllDevicesModel::rowsAboutToBeRemoved,
			this, &SolarYieldModel::sourceDeviceAboutToBeRemoved);
	connect(AllDevicesModel::create(), &AllDevicesModel::modelAboutToBeReset,
			this, &SolarYieldModel::sourceDevicesAboutToBeReset);

	endResetModel();

	refreshMaximumYield();
	if (count() != prevCount) {
		emit countChanged();
	}
}

void SolarYieldModel::maybeAddHistoryForDevice(Device *device)
{
	if (!device || !device->serviceItem()) {
		qmlWarning(this) << "invalid history candidate!";
		return;
	}
	if (shouldMonitorDevice(device)) {
		// This device may have a /History value, so monitor it.
		// Use itemGetOrCreate() to get the value regardless of whether it currently exists.
		if (VeQItem *daysAvailableItem = device->serviceItem()->itemGetOrCreate(QStringLiteral("History/Overall/DaysAvailable"))) {
			m_daysAvailableItems.insert(daysAvailableItem->uniqueId(), daysAvailableItem);
			if (daysAvailableItem->getValue().toInt() > 0) {
				updateDaysAvailable(daysAvailableItem);
			}
			connect(daysAvailableItem, &VeQItem::valueChanged, this, &SolarYieldModel::daysAvailableChanged);
		}
	}
}

void SolarYieldModel::daysAvailableChanged(QVariant daysAvailable)
{
	Q_UNUSED(daysAvailable)
	if (VeQItem *daysAvailableItem = qobject_cast<VeQItem *>(sender())) {
		updateDaysAvailable(daysAvailableItem);
		refreshMaximumYield();
	}
}

void SolarYieldModel::yieldValueChanged(QVariant value)
{
	Q_UNUSED(value)

	if (VeQItem *yieldItem = qobject_cast<VeQItem *>(sender())) {
		if (VeQItem *dayItem = yieldItem->itemParent()) {
			bool ok = false;
			const int day = dayItem->id().toInt(&ok);
			if (ok) {
				updateDayAt(day - m_firstDay);
				refreshMaximumYield();
			}
		}
	}
}

void SolarYieldModel::updateDayAt(int index)
{
	if (index >= 0 && index < m_dailyYields.count()) {
		DailyYield *dailyYield = &m_dailyYields[index];
		qreal totalYield = 0;
		for (auto it = dailyYield->yieldItems.begin(); it != dailyYield->yieldItems.end(); ++it) {
			if (it.value()) {
				totalYield += it.value()->getValue().value<qreal>();
			}
		}
		dailyYield->yieldKwh = totalYield;
		emit dataChanged(createIndex(index, 0), createIndex(index, 0), { YieldKwhRole });
	}
}

void SolarYieldModel::updateDaysAvailable(VeQItem *daysAvailableItem)
{
	if (!m_daysAvailableItems.contains(daysAvailableItem->uniqueId())) {
		// The value is no longer monitored.
		return;
	}

	if (VeQItem *overallItem = daysAvailableItem->itemParent()) {
		if (VeQItem *historyItem = overallItem->itemParent()) {
			for (int i = 0; i < m_dailyYields.count(); ++i) {
				const int day = i - m_firstDay;
				if (VeQItem *yieldItem = historyItem->itemGet(QStringLiteral("Daily/%1/Yield").arg(day))) {
					// Add entry for the available day.
					m_dailyYields[i].yieldItems.insert(yieldItem->uniqueId(), yieldItem);
					updateDayAt(i);
					connect(yieldItem, &VeQItem::valueChanged, this, &SolarYieldModel::yieldValueChanged);
				} else {
					// No entry is available for this day; remove yield item if it is present.
					const QString yieldItemUid = historyItem->uniqueId() + QStringLiteral("/Daily/%1/Yield").arg(day);
					if (VeQItem *yieldItem = m_dailyYields[i].yieldItems.take(yieldItemUid)) {
						yieldItem->disconnect(this);
						updateDayAt(i);
					}
				}
			}
		}
	}
}

void SolarYieldModel::refreshMaximumYield()
{
	qreal maxYield = 0;
	for (int i = 0; i < m_dailyYields.count(); ++i) {
		maxYield = std::max(maxYield, m_dailyYields.at(i).yieldKwh);
	}

	if (maxYield != m_maximumYield) {
		m_maximumYield = maxYield;
		emit maximumYieldChanged();
	}
}

bool SolarYieldModel::shouldMonitorDevice(Device *device) const
{
	if (!device) {
		return false;
	} else if (m_serviceUid.length() > 0) {
		return device->serviceUid() == m_serviceUid;
	} else {
		static const QStringList serviceTypes = {
			QStringLiteral("solarcharger"),
			QStringLiteral("multi"),
			QStringLiteral("inverter"),
		};
		return serviceTypes.indexOf(device->serviceType()) >= 0;
	}
}
