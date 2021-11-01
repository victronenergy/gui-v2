/*
** Copyright (C) 2021 Victron Energy B.V.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_THEME_H
#define VICTRON_VENUSOS_GUI_V2_THEME_H

#include <QtQml/qqmlregistration.h>
#include <QtCore/QObject>
#include <QtCore/QVariant>
#include <QtCore/QVector>
#include <QtGui/QColor>

namespace Victron {

namespace VenusOS {

class Theme : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(DisplayMode displayMode READ displayMode WRITE setDisplayMode NOTIFY displayModeChanged)
	Q_PROPERTY(QColor backgroundColor READ backgroundColor NOTIFY backgroundColorChanged)
	Q_PROPERTY(QColor primaryFontColor READ primaryFontColor NOTIFY primaryFontColorChanged)
	Q_PROPERTY(QColor secondaryFontColor READ secondaryFontColor NOTIFY secondaryFontColorChanged)
	Q_PROPERTY(QColor highlightColor READ highlightColor NOTIFY highlightColorChanged)
	Q_PROPERTY(QColor dimColor READ dimColor NOTIFY dimColorChanged)
	Q_PROPERTY(QColor weatherColor READ weatherColor CONSTANT)
	Q_PROPERTY(QColor okColor READ okColor NOTIFY okColorChanged)
	Q_PROPERTY(QColor okSecondaryColor READ okSecondaryColor NOTIFY okSecondaryColorChanged)
	Q_PROPERTY(QColor warningColor READ warningColor NOTIFY warningColorChanged)
	Q_PROPERTY(QColor warningSecondaryColor READ warningSecondaryColor NOTIFY warningSecondaryColorChanged)
	Q_PROPERTY(QColor criticalColor READ criticalColor NOTIFY criticalColorChanged)
	Q_PROPERTY(QColor criticalSecondaryColor READ criticalSecondaryColor NOTIFY criticalSecondaryColorChanged)
	Q_PROPERTY(int fontSizeMedium READ fontSizeMedium CONSTANT)
	Q_PROPERTY(int marginSmall READ marginSmall CONSTANT)
	Q_PROPERTY(int horizontalPageMargin READ horizontalPageMargin CONSTANT)
	Q_PROPERTY(int iconSizeMedium READ iconSizeMedium CONSTANT)
	Q_PROPERTY(ScreenSize screenSize READ screenSize WRITE setScreenSize NOTIFY screenSizeChanged)

public:
	enum DisplayMode {
		Light = 0,
		Dark,
	};
	Q_ENUM(DisplayMode)

	enum ScreenSize {
		FiveInch800x480,
		SevenInch1024x600
	};
	Q_ENUM(ScreenSize)

	enum ColorProperty {
		BackgroundColor = 0,
		PrimaryFontColor,
		SecondaryFontColor,
		HighlightColor,
		DimColor,
		OkColor,
		OkSecondaryColor,
		WarningColor,
		WarningSecondaryColor,
		CriticalColor,
		CriticalSecondaryColor
	};
	Q_ENUM(ColorProperty)

	enum OtherProperty {
		FontSizeMedium = 0,
		MarginSmall,
		HorizontalPageMargin,
		IconSizeMedium,
		WeatherColor, /* The color of the weather details is the same in both Light and Dark modes */
	};
	Q_ENUM(OtherProperty)

	enum StatusLevel {
		Ok = 0,
		Warning,
		Critical
	};
	Q_ENUM(StatusLevel)

	Q_INVOKABLE QColor colorValue(DisplayMode mode, ColorProperty role) const;
	Q_INVOKABLE QVariant otherValue(OtherProperty role) const;
	Q_INVOKABLE QString displayModeToString(DisplayMode mode) const;
	Q_INVOKABLE QString screenSizeToString(ScreenSize screenSize) const;

	Q_INVOKABLE QColor statusColorValue(StatusLevel level, bool secondaryColor = false) const;

	DisplayMode displayMode() const;
	void setDisplayMode(DisplayMode mode);
	void setScreenSize(ScreenSize screenSize);

	QColor backgroundColor() const;
	QColor primaryFontColor() const;
	QColor secondaryFontColor() const;
	QColor highlightColor() const;
	QColor dimColor() const;
	QColor weatherColor() const;
	QColor okColor() const;
	QColor okSecondaryColor() const;
	QColor warningColor() const;
	QColor warningSecondaryColor() const;
	QColor criticalColor() const;
	QColor criticalSecondaryColor() const;

	int fontSizeMedium() const;
	int marginSmall() const;
	int horizontalPageMargin() const;
	int iconSizeMedium() const;
	ScreenSize screenSize() const;

Q_SIGNALS:
	void displayModeChanged();
	void backgroundColorChanged();
	void primaryFontColorChanged();
	void secondaryFontColorChanged();
	void highlightColorChanged();
	void dimColorChanged();
	void okColorChanged();
	void okSecondaryColorChanged();
	void warningColorChanged();
	void warningSecondaryColorChanged();
	void criticalColorChanged();
	void criticalSecondaryColorChanged();
	void screenSizeChanged();

private:
	DisplayMode m_displayMode =  Dark;
	ScreenSize m_screenSize = FiveInch800x480;

	/* these values depend on the currently selected displayMode */
	QVector<QVector<QVariant> > m_colorValues {
		/* [Light] */
		{
			/* [BackgroundColor] */
			QVariant::fromValue<QColor>(QColor(230, 229, 225)),
			/* [PrimaryFontColor] */
			QVariant::fromValue<QColor>(QColor(39, 38, 34)),
			/* [SecondaryFontColor] */
			QVariant::fromValue<QColor>(QColor(150, 149, 145)),
			/* [HighlightColor] */
			QVariant::fromValue<QColor>(QColor(5, 111, 255)),
			/* [DimColor] */
			QVariant::fromValue<QColor>(QColor(5, 55, 122)),
			/* [OkColor] */
			QVariant::fromValue<QColor>(QColor(56, 125, 197)),
			/* [OkSecondaryColor] */
			QVariant::fromValue<QColor>(QColor(195, 208, 219)),
			/* [WarningColor] */
			QVariant::fromValue<QColor>(QColor(240, 150, 46)),
			/* [WarningSecondaryColor] */
			QVariant::fromValue<QColor>(QColor(232, 213, 189)),
			/* [CriticalColor] */
			QVariant::fromValue<QColor>(QColor(243, 92, 88)),
			/* [CriticalSecondaryColor] */
			QVariant::fromValue<QColor>(QColor(233, 202, 198)),
		},
		/* [Dark] */
		{
			/* [BackgroundColor] */
			QVariant::fromValue<QColor>(QColor(00, 00, 00)),
			/* [PrimaryFontColor] */
			QVariant::fromValue<QColor>(QColor(255, 255, 255)),
			/* [SecondaryFontColor] */
			QVariant::fromValue<QColor>(QColor(100, 99, 95)),
			/* [HighlightColor] */
			QVariant::fromValue<QColor>(QColor(5, 111, 255)),
			/* [DimColor] */
			QVariant::fromValue<QColor>(QColor(5, 55, 122)),
			/* [OkColor] */
			QVariant::fromValue<QColor>(QColor(56, 125, 197)),
			/* [OkSecondaryColor] */
			QVariant::fromValue<QColor>(QColor(17, 37, 59)),
			/* [WarningColor] */
			QVariant::fromValue<QColor>(QColor(240, 150, 46)),
			/* [WarningSecondaryColor] */
			QVariant::fromValue<QColor>(QColor(72, 45, 14)),
			/* [CriticalColor] */
			QVariant::fromValue<QColor>(QColor(243, 92, 88)),
			/* [CriticalSecondaryColor] */
			QVariant::fromValue<QColor>(QColor(73, 28, 26)),
		}
	};

	/* these values do not depend on the currently selected displayMode */
	QVector<QVariant> m_otherValues {
		/* [FontSizeMedium] */
		18,
		/* [MarginSmall] */
		7,
		/* [HorizontalPageMargin] */
		24,
		/* [IconSizeMedium] */
		32,
		/* [WeatherColor] - The color of the weather details is the same in both Light and Dark modes */
		QVariant::fromValue<QColor>(QColor(150, 149, 145)),
	};
};

} /* VenusOS */

} /* Victron */

#endif /* VICTRON_VENUSOS_GUI_V2_THEME_H */

