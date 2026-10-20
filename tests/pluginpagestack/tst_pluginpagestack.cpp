/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include <QQmlEngine>
#include <QQmlContext>

#include "backendconnection.h"
#include "testutils.h"

// Counts plugin-page objects created from the fixture URLs. The fixtures call born() and died(),
// so a rejected push that leaks its page leaves live above zero.
class PluginPageStackTestHelper : public QObject {
	Q_OBJECT
	Q_PROPERTY(int live READ live NOTIFY liveChanged)

public:
	int live() const { return m_live; }

	Q_INVOKABLE void born() {
		++m_live;
		emit liveChanged();
	}

	Q_INVOKABLE void died() {
		--m_live;
		emit liveChanged();
	}

public slots:
	void qmlEngineAvailable(QQmlEngine *engine) {
		engine->rootContext()->setContextProperty(QStringLiteral("PluginPageTestTracker"), this);
	}

signals:
	void liveChanged();

private:
	int m_live = 0;
};

int main(int argc, char **argv) {
	PluginPageStackTestHelper helper;

	QTEST_SET_MAIN_SOURCE_PATH
	// PluginListRow shows a row only when Services.settings grants the access level.
	// The mock backend loads that settings service; this test does not load ApplicationContent.
	Victron::VenusOS::BackendConnection::create()->setType(
			Victron::VenusOS::BackendConnection::MockSource);
	return quick_test_main_with_setup(argc, argv, "tst_pluginpagestack",
			resolveTestSourceDir("pluginpagestack", argv[0]).toLocal8Bit().constData(), &helper);
}

#include "tst_pluginpagestack.moc"
