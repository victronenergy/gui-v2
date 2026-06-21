/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_UICONFIG_H
#define VICTRON_GUIV2_UICONFIG_H

#include <QObject>
#include <QUrl>
#include <QQmlEngine>
#include <qqmlintegration.h>

class QJSEngine;

namespace Victron {
namespace VenusOS {

class UiConfig : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON
	Q_PROPERTY(bool animationEnabled READ animationEnabled WRITE setAnimationEnabled NOTIFY animationEnabledChanged FINAL)
	Q_PROPERTY(bool applicationVisible READ isApplicationVisible WRITE setApplicationVisible NOTIFY applicationVisibleChanged FINAL)
	Q_PROPERTY(QUrl demoImageFileName READ demoImageFileName CONSTANT FINAL)
	Q_PROPERTY(bool msaaEnabled READ msaaEnabled WRITE setMsaaEnabled NOTIFY msaaEnabledChanged FINAL)
	Q_PROPERTY(bool needsWasmKeyboardHandler READ needsWasmKeyboardHandler WRITE setNeedsWasmKeyboardHandler NOTIFY needsWasmKeyboardHandlerChanged FINAL)
	Q_PROPERTY(bool showSplashAnimation READ showSplashAnimation WRITE setShowSplashAnimation NOTIFY showSplashAnimationChanged FINAL)
	Q_PROPERTY(bool splashScreenVisible READ splashScreenVisible WRITE setSplashScreenVisible NOTIFY splashScreenVisibleChanged FINAL)

public:
	static UiConfig* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);

	bool isApplicationVisible() const;
	void setApplicationVisible(bool v);

	bool animationEnabled() const;
	void setAnimationEnabled(bool v);

	QUrl demoImageFileName() const;

	bool msaaEnabled() const;
	void setMsaaEnabled(bool e);

	bool needsWasmKeyboardHandler() const;
	void setNeedsWasmKeyboardHandler(bool needsWasmKeyboardHandler);

	bool showSplashAnimation() const;
	void setShowSplashAnimation(bool showSplashAnimation);

	bool splashScreenVisible() const;
	void setSplashScreenVisible(bool v);

Q_SIGNALS:
	void animationEnabledChanged();
	void applicationVisibleChanged();
	void msaaEnabledChanged();
	void needsWasmKeyboardHandlerChanged();
	void showSplashAnimationChanged();
	void splashScreenVisibleChanged();

private:
	explicit UiConfig(QQmlEngine* engine);
	bool m_animationEnabled = true;
	bool m_applicationVisible = true;
	bool m_msaaEnabled = true;
	bool m_needsWasmKeyboardHandler = false;
#if defined(VENUS_WEBASSEMBLY_BUILD)
	// By default, skip the fade and logo animations on WebAssembly as startup speed is more important.
	bool m_showSplashAnimation = false;
#else
	bool m_showSplashAnimation = true;
#endif
	bool m_splashScreenVisible = true;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_UICONFIG_H
