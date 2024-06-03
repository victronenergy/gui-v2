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

namespace Victron {
namespace VenusOS {

class Theme : public QObject
{
	Q_OBJECT
	QML_NAMED_ELEMENT(ThemeBase)
	Q_PROPERTY(ScreenSize screenSize READ screenSize WRITE setScreenSize NOTIFY screenSizeChanged)
	Q_PROPERTY(ColorScheme colorScheme READ colorScheme WRITE setColorScheme NOTIFY colorSchemeChanged)
	Q_PROPERTY(QString applicationVersion READ applicationVersion CONSTANT)

public:
	enum ScreenSize {
		FiveInch = 0,
		SevenInch
	};
	Q_ENUM(ScreenSize)

	enum ColorScheme {
		Dark = 0,
		Light
	};
	Q_ENUM(ColorScheme)

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

	Q_INVOKABLE bool objectHasQObjectParent(QObject *obj) const;

	QString applicationVersion() const;

Q_SIGNALS:
	void screenSizeChanged(Victron::VenusOS::Theme::ScreenSize screenSize);
	void screenSizeChanged_parameterless();
	void colorSchemeChanged(Victron::VenusOS::Theme::ColorScheme colorScheme);
	void colorSchemeChanged_parameterless();

protected:
	ScreenSize m_screenSize = SevenInch;
	ColorScheme m_colorScheme = Dark;
};

}
}

#endif // VICTRON_VENUSOS_GUI_V2_THEME_H
