/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_THEME_H
#define VICTRON_VENUSOS_GUI_V2_THEME_H

#include <QGuiApplication>
#include <QScreen>
#include <QObject>
#include <QSizeF>
#include <qqmlintegration.h>

#include "enums.h"

namespace Victron {
namespace VenusOS {

class Theme : public QObject
{
	Q_OBJECT
	QML_NAMED_ELEMENT(ThemeBase)
	Q_PROPERTY(ScreenSize screenSize READ screenSize WRITE setScreenSize NOTIFY screenSizeChanged)
	Q_PROPERTY(ColorScheme colorScheme READ colorScheme WRITE setColorScheme NOTIFY colorSchemeChanged)
	Q_PROPERTY(SystemColorScheme systemColorScheme READ systemColorScheme WRITE setSystemColorScheme NOTIFY systemColorSchemeChanged)
	Q_PROPERTY(ForcedColorScheme forcedColorScheme READ forcedColorScheme WRITE setForcedColorScheme NOTIFY forcedColorSchemeChanged)
	Q_PROPERTY(QString applicationVersion READ applicationVersion CONSTANT)
	Q_PROPERTY(int geometry_screen_width READ geometry_screen_width WRITE setGeometry_screen_width NOTIFY geometry_screen_widthChanged FINAL)
	Q_PROPERTY(int geometry_screen_height READ geometry_screen_height WRITE setGeometry_screen_height NOTIFY geometry_screen_heightChanged FINAL)
	Q_PROPERTY(bool adjustingGeometry READ adjustingGeometry NOTIFY adjustingGeometryChanged FINAL)

public:
	enum ScreenSize {
		FiveInch = 0,
		SevenInch,
		Portrait
	};
	Q_ENUM(ScreenSize)

	enum ColorScheme {
		Dark = 0,
		Light
	};
	Q_ENUM(ColorScheme)

	enum SystemColorScheme {
		SystemColorSchemeDark = 0,
		SystemColorSchemeLight
	};
	Q_ENUM(SystemColorScheme)

	enum ForcedColorScheme {
		ForcedColorSchemeDark = 0,
		ForcedColorSchemeLight,
		ForcedColorSchemeAuto,
		ForcedColorSchemeDefault // uses the user choice, not the forced color scheme
	};
	Q_ENUM(ForcedColorScheme)

	enum StatusLevel {
		Ok = 0,
		Warning,
		Critical
	};
	Q_ENUM(StatusLevel)

	explicit Theme(QObject *parent = nullptr);

	Victron::VenusOS::Theme::ScreenSize screenSize() const;
	void setScreenSize(Victron::VenusOS::Theme::ScreenSize size);

	Victron::VenusOS::Theme::ColorScheme colorScheme() const;
	void setColorScheme(Victron::VenusOS::Theme::ColorScheme scheme);

	Victron::VenusOS::Theme::SystemColorScheme systemColorScheme() const;
	void setSystemColorScheme(Victron::VenusOS::Theme::SystemColorScheme systemScheme);

	static Theme *instance();

	Victron::VenusOS::Theme::ForcedColorScheme forcedColorScheme() const;
	void setForcedColorScheme(Victron::VenusOS::Theme::ForcedColorScheme forcedScheme);

	int geometry_screen_width() const;
	void setGeometry_screen_width(int width);
	int geometry_screen_height() const;
	void setGeometry_screen_height(int height);

	Q_INVOKABLE Victron::VenusOS::Theme::StatusLevel getValueStatus(qreal value, Victron::VenusOS::Enums::Gauges_ValueType valueType) const;
	Q_INVOKABLE bool windowIsLandscape() const;
	Q_INVOKABLE bool objectHasQObjectParent(QObject *obj) const;

	bool adjustingGeometry() const;
	QString applicationVersion() const;

Q_SIGNALS:
	void screenSizeChanged(Victron::VenusOS::Theme::ScreenSize screenSize);
	void screenSizeChanged_parameterless();
	void colorSchemeChanged(Victron::VenusOS::Theme::ColorScheme colorScheme);
	void colorSchemeChanged_parameterless();
	void systemColorSchemeChanged(Victron::VenusOS::Theme::SystemColorScheme systemColorScheme);
	void systemColorSchemeChanged_parameterless();
	void forcedColorSchemeChanged(Victron::VenusOS::Theme::ForcedColorScheme forcedColorScheme);
	void geometry_screen_widthChanged();
	void geometry_screen_heightChanged();
	void adjustingGeometryChanged();

protected:
	void setAdjustingGeometry(bool adjusting);

	ScreenSize m_screenSize = SevenInch;
	ColorScheme m_colorScheme = Dark;
	SystemColorScheme m_systemColorScheme = SystemColorSchemeDark;
	ForcedColorScheme m_forcedColorScheme = ForcedColorSchemeDefault;
	int m_screenWidth = 1024;
	int m_screenHeight = 600;
	bool m_adjustingGeometry = false;
};

}
}

#endif // VICTRON_VENUSOS_GUI_V2_THEME_H
