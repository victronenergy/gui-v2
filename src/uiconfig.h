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


Q_SIGNALS:
	void animationEnabledChanged();
	void applicationVisibleChanged();
	void msaaEnabledChanged();
	void needsWasmKeyboardHandlerChanged();

private:
	explicit UiConfig(QQmlEngine* engine);
	bool m_animationEnabled = true;
	bool m_applicationVisible = true;
	bool m_msaaEnabled = true;
	bool m_needsWasmKeyboardHandler = false;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_UICONFIG_H
