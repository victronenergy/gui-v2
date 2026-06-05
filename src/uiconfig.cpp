#include "uiconfig.h"

#include <QFile>

using namespace Victron::VenusOS;

UiConfig* UiConfig::create(QQmlEngine *engine, QJSEngine *)
{
	static UiConfig* uiconfig = new UiConfig(engine);
	return uiconfig;
}

UiConfig::UiConfig(QQmlEngine *engine)
	: QObject(engine)
{
}

bool UiConfig::isApplicationVisible() const
{
	return m_applicationVisible;
}

void UiConfig::setApplicationVisible(bool v)
{
	if (m_applicationVisible != v) {
		m_applicationVisible = v;
		Q_EMIT applicationVisibleChanged();
	}
}

bool UiConfig::animationEnabled() const
{
	return m_animationEnabled;
}

void UiConfig::setAnimationEnabled(bool v)
{
	if (m_animationEnabled != v) {
		m_animationEnabled = v;
		Q_EMIT animationEnabledChanged();
	}
}

QUrl UiConfig::demoImageFileName() const
{
	static const QUrl filePath = QUrl::fromLocalFile("/data/demo-brief.png");
	static const bool fileExists = QFile::exists(filePath.toLocalFile());
	return fileExists ? filePath : QUrl();
}

bool UiConfig::msaaEnabled() const
{
	return m_msaaEnabled;
}

void UiConfig::setMsaaEnabled(bool e)
{
	if (m_msaaEnabled != e) {
		m_msaaEnabled = e;
		Q_EMIT msaaEnabledChanged();
	}
}

bool UiConfig::needsWasmKeyboardHandler() const
{
	return m_needsWasmKeyboardHandler;
}

void UiConfig::setNeedsWasmKeyboardHandler(bool needsWasmKeyboardHandler)
{
	if (m_needsWasmKeyboardHandler != needsWasmKeyboardHandler) {
		m_needsWasmKeyboardHandler = needsWasmKeyboardHandler;
		Q_EMIT needsWasmKeyboardHandlerChanged();
	}
}

