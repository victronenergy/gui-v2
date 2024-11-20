/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_UNITS_H
#define VICTRON_VENUSOS_GUI_V2_UNITS_H

#include <QtGlobal>
#include <QQmlEngine>
#include <QObject>


#include <veutil/qt/unit_conversion.hpp>

#include "enums.h"

namespace Victron {
namespace Units {

class quantityInfo
{
	Q_GADGET
	QML_ELEMENT
	Q_PROPERTY(QString number MEMBER number FINAL)
	Q_PROPERTY(QString unit MEMBER unit FINAL)
	Q_PROPERTY(VenusOS::Enums::Units_Scale scale MEMBER scale FINAL)

public:
	QString number;
	QString unit;
	VenusOS::Enums::Units_Scale scale = VenusOS::Enums::Units_Scale_None;
};

class Units : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON
	Q_PROPERTY(QString numberFormattingLocaleName READ numberFormattingLocaleName CONSTANT FINAL)

public:
	enum FormatHint {
		CompactUnitFormat = 0x1
	};
	Q_ENUM(FormatHint)
	Q_DECLARE_FLAGS(FormatHints, FormatHint)

	explicit Units(QObject *parent = nullptr);
	~Units() override;

	static QObject* instance(QQmlEngine *engine, QJSEngine *);

	QString numberFormattingLocaleName() const;
	Q_INVOKABLE QString formatNumber(qreal number, int precision = 0) const;
	Q_INVOKABLE qreal formattedNumberToReal(const QString &s) const;

	Q_INVOKABLE int defaultUnitPrecision(VenusOS::Enums::Units_Type unit) const;
	Q_INVOKABLE QString defaultUnitString(VenusOS::Enums::Units_Type unit, int formatHints = 0) const;

	Q_INVOKABLE QString scaleToString(VenusOS::Enums::Units_Scale scale) const;
	Q_INVOKABLE bool isScalingSupported(VenusOS::Enums::Units_Type unit) const;

	Q_INVOKABLE quantityInfo getDisplayText(
		VenusOS::Enums::Units_Type unit,
		qreal value,
		int precision = -1,
		qreal unitMatchValue = qQNaN()) const;

	quantityInfo getDisplayTextWithHysteresis(
		VenusOS::Enums::Units_Type unit,
		qreal value,
		VenusOS::Enums::Units_Scale previousScale,
		int precision = -1,
		qreal unitMatchValue = qQNaN(),
		int formatHints = 0) const;

	Q_INVOKABLE QString getCombinedDisplayText(
		VenusOS::Enums::Units_Type unit,
		qreal value,
		int precision = -1) const;

	Q_INVOKABLE QString getCapacityDisplayText(VenusOS::Enums::Units_Type unit,
		qreal capacity_m3,
		qreal remaining_m3) const;

	Q_INVOKABLE qreal convert(qreal value, VenusOS::Enums::Units_Type fromUnit, VenusOS::Enums::Units_Type toUnit) const;

	Q_INVOKABLE int unitToVeUnit(VenusOS::Enums::Units_Type unit) const;

	Q_INVOKABLE qreal sumRealNumbers(qreal a, qreal b) const;

	Q_INVOKABLE qreal sumRealNumbersList(const QList<qreal> &numbers) const;

	Q_INVOKABLE qreal scaleNumber(qreal n, qreal fromMin, qreal fromMax, qreal toMin, qreal toMax) const {
		const qreal fromRange = fromMax - fromMin;
		const qreal toRange = toMax - toMin;
		qreal normalized = qMax(fromMin, qMin(fromMax, n));
		return qFuzzyIsNull(fromRange) ? 0.0 : ((((normalized - fromMin) / fromRange) * toRange) + toMin);
	}

private:
	QString formatWindDirection(int degrees) const;
};

}
}

Q_DECLARE_OPERATORS_FOR_FLAGS(Victron::Units::Units::FormatHints)
Q_DECLARE_METATYPE(Victron::Units::quantityInfo)

#endif // VICTRON_VENUSOS_GUI_V2_UNITS_H
