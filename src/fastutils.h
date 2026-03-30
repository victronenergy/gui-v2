/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_FASTUTILS_H
#define VICTRON_VENUSOS_GUI_V2_FASTUTILS_H

#include <QQmlEngine>
#include <QObject>
#include <QFont>
#include <QColor>

#include "themeobjects.h"

class QQmlEngine;
class QJSEngine;

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
	Q_INVOKABLE qreal scaleNumber(qreal n, qreal fromMin, qreal fromMax, qreal toMin, qreal toMax) const {
		return scale(n, fromMin, fromMax, toMin, toMax);
	}
	Q_INVOKABLE QColor invalidColor() const { return QColor(); }

	static qreal scale(qreal n, qreal fromMin, qreal fromMax, qreal toMin, qreal toMax) {
		const qreal fromRange = fromMax - fromMin;
		const qreal toRange = toMax - toMin;
		const qreal normalized = qMax(fromMin, qMin(fromMax, n));
		return qFuzzyIsNull(fromRange) ? 0.0 : ((((normalized - fromMin) / fromRange) * toRange) + toMin);
	}

	static FastUtils* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);
};

/*
** Helper which takes a value in a min/max range and returns the value as a ratio.
** Useful for graphs and gauges.
*/

class ValueRange : public QObject
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(qreal minimumValue READ minimumValue WRITE setMinimumValue NOTIFY minimumValueChanged FINAL)
	Q_PROPERTY(qreal maximumValue READ maximumValue WRITE setMaximumValue NOTIFY maximumValueChanged FINAL)
	Q_PROPERTY(qreal value READ value WRITE setValue NOTIFY valueChanged FINAL)
	Q_PROPERTY(qreal valueAsRatio READ valueAsRatio NOTIFY valueAsRatioChanged FINAL)

public:
	qreal minimumValue() const { return m_minimumValue; }
	qreal maximumValue() const { return m_maximumValue; }
	qreal value() const { return m_value; }
	qreal valueAsRatio() const { return m_valueAsRatio; }

	void setMinimumValue(qreal v);
	void setMaximumValue(qreal v);
	void setValue(qreal v);

Q_SIGNALS:
	void minimumValueChanged();
	void maximumValueChanged();
	void valueChanged();
	void valueAsRatioChanged();

private:
	void updateValueAsRatio();
	qreal m_minimumValue = 0.0;
	qreal m_maximumValue = 0.0;
	qreal m_value = qQNaN();
	qreal m_valueAsRatio = 0.0;
};

}
}

#endif // VICTRON_VENUSOS_GUI_V2_FASTUTILS_H
