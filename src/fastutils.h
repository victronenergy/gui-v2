/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_FASTUTILS_H
#define VICTRON_VENUSOS_GUI_V2_FASTUTILS_H

#include <QQmlEngine>
#include <QObject>
#include <QFont>

#include "themeobjects.h"

namespace Victron {
namespace VenusOS {

/*
** Similar to Utils.js but in C++ so it's much faster.
** Obviously, we cannot do JavaScript-specific mutations here,
** but for many use-cases, it's far more efficient to define them here.
*/

class FastUtils : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON

public:
	explicit FastUtils(QObject *parent = nullptr);
	~FastUtils() override;

	Q_INVOKABLE QList<qreal> calculateLoadGraphYValues(const QList<qreal> &data, int dataLen, qreal height) const;
	Q_INVOKABLE qreal degreesToRadians(const qreal degrees) const;
	Q_INVOKABLE int fittedPixelSize(const QString &text, const qreal maxWidth, int minPixelSize, int maxPixelSize, const QFont &font, ThemeSingleton *theme = nullptr) const;
};

}
}

#endif // VICTRON_VENUSOS_GUI_V2_FASTUTILS_H
