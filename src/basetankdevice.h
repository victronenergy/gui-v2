/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_BASETANKDEVICE_H
#define VICTRON_GUIV2_BASETANKDEVICE_H

#include <qqmlintegration.h>
#include <QtGlobal>

#include "basedevice.h"

namespace Victron {
namespace VenusOS {

class BaseTankDevice : public BaseDevice
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int type READ type WRITE setType NOTIFY typeChanged)
	Q_PROPERTY(qreal level READ level WRITE setLevel NOTIFY levelChanged)
	Q_PROPERTY(qreal capacity READ capacity WRITE setCapacity NOTIFY capacityChanged)
	Q_PROPERTY(qreal remaining READ remaining WRITE setRemaining NOTIFY remainingChanged)

public:
	explicit BaseTankDevice(QObject *parent = nullptr);

	int type() const;
	void setType(int type);

	// 0 to 100, as a percentage
	qreal level() const;
	void setLevel(qreal level);

	qreal capacity() const;
	void setCapacity(qreal capacity);

	qreal remaining() const;
	void setRemaining(qreal remaining);

Q_SIGNALS:
	void typeChanged();
	void levelChanged();
	void capacityChanged();
	void remainingChanged();

private:
	void updateMeasurements(const qreal prevLevel, const qreal prevCacpacity, const qreal prevRemaining);

	int m_type = 0;
	qreal m_level = qQNaN();
	qreal m_capacity = qQNaN();
	qreal m_remaining = qQNaN();
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_BASETANKDEVICE_H
