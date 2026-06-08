/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "units.h"
#include "enums.h"

#include <veutil/qt/unit_conversion.hpp>

#include <QtMath>

namespace {

// \u33A5 is not supported by the font
static const QString CubicMetre = QStringLiteral("\u006D\u00B3");
static const QString DegreesSymbol = QStringLiteral("\u00b0");
static const QString LitreSymbol = QStringLiteral("\u2113");
static const QString EmptyString = QString();

struct UnitMetaData {
	QString label;
	Victron::VenusOS::Enums::Units_Type unit = Victron::VenusOS::Enums::Units_None;
	Victron::VenusOS::Enums::Units_Scale maximumScale = Victron::VenusOS::Enums::Units_Scale_None;
	Unit::Type veUnit = Unit::Default;
	int decimals = 0;
};

static const std::vector<UnitMetaData> UnitTable {
	//              label    unit                                                       maximumScale                                    veUnit                          defaultDecimals
	{         EmptyString,   Victron::VenusOS::Enums::Units_None,                       Victron::VenusOS::Enums::Units_Scale_None,      Unit::Default,                  0   },
	{                 "A",   Victron::VenusOS::Enums::Units_Amp,                        Victron::VenusOS::Enums::Units_Scale_Tera,      Unit::Default,                  1   },
	{                "Ah",   Victron::VenusOS::Enums::Units_AmpHour,                    Victron::VenusOS::Enums::Units_Scale_Tera,      Unit::Default,                  1   },
	{             "Ah/km",   Victron::VenusOS::Enums::Units_AmpHourPerKilometre,        Victron::VenusOS::Enums::Units_Scale_None,      Unit::AmpHourPerKilometre,      0   },
	{             "Ah/mi",   Victron::VenusOS::Enums::Units_AmpHourPerMile,             Victron::VenusOS::Enums::Units_Scale_None,      Unit::AmpHourPerMile,           0   },
	{             "Ah/NM",   Victron::VenusOS::Enums::Units_AmpHourPerNauticalMile,     Victron::VenusOS::Enums::Units_Scale_None,      Unit::AmpHourPerNauticalMile,   0   },
	{       DegreesSymbol,   Victron::VenusOS::Enums::Units_CardinalDirection,          Victron::VenusOS::Enums::Units_Scale_None,      Unit::Default,                  0   },
	{               "kWh",   Victron::VenusOS::Enums::Units_Energy_KiloWattHour,        Victron::VenusOS::Enums::Units_Scale_Tera,      Unit::Default,                  3   },
	{                "ft",   Victron::VenusOS::Enums::Units_Foot,                       Victron::VenusOS::Enums::Units_Scale_None,      Unit::Foot,                     0   },
	{               "hPa",   Victron::VenusOS::Enums::Units_Hectopascal,                Victron::VenusOS::Enums::Units_Scale_None,      Unit::Default,                  1   },
	{                "Hz",   Victron::VenusOS::Enums::Units_Hertz,                      Victron::VenusOS::Enums::Units_Scale_Tera,      Unit::Default,                  1   },
	{                "km",   Victron::VenusOS::Enums::Units_Kilometre,                  Victron::VenusOS::Enums::Units_Scale_None,      Unit::Kilometre,                0   },
	{               "kPa",   Victron::VenusOS::Enums::Units_Kilopascal,                 Victron::VenusOS::Enums::Units_Scale_None,      Unit::Default,                  0   },
	{               "lux",   Victron::VenusOS::Enums::Units_Lux,                        Victron::VenusOS::Enums::Units_Scale_None,      Unit::Default,                  0   },
	{                 "m",   Victron::VenusOS::Enums::Units_Metre,                      Victron::VenusOS::Enums::Units_Scale_Kilo,      Unit::Metre,                    0   },
	{  "µg/" + CubicMetre,   Victron::VenusOS::Enums::Units_MicrogramPerCubicMeter,     Victron::VenusOS::Enums::Units_Scale_None,      Unit::Default,                  1   },
	{                "mi",   Victron::VenusOS::Enums::Units_Mile,                       Victron::VenusOS::Enums::Units_Scale_None,      Unit::Mile,                     0   },
	{                "NM",   Victron::VenusOS::Enums::Units_Nautical_Mile,              Victron::VenusOS::Enums::Units_Scale_None,      Unit::NauticalMile,             0   },
	{                "Nm",   Victron::VenusOS::Enums::Units_NewtonMeter,                Victron::VenusOS::Enums::Units_Scale_None,      Unit::Default,                  0   },
	{               "ppm",   Victron::VenusOS::Enums::Units_PartsPerMillion,            Victron::VenusOS::Enums::Units_Scale_None,      Unit::Default,                  0   },
	{                 "%",   Victron::VenusOS::Enums::Units_Percentage,                 Victron::VenusOS::Enums::Units_Scale_None,      Unit::Default,                  0   },
	{         EmptyString,   Victron::VenusOS::Enums::Units_PowerFactor,                Victron::VenusOS::Enums::Units_Scale_None,      Unit::Default,                  3   },
	{               "RPM",   Victron::VenusOS::Enums::Units_RevolutionsPerMinute,       Victron::VenusOS::Enums::Units_Scale_None,      Unit::RevolutionsPerMinute,     0   },
	{              "km/h",   Victron::VenusOS::Enums::Units_Speed_KilometresPerHour,    Victron::VenusOS::Enums::Units_Scale_None,      Unit::KilometresPerHour,        0   },
	{                "kn",   Victron::VenusOS::Enums::Units_Speed_Knots,                Victron::VenusOS::Enums::Units_Scale_None,      Unit::Knots,                    0   },
	{               "m/s",   Victron::VenusOS::Enums::Units_Speed_MetresPerSecond,      Victron::VenusOS::Enums::Units_Scale_Kilo,      Unit::MetresPerSecond,          0   },
	{               "mph",   Victron::VenusOS::Enums::Units_Speed_MilesPerHour,         Victron::VenusOS::Enums::Units_Scale_None,      Unit::MilesPerHour,             0   },
	{ DegreesSymbol + "C",   Victron::VenusOS::Enums::Units_Temperature_Celsius,        Victron::VenusOS::Enums::Units_Scale_None,      Unit::Celsius,                  0   },
	{ DegreesSymbol + "F",   Victron::VenusOS::Enums::Units_Temperature_Fahrenheit,     Victron::VenusOS::Enums::Units_Scale_None,      Unit::Fahrenheit,               0   },
	{ DegreesSymbol + "K",   Victron::VenusOS::Enums::Units_Temperature_Kelvin,         Victron::VenusOS::Enums::Units_Scale_None,      Unit::Kelvin,                   0   },
	{                 "d",   Victron::VenusOS::Enums::Units_Time_Day,                   Victron::VenusOS::Enums::Units_Scale_None,      Unit::Default,                  0   },
	{                 "h",   Victron::VenusOS::Enums::Units_Time_Hour,                  Victron::VenusOS::Enums::Units_Scale_None,      Unit::Default,                  0   },
	{                 "m",   Victron::VenusOS::Enums::Units_Time_Minute,                Victron::VenusOS::Enums::Units_Scale_None,      Unit::Default,                  0   },
	{                 "s",   Victron::VenusOS::Enums::Units_Time_Second,                Victron::VenusOS::Enums::Units_Scale_None,      Unit::Default,                  0   },
	{                "VA",   Victron::VenusOS::Enums::Units_VoltAmpere,                 Victron::VenusOS::Enums::Units_Scale_Tera,      Unit::Default,                  1   },
	{               "var",   Victron::VenusOS::Enums::Units_VoltAmpereReactive,         Victron::VenusOS::Enums::Units_Scale_Tera,      Unit::Default,                  1   },
	{                 "V",   Victron::VenusOS::Enums::Units_Volt_AC,                    Victron::VenusOS::Enums::Units_Scale_Tera,      Unit::Default,                  1   },
	{                 "V",   Victron::VenusOS::Enums::Units_Volt_DC,                    Victron::VenusOS::Enums::Units_Scale_Tera,      Unit::Default,                  2   },
	{          CubicMetre,   Victron::VenusOS::Enums::Units_Volume_CubicMetre,          Victron::VenusOS::Enums::Units_Scale_None,      Unit::CubicMetre,               3   },
	{               "gal",   Victron::VenusOS::Enums::Units_Volume_GallonImperial,      Victron::VenusOS::Enums::Units_Scale_None,      Unit::ImperialGallon,           0   },
	{               "gal",   Victron::VenusOS::Enums::Units_Volume_GallonUS,            Victron::VenusOS::Enums::Units_Scale_None,      Unit::UsGallon,                 0   },
	{         LitreSymbol,   Victron::VenusOS::Enums::Units_Volume_Litre,               Victron::VenusOS::Enums::Units_Scale_Kilo,      Unit::Litre,                    0   },
	{                 "W",   Victron::VenusOS::Enums::Units_Watt,                       Victron::VenusOS::Enums::Units_Scale_Tera,      Unit::Default,                  0   },
	{              "W/m2",   Victron::VenusOS::Enums::Units_WattsPerSquareMetre,        Victron::VenusOS::Enums::Units_Scale_Tera,      Unit::Default,                  0   },
	{             "Wh/km",   Victron::VenusOS::Enums::Units_WattHourPerKilometre,       Victron::VenusOS::Enums::Units_Scale_None,      Unit::WattHourPerKilometre,     0   },
	{             "Wh/mi",   Victron::VenusOS::Enums::Units_WattHourPerMile,            Victron::VenusOS::Enums::Units_Scale_None,      Unit::WattHourPerMile,          0   },
	{             "Wh/NM",   Victron::VenusOS::Enums::Units_WattHourPerNauticalMile,    Victron::VenusOS::Enums::Units_Scale_None,      Unit::WattHourPerNauticalMile,  0   },
};

inline const UnitMetaData &unitMeta(Victron::VenusOS::Enums::Units_Type unit)
{
	const auto index = static_cast<std::size_t>(unit);
	Q_ASSERT(index < UnitTable.size());
	Q_ASSERT(UnitTable[index].unit == unit);
	Q_ASSERT(unit >= Victron::VenusOS::Enums::Units_None && unit <= Victron::VenusOS::Enums::Units_Type_Max);
	if (unit < Victron::VenusOS::Enums::Units_None || unit > Victron::VenusOS::Enums::Units_Type_Max) {
		return UnitTable[Victron::VenusOS::Enums::Units_None];
	}
	return UnitTable[index];
}

Unit::Type unitToVeUnit(Victron::VenusOS::Enums::Units_Type unit)
{
	return unitMeta(unit).veUnit;
}

const QLocale *formattingLocale()
{
	static const QLocale locale = QLocale::c();
	return &locale;
}

}

namespace Victron {
namespace Units {

QObject* Units::instance(QQmlEngine *, QJSEngine *)
{
	static QObject* units = new Units;
	return units;
}

Units::Units(QObject *parent)
	: QObject(parent)
{
}

Units::~Units()
{
}

QString Units::numberFormattingLocaleName() const
{
	return formattingLocale()->name();
}

QString Units::degreesSymbol() const
{
	return DegreesSymbol;
}

QString Units::formatNumber(qreal number, int precision) const
{
	return formattingLocale()->toString(number, 'f', precision);
}

qreal Units::formattedNumberToReal(const QString &s) const
{
	bool ok = false;
	const double d = formattingLocale()->toDouble(s, &ok);
	return ok ? d : qQNaN();
}

QString Units::formatLatitude(qreal latitude, VenusOS::Enums::GpsData_Format format) const
{
	return formatCoordinate(latitude, format,
			latitude >= 0
				? VenusOS::Enums::CardinalDirection_North
				: VenusOS::Enums::CardinalDirection_South);
}

QString Units::formatLongitude(qreal longitude, VenusOS::Enums::GpsData_Format format) const
{
	return formatCoordinate(longitude, format,
			longitude >= 0
				? VenusOS::Enums::CardinalDirection_East
				: VenusOS::Enums::CardinalDirection_West);
}

QString Units::formatCoordinate(qreal decimalDegrees, VenusOS::Enums::GpsData_Format format, VenusOS::Enums::CardinalDirection direction) const
{
	const double degrees = std::abs(decimalDegrees);
	const double minutes = std::fmod(degrees, 1) * 60.0;
	const double seconds = std::fmod(minutes, 1) * 60.0;

	switch (format) {
	case VenusOS::Enums::GpsData_Format_DegreesMinutesSeconds: // e.g. 52° 20' 41.6" N
		return QString("%1%2 %3' %4\" %5")
				.arg(formatNumber(std::floor(degrees)))
				.arg(DegreesSymbol)
				.arg(formatNumber(std::floor(minutes)))
				.arg(formatNumber(seconds, 1))
				.arg(VenusOS::Enums::create()->cardinalDirectionToShortText(direction));
	case VenusOS::Enums::GpsData_Format_DecimalDegrees: // e.g. 52.34489
		return formatNumber(decimalDegrees, 6);
	case VenusOS::Enums::GpsData_Format_DegreesMinutes: // e.g. 52° 20.693 N
		return QString("%1%2 %3 %4")
				.arg(formatNumber(std::floor(degrees)))
				.arg(DegreesSymbol)
				.arg(formatNumber(minutes, 4))
				.arg(VenusOS::Enums::create()->cardinalDirectionToShortText(direction));
	}
	return QString();
}

int Units::defaultUnitDecimals(VenusOS::Enums::Units_Type unit) const
{
	return unitMeta(unit).decimals;
}

QString Units::defaultUnitString(VenusOS::Enums::Units_Type unit, Victron::Units::Units::FormatHints formatHints) const
{
	if ((formatHints & CompactUnitFormat)
		&& (unit == VenusOS::Enums::Units_Type::Units_Temperature_Celsius
			|| unit == VenusOS::Enums::Units_Type::Units_Temperature_Fahrenheit
			|| unit == VenusOS::Enums::Units_Type::Units_Temperature_Kelvin)) {
		return DegreesSymbol;
	}

	return unitMeta(unit).label;
}

VenusOS::Enums::Units_Scale Units::maximumUnitScale(VenusOS::Enums::Units_Type unit) const
{
	return unitMeta(unit).maximumScale;
}

QString Units::scaleToString(VenusOS::Enums::Units_Scale scale) const {
	switch (scale) {
	case VenusOS::Enums::Units_Scale_Tera:
		return QStringLiteral("T");
	case VenusOS::Enums::Units_Scale_Giga:
		return QStringLiteral("G");
	case VenusOS::Enums::Units_Scale_Mega:
		return QStringLiteral("M");
	case VenusOS::Enums::Units_Scale_Kilo:
		return QStringLiteral("k");
	case VenusOS::Enums::Units_Scale_None:
	default:
		return QString();
	}
}

// Returns the physical quantity as a tuple of strings: { number, unit }.
// The number and unit string are displayed as scaled if the absolute value
// grows high enough (kilo, mega, giga, tera).
quantityInfo Units::getDisplayText(
	VenusOS::Enums::Units_Type unit,
	qreal value,
	int decimals,
	Victron::Units::Units::FormatHints formatHints,
	qreal unitMatchValue) const
{
	return getDisplayTextWithHysteresis(unit, value, VenusOS::Enums::Units_Scale_None /* skip hysteresis */, decimals, formatHints, unitMatchValue);
}

quantityInfo Units::getDisplayTextWithHysteresis(VenusOS::Enums::Units_Type unit,
	qreal value,
	VenusOS::Enums::Units_Scale previousScale,
	int decimals,
	Victron::Units::Units::FormatHints formatHints,
	qreal unitMatchValue) const
{
	// value unknown
	if (qIsNaN(value)) {
		quantityInfo qty;
		qty.number = QStringLiteral("--");
		qty.unit = defaultUnitString(unit, formatHints);
		return qty;
	}

	quantityInfo quantity;
	quantity.unit = defaultUnitString(unit, formatHints);
	quantity.scale = VenusOS::Enums::Units_Scale_None;

	// For Watts, floor values with magnitude less than 1.0 W.
	// This ensures we ignore potential noise values.
	if (unit == VenusOS::Enums::Units_Watt && qAbs(value) < 1.0) {
		quantity.number = formattingLocale()->toString(0.0, 'f', 0);
		return quantity;
	}

	// For Percentages with zero decimal places, if the value is between 99% and 99.9%,
	// always show 99% so that it's clear that it's not completely full.
	if (unit == VenusOS::Enums::Units_Percentage && (decimals == 0 || decimals == -1) && value > 99) {
		quantity.number = value < 99.9
			? formattingLocale()->toString(99.0, 'f', 0)
			: formattingLocale()->toString(100.0, 'f', 0);
		return quantity;
	}

	if (unit == VenusOS::Enums::Units_CardinalDirection) {
		value = fmod(value + 360, 360);
		quantity.unit += " " + formatWindDirection(static_cast<int>(value));
	}

	qreal scaledValue = value;

	// scale value if the unit of measure is scalable
	// check format hints for display override value
	const Victron::VenusOS::Enums::Units_Scale maxScale = maximumUnitScale(unit);
	if (maxScale > VenusOS::Enums::Units_Scale_None && !(formatHints & Units::FormatHint::NoScaling)) {
		qreal scaleMatch = !qIsNaN(unitMatchValue) ? unitMatchValue : scaledValue;

		// Kilowatthour is already in kilos, normalize to plain watthours before scaling
		if (unit == VenusOS::Enums::Units_Energy_KiloWattHour) {
			quantity.unit = QStringLiteral("Wh");
			scaledValue = 1000.0 * scaledValue;
			scaleMatch = 1000.0 * scaleMatch;
		}

		const QList<VenusOS::Enums::Units_Scale> scales = {
			VenusOS::Enums::Units_Scale_Tera,
			VenusOS::Enums::Units_Scale_Giga,
			VenusOS::Enums::Units_Scale_Mega,
			VenusOS::Enums::Units_Scale_Kilo,
		};

		auto isOverLimit = [](qreal value, VenusOS::Enums::Units_Scale scale, VenusOS::Enums::Units_Scale previousScale) {
			// Implement hysteresis: Move to larger scale unit when value is over 10*scale,
			// but only move back to smaller scale when value drops below 9*scale.
			bool wasPreviousScale = scale == previousScale;

			// Kilo scale has 10k limit, other scales grow by 1k
			qreal multiplier = wasPreviousScale ? 0.9 : 1;
			if (scale == VenusOS::Enums::Units_Scale_Kilo) {
				multiplier = wasPreviousScale ? 9 : 10;
			}

			return qAbs(value) >= multiplier*qPow(10, 3*scale);
		};

		// For some units, do not scale beyond the kilo range, as we don't want to display them in
		// mega/tera/giga format.
		if (maxScale == VenusOS::Enums::Units_Scale_Kilo) {
			if (isOverLimit(scaleMatch, VenusOS::Enums::Units_Scale_Kilo, previousScale)) {
				quantity.unit = QStringLiteral("k%1").arg(defaultUnitString(unit));
				quantity.scale = VenusOS::Enums::Units_Scale_Kilo;
				scaledValue = scaledValue / 1000.0;
			}
		} else {
			for (const auto scale : scales) {
				if (isOverLimit(scaleMatch, scale, previousScale)) {
					quantity.unit = scaleToString(scale) + quantity.unit;
					quantity.scale = scale;
					scaledValue = scaledValue / qPow(10, 3*scale);
					break;
				}
			}

			// If value is zero prefer kWh instead of Wh
			if (scaledValue == 0 && unit == VenusOS::Enums::Units_Energy_KiloWattHour) {
				quantity.unit = defaultUnitString(unit, formatHints);
			}
		}
	}

	auto numberOfDigits = [](int value) -> int {
		int digits = 0;
		while (value) {
			value /= 10;
			digits++;
		}
		return digits;
	};

	// If kilowatt-hours have not been scaled avoid decimals
	if (!(formatHints & Units::FormatHint::NoDecimalAdjustment) && quantity.scale == VenusOS::Enums::Units_Scale_None && unit == VenusOS::Enums::Units_Energy_KiloWattHour) {
		decimals = 0;
	}

	// If the scaled value is large then possibly clip the decimals by 1 or 2 fractional digits depending on initial decimals.
	// Only apply this logic to scaled values with 2 non fractional digits if the units are not Units_Volt_DC.
	// i.e. don't clip decimals for values like 53.35 V DC.
	decimals = decimals < 0 ? defaultUnitDecimals(unit) : decimals;
	const int digits = numberOfDigits(static_cast<int>(scaledValue));
	if (!(formatHints & Units::FormatHint::NoDecimalAdjustment) && (unit != VenusOS::Enums::Units_Volt_DC || digits > 2)) {
		if (digits >= 4) {
			decimals = 0;
		} else if (digits == 3) {
			decimals = decimals >= 3 ? 1 : 0;
		} else if (digits == 2) {
			decimals = decimals >= 3 ? 2
				: decimals >= 1 ? 1
				: 0;
		}
	}

	const qreal vFixedMultiplier = std::pow(10, decimals);
	const int vFixed = qRound(scaledValue * vFixedMultiplier);
	scaledValue = (1.0*vFixed) / vFixedMultiplier;
	quantity.number = formattingLocale()->toString(scaledValue, 'f', decimals);

	return quantity;
}

QString Units::getCombinedDisplayText(VenusOS::Enums::Units_Type unit, qreal value, int decimals, Victron::Units::Units::FormatHints formatHints) const
{
	const int d = decimals < 0 ? defaultUnitDecimals(unit) : decimals;
	const quantityInfo qty = getDisplayText(unit, value, d, formatHints);
	if (qty.number.compare(QStringLiteral("--")) == 0) {
		return qty.number;
	}
	return QStringLiteral("%1%2").arg(qty.number, qty.unit);
}

QString Units::getCapacityDisplayText(
	VenusOS::Enums::Units_Type unit,
	qreal capacity_m3,
	qreal remaining_m3) const
{
	const qreal capacity = convert(capacity_m3, VenusOS::Enums::Units_Volume_CubicMetre, unit);
	const qreal remaining = convert(remaining_m3, VenusOS::Enums::Units_Volume_CubicMetre, unit);

	const int decimals = defaultUnitDecimals(unit);
	const quantityInfo c = getDisplayText(unit, capacity, decimals);
	const quantityInfo r = getDisplayText(unit, remaining, decimals, Victron::Units::Units::FormatHint::NoFormatHints, capacity);
	return QStringLiteral("%1/%2%3").arg(r.number, c.number, c.unit);
}

qreal Units::convert(qreal value, VenusOS::Enums::Units_Type fromUnit, VenusOS::Enums::Units_Type toUnit) const
{
	if (fromUnit == toUnit) {
		return value;
	}
	if (qIsNaN(value)
			|| fromUnit == VenusOS::Enums::Units_None
			|| toUnit == VenusOS::Enums::Units_None) {
		return qQNaN();
	}

	Unit::Type fromVeUnit = ::unitToVeUnit(fromUnit);
	if (fromVeUnit == Unit::Default) {
		qWarning() << "convert() does not support conversion from unit:" << fromUnit;
		return value;
	}
	Unit::Type toVeUnit = ::unitToVeUnit(toUnit);
	if (toVeUnit == Unit::Default) {
		qWarning() << "convert() does not support conversion to unit:" << toUnit;
		return value;
	}
	return UnitConverters::instance().convert(value, fromVeUnit, toVeUnit);
}

// This considers whether the values are NaN. If both are NaN, the result is NaN.
qreal Units::sumRealNumbers(qreal a, qreal b) const
{
	const bool aNaN = qIsNaN(a);
	const bool bNaN = qIsNaN(b);

	return (aNaN && bNaN) ? qQNaN()
		: aNaN ? b
		: bNaN ? a
		: (a+b);
}

qreal Units::sumRealNumbersList(const QList<qreal> &numbers) const
{
	qreal total = 0;
	for (qreal n : numbers) {
		total += (qIsNaN(n) ? 0 : n);
	}
	return total;
}

int Units::unitToVeUnit(VenusOS::Enums::Units_Type unit) const
{
	return static_cast<int>(::unitToVeUnit(unit));
}

QString Units::formatWindDirection(int degrees) const {
	const QString directions[] = {
		//% "N"
		qtTrId("direction_north"),
		//% "NE"
		qtTrId("direction_northeast"),
		//% "E"
		qtTrId("direction_east"),
		//% "SE"
		qtTrId("direction_southeast"),
		//% "S"
		qtTrId("direction_south"),
		//% "SW"
		qtTrId("direction_southwest"),
		//% "W"
		qtTrId("direction_west"),
		//% "NW"
		qtTrId("direction_northwest")
	};
	const int index = static_cast<int>((degrees + 22.5) / 45.0) % 8;
	return directions[index];
}

} // Units
} // Victron
