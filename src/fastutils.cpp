/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "fastutils.h"

namespace Victron {
namespace VenusOS {

FastUtils::FastUtils(QObject *parent)
	: QObject(parent)
{
}

FastUtils::~FastUtils()
{
}

// this properly belongs in a utils class, but there is no cpp utils currently.
QList<qreal> FastUtils::calculateLoadGraphYValues(const QList<qreal> &data, int dataLen, qreal height) const
{
	QList<qreal> ret;
	ret.reserve(dataLen);
	for (int i = 0; i < dataLen; ++i) {
		ret.append((1.0 - (data.count() <= i ? 0.0 : data[i])) * height);
	}
	return ret;
}

qreal FastUtils::degreesToRadians(const qreal degrees) const
{
	return degrees * 0.017453292519943295;  // Math.PI/180
}

}
}
