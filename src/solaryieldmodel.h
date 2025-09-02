/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_SOLARYIELDMODEL_H
#define VICTRON_GUIV2_SOLARYIELDMODEL_H

#include <QAbstractListModel>
#include <QPointer>
#include <QQmlParserStatus>
#include <qqmlintegration.h>

#include <veutil/qt/ve_qitem.hpp>

namespace Victron {
namespace VenusOS {

class Device;

/*
	Provides a model of solar yield values (in KwH) for the specified days.

	If serviceUid is set, then the model only includes the history for that service. Otherwise, the
	model includes the yield for all solarcharger, multi and inverter services on the system with
	/History values.
*/
class SolarYieldModel : public QAbstractListModel, public QQmlParserStatus
{
	Q_OBJECT
	Q_INTERFACES(QQmlParserStatus)
	QML_ELEMENT
	Q_PROPERTY(int count READ count NOTIFY countChanged FINAL)
	Q_PROPERTY(qreal maximumYield READ maximumYield NOTIFY maximumYieldChanged FINAL)
	Q_PROPERTY(int firstDay READ firstDay WRITE setFirstDay NOTIFY firstDayChanged FINAL)
	Q_PROPERTY(int lastDay READ lastDay WRITE setLastDay NOTIFY lastDayChanged FINAL)
	Q_PROPERTY(QString serviceUid READ serviceUid WRITE setServiceUid NOTIFY serviceUidChanged FINAL)

public:
	enum Role {
		DayRole = Qt::UserRole,
		YieldKwhRole,
	};
	Q_ENUM(Role)

	explicit SolarYieldModel(QObject *parent = nullptr);

	int count() const;
	qreal maximumYield() const;

	int firstDay() const;
	void setFirstDay(int firstDay);

	int lastDay() const;
	void setLastDay(int lastDay);

	QString serviceUid() const;
	void setServiceUid(const QString &serviceUid);

	int rowCount(const QModelIndex &parent) const override;
	QVariant data(const QModelIndex& index, int role) const override;

	void classBegin() override;
	void componentComplete() override;

Q_SIGNALS:
	void countChanged();
	void firstDayChanged();
	void lastDayChanged();
	void maximumYieldChanged();
	void serviceUidChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;

private:
	struct DailyYield {
		QMap<QString, QPointer<VeQItem> > yieldItems;
		qreal yieldKwh = 0;
	};

	void sourceDeviceAdded(const QModelIndex &parent, int first, int last);
	void sourceDeviceAboutToBeRemoved(const QModelIndex &parent, int first, int last);
	void resetYields();
	void clearYields();
	void populateYields();
	void maybeAddHistoryForDevice(Device *device);
	void daysAvailableChanged(QVariant value);
	void yieldValueChanged(QVariant value);
	void updateDayAt(int day);
	void updateDaysAvailable(VeQItem *daysAvailableItem);
	void refreshMaximumYield();
	bool deviceMayHaveSolarHistory(Device *device) const;

	QMap<QString, QPointer<VeQItem> > m_daysAvailableItems;
	QVector<DailyYield> m_dailyYields;
	QString m_serviceUid;
	qreal m_maximumYield = 0;
	int m_firstDay = -1;
	int m_lastDay = -1;
	bool m_completed = false;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_SOLARYIELDMODEL_H
