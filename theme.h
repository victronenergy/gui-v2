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
	Q_PROPERTY(int fontSizeMedium READ fontSizeMedium CONSTANT)
	Q_PROPERTY(int marginSmall READ marginSmall CONSTANT)
	Q_PROPERTY(int horizontalPageMargin READ horizontalPageMargin CONSTANT)
	Q_PROPERTY(int iconSizeMedium READ iconSizeMedium CONSTANT)

public:
	enum DisplayMode {
		Light = 0,
		Dark,
	};
	Q_ENUM(DisplayMode)

	enum ColorProperty {
		BackgroundColor = 0,
		PrimaryFontColor,
		SecondaryFontColor,
		HighlightColor,
		DimColor,
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

	Q_INVOKABLE QColor colorValue(DisplayMode mode, ColorProperty role) const;
	Q_INVOKABLE QVariant otherValue(OtherProperty role) const;

	DisplayMode displayMode() const;
	void setDisplayMode(DisplayMode mode);

	QColor backgroundColor() const;
	QColor primaryFontColor() const;
	QColor secondaryFontColor() const;
	QColor highlightColor() const;
	QColor dimColor() const;
	QColor weatherColor() const;

	int fontSizeMedium() const;
	int marginSmall() const;
	int horizontalPageMargin() const;
	int iconSizeMedium() const;

Q_SIGNALS:
	void displayModeChanged();
	void backgroundColorChanged();
	void primaryFontColorChanged();
	void secondaryFontColorChanged();
	void highlightColorChanged();
	void dimColorChanged();

private:
	DisplayMode m_displayMode = Dark;

	/* these values depend on the currently selected displayMode */
	QVector<QVector<QVariant> > m_colorValues {
		/* [Light] */
		{
			/* [BackgroundColor] */
			QVariant::fromValue<QColor>(QColor(255, 255, 255)),
			/* [PrimaryFontColor] */
			QVariant::fromValue<QColor>(QColor(39, 38, 34)),
			/* [SecondaryFontColor] */
			QVariant::fromValue<QColor>(QColor(150, 149, 145)),
			/* [HighlightColor] */
			QVariant::fromValue<QColor>(QColor(5, 111, 255)),
			/* [DimColor] */
			QVariant::fromValue<QColor>(QColor(5, 55, 122)),
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

