/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include <QtQuickTest/quicktest.h>
#include <QCoreApplication>
#include <QQmlContext>
#include <QQmlEngine>
#include <QTranslator>

#include "backendconnection.h"
#include "testutils.h"

/*
	A translator that prefixes each translated string, so that tests can simulate a change in
	translation catalogue without depending on the .qm files, which are not built into the tests.
*/
class TestTranslator : public QTranslator
{
	Q_OBJECT
	Q_PROPERTY(QString prefix READ prefix WRITE setPrefix NOTIFY prefixChanged FINAL)

public:
	explicit TestTranslator(QObject *parent = nullptr) : QTranslator(parent) {}

	QString prefix() const
	{
		return m_prefix;
	}

	void setPrefix(const QString &prefix)
	{
		if (m_prefix == prefix) {
			return;
		}
		if (m_prefix.isEmpty()) {
			QCoreApplication::installTranslator(this);
		} else if (prefix.isEmpty()) {
			QCoreApplication::removeTranslator(this);
		}
		m_prefix = prefix;
		emit prefixChanged();
	}

	bool isEmpty() const override
	{
		return m_prefix.isEmpty();
	}

	QString translate(const char *, const char *sourceText, const char *, int) const override
	{
		return m_prefix.isEmpty() ? QString() : m_prefix + QString::fromUtf8(sourceText);
	}

Q_SIGNALS:
	void prefixChanged();

public slots:
	void qmlEngineAvailable(QQmlEngine *engine)
	{
		engine->rootContext()->setContextProperty(QStringLiteral("WifiTestTranslator"), this);
	}

private:
	QString m_prefix;
};

int main(int argc, char **argv)
{
	TestTranslator translator;

	QTEST_SET_MAIN_SOURCE_PATH
	Victron::VenusOS::BackendConnection::create()->setType(Victron::VenusOS::BackendConnection::MockSource);
	const QByteArray srcDir = resolveTestSourceDir("wifimodel", argv[0]).toLocal8Bit();
	return quick_test_main_with_setup(argc, argv, "tst_wifimodel", srcDir.constData(), &translator);
}

#include "tst_wifimodel.moc"
