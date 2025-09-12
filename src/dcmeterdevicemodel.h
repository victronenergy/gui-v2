/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_DCMETERDEVICEMODEL_H
#define VICTRON_GUIV2_DCMETERDEVICEMODEL_H

#include <QtGlobal>
#include <QPointer>
#include <QAbstractListModel>
#include <QQmlParserStatus>

#include <veutil/qt/ve_qitem.hpp>

#include "device.h"

class QTimerEvent;

namespace Victron {
namespace VenusOS {

/*
	A model of DC meter devices.

	Set serviceTypes to the required DC meter types, such as "alternator" or "dcgenset".
	The meterType can also be set to additionally restrict the model to devices of that type.

	Note this model is not sorted.
*/
class DcMeterDeviceModel : public QAbstractListModel, public QQmlParserStatus
{
	Q_OBJECT
	QML_ELEMENT
	Q_INTERFACES(QQmlParserStatus)
	Q_PROPERTY(int count READ count NOTIFY countChanged FINAL)
	Q_PROPERTY(Device *firstObject READ firstObject NOTIFY firstObjectChanged FINAL)
	Q_PROPERTY(int firstMeterType READ firstMeterType NOTIFY firstMeterTypeChanged FINAL)
	Q_PROPERTY(QStringList serviceTypes READ serviceTypes WRITE setServiceTypes NOTIFY serviceTypesChanged FINAL)
	Q_PROPERTY(int meterType READ meterType WRITE setMeterType NOTIFY meterTypeChanged FINAL)
	Q_PROPERTY(qreal totalPower READ totalPower NOTIFY totalPowerChanged FINAL)
	Q_PROPERTY(qreal totalCurrent READ totalCurrent NOTIFY totalCurrentChanged FINAL)
public:
	enum Role {
		DeviceRole = Qt::UserRole,
	};
	Q_ENUM(Role)

	explicit DcMeterDeviceModel(QObject *parent = nullptr);
	~DcMeterDeviceModel();

	int count() const;
	Device *firstObject() const;
	int firstMeterType() const;

	qreal totalPower() const;
	qreal totalCurrent() const;

	QStringList serviceTypes() const;
	void setServiceTypes(const QStringList &serviceTypes);

	int meterType() const;
	void setMeterType(int meterType);

	QVariant data(const QModelIndex& index, int role) const override;
	int rowCount(const QModelIndex &parent) const override;

	void classBegin() override;
	void componentComplete() override;

	Q_INVOKABLE Device *deviceAt(int index) const; // Note: object has CppOwnership.
	Q_INVOKABLE int meterTypeAt(int index);

Q_SIGNALS:
	void countChanged();
	void firstObjectChanged();
	void serviceTypesChanged();
	void meterTypeChanged();
	void totalPowerChanged();
	void totalCurrentChanged();
	void firstMeterTypeChanged();

protected:
	QHash<int, QByteArray> roleNames() const override;
	void timerEvent(QTimerEvent *event) override;

private:
	struct DcMeter {
		void disconnect(DcMeterDeviceModel *model);

		int type = -1;
		QPointer<VeQItem> powerItem;
		QPointer<VeQItem> currentItem;
		Device *device = nullptr;
	};

	bool includeDevice(Device *device);
	int indexOf(const QString &serviceUid) const;
	void resetMeters();
	void clearMeters();
	void addMatchingMeters();
	void sourceDeviceAdded(const QModelIndex &parent, int first, int last);
	void sourceDeviceAboutToBeRemoved(const QModelIndex &parent, int first, int last);
	void addMeterDevice(Device *device);
	void scheduleUpdateTotals();
	void updateTotals();
	void updateFirstMeter();

	QVector<DcMeter> m_meters;
	QStringList m_serviceTypes;
	QString m_firstUid;
	qreal m_totalPower = 0;
	qreal m_totalCurrent = 0;
	int m_timerId = 0;
	int m_firstMeterType = -1;
	int m_meterType = -1;
	bool m_completed = false;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_DCMETERDEVICEMODEL_H

