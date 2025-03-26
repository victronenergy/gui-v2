/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_BASETANKDEVICEMODEL_H
#define VICTRON_GUIV2_BASETANKDEVICEMODEL_H

#include "basedevicemodel.h"

namespace Victron {
namespace VenusOS {

class BaseTankDevice;

class BaseTankDeviceModel : public BaseDeviceModel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int type READ type WRITE setType NOTIFY typeChanged)
	Q_PROPERTY(qreal averageLevel READ averageLevel WRITE setAverageLevel NOTIFY averageLevelChanged)
	Q_PROPERTY(qreal totalCapacity READ totalCapacity WRITE setTotalCapacity NOTIFY totalCapacityChanged)
	Q_PROPERTY(qreal totalRemaining READ totalRemaining WRITE setTotalRemaining NOTIFY totalRemainingChanged)

public:
	explicit BaseTankDeviceModel(QObject *parent = nullptr);

	int type() const;
	void setType(int type);

	qreal averageLevel() const;
	void setAverageLevel(qreal averageLevel);

	qreal totalCapacity() const;
	void setTotalCapacity(qreal totalCapacity);

	qreal totalRemaining() const;
	void setTotalRemaining(qreal totalRemaining);

	Q_INVOKABLE BaseTankDevice *tankAt(int index) const;

Q_SIGNALS:
	void typeChanged();
	void averageLevelChanged();
	void totalCapacityChanged();
	void totalRemainingChanged();

private:
	void modelRowsInserted(const QModelIndex &parent, int first, int last);
	void modelRowsRemoved(const QModelIndex &parent, int first, int last);
	void updateTotals();
	qreal sumOf(qreal a, qreal b) const;

	int m_type = 0;
	qreal m_averageLevel = qQNaN();
	qreal m_totalCapacity = qQNaN();
	qreal m_totalRemaining = qQNaN();
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_BASETANKDEVICEMODEL_H
