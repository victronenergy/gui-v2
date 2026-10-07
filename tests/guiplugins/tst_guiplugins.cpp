/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "guiplugins.h"

#include <QtTest>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QGuiApplication>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSignalSpy>

#include <sys/stat.h>

using namespace Victron::VenusOS;

namespace {

ino_t fileInode(const QString &path)
{
	struct stat st;
	if (stat(path.toLocal8Bit().constData(), &st) != 0) {
		return 0;
	}
	return st.st_ino;
}

QJsonObject readObject(const QString &path)
{
	QFile f(path);
	if (!f.open(QIODevice::ReadOnly)) {
		return QJsonObject();
	}
	return QJsonDocument::fromJson(f.readAll()).object();
}

bool writeObject(const QString &path, const QJsonObject &obj)
{
	QFile f(path);
	if (!f.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
		return false;
	}
	f.write(QJsonDocument(obj).toJson(QJsonDocument::Indented));
	return true;
}

} // namespace

class tst_GuiPlugins : public QObject
{
	Q_OBJECT

public:
	tst_GuiPlugins()
	{
		m_dir = QDir::temp().filePath(QStringLiteral("gui-v2-plugin-ui-state-test"));
		QDir(m_dir).removeRecursively();
		QDir().mkpath(m_dir);
		m_path = m_dir + QStringLiteral("/plugin-ui-state.json");
		qputenv("VENUS_PLUGIN_UI_STATE_FILE", m_path.toLocal8Bit());
	}

private slots:
	void initTestCase();
	void startup_does_not_create_state_file();
	void enabling_already_enabled_plugin_is_noop();
	void save_replaces_file_atomically();
	void own_write_does_not_emit_again();
	void inplace_external_edit_is_seen();
	void recreated_file_is_seen();
	void settings_writes_are_coalesced();

private:
	QString m_dir;
	QString m_path;
	GuiPluginLoader *m_loader = nullptr;
};

void tst_GuiPlugins::initTestCase()
{
	QVERIFY(!QFile::exists(m_path));
	m_loader = new GuiPluginLoader(this);
}

void tst_GuiPlugins::startup_does_not_create_state_file()
{
	QVERIFY2(!QFile::exists(m_path),
			"plugin UI state must be created on the first real write, not at startup");
}

void tst_GuiPlugins::enabling_already_enabled_plugin_is_noop()
{
	QSignalSpy enabledSpy(m_loader, &GuiPluginLoader::pluginEnabledChanged);
	QSignalSpy stateSpy(m_loader, &GuiPluginLoader::pluginUiStateChanged);
	QVERIFY(m_loader->isPluginEnabled(QStringLiteral("NeverStored")));
	m_loader->setPluginEnabled(QStringLiteral("NeverStored"), true);
	QCOMPARE(enabledSpy.count(), 0);
	QCOMPARE(stateSpy.count(), 0);
	QVERIFY2(!QFile::exists(m_path),
			"setPluginEnabled(true) on a plugin that is already enabled must not write");
}

void tst_GuiPlugins::save_replaces_file_atomically()
{
	m_loader->setPluginEnabled(QStringLiteral("CardExample"), false);
	QVERIFY(QFile::exists(m_path));
	const ino_t before = fileInode(m_path);
	QVERIFY(before != 0);

	m_loader->setPluginSetting(QStringLiteral("CardExample"), QStringLiteral("k"), 1);
	m_loader->flushPluginUiState();
	const ino_t after = fileInode(m_path);
	QVERIFY2(after != 0 && after != before,
			"state file writes must replace the inode (QSaveFile), not truncate in place");

	const QJsonObject root = readObject(m_path);
	QCOMPARE(root.value(QStringLiteral("CardExample")).toObject()
			.value(QStringLiteral("settings")).toObject()
			.value(QStringLiteral("k")).toInt(), 1);
}

void tst_GuiPlugins::own_write_does_not_emit_again()
{
	QSignalSpy spy(m_loader, &GuiPluginLoader::pluginUiStateChanged);
	m_loader->setPluginSetting(QStringLiteral("CardExample"), QStringLiteral("k"), 2);
	QCOMPARE(spy.count(), 1);
	m_loader->flushPluginUiState();
	QTest::qWait(500);
	QCOMPARE(spy.count(), 1);
}

void tst_GuiPlugins::inplace_external_edit_is_seen()
{
	QJsonObject root = readObject(m_path);
	QJsonObject card = root.value(QStringLiteral("CardExample")).toObject();
	card.insert(QStringLiteral("enabled"), true);
	root.insert(QStringLiteral("CardExample"), card);

	QSignalSpy spy(m_loader, &GuiPluginLoader::pluginEnabledChanged);
	QVERIFY(writeObject(m_path, root));
	QTRY_COMPARE_WITH_TIMEOUT(spy.count(), 1, 2000);
	QVERIFY(m_loader->isPluginEnabled(QStringLiteral("CardExample")));
}

void tst_GuiPlugins::recreated_file_is_seen()
{
	QVERIFY(QFile::remove(m_path));
	QTest::qWait(300);

	QJsonObject nav;
	nav.insert(QStringLiteral("enabled"), false);
	QJsonObject root;
	root.insert(QStringLiteral("NavigationExample"), nav);

	QSignalSpy spy(m_loader, &GuiPluginLoader::pluginEnabledChanged);
	QVERIFY(writeObject(m_path, root));
	QTRY_COMPARE_WITH_TIMEOUT(spy.count(), 1, 2000);
	QVERIFY(!m_loader->isPluginEnabled(QStringLiteral("NavigationExample")));
}

void tst_GuiPlugins::settings_writes_are_coalesced()
{
	qputenv("VENUS_PLUGIN_UI_STATE_SAVE_MS", "250");
	m_loader->setPluginSetting(QStringLiteral("CardExample"), QStringLiteral("k"), 1);
	m_loader->flushPluginUiState();
	const ino_t before = fileInode(m_path);
	QVERIFY(before != 0);
	QCOMPARE(readObject(m_path).value(QStringLiteral("CardExample")).toObject()
			.value(QStringLiteral("settings")).toObject()
			.value(QStringLiteral("k")).toInt(), 1);

	m_loader->setPluginSetting(QStringLiteral("CardExample"), QStringLiteral("k"), 10);
	m_loader->setPluginSetting(QStringLiteral("CardExample"), QStringLiteral("k"), 11);
	m_loader->setPluginSetting(QStringLiteral("CardExample"), QStringLiteral("k"), 12);
	QCOMPARE(m_loader->pluginSetting(QStringLiteral("CardExample"), QStringLiteral("k")).toInt(), 12);

	QTest::qWait(80);
	QCOMPARE(fileInode(m_path), before);
	QCOMPARE(readObject(m_path).value(QStringLiteral("CardExample")).toObject()
			.value(QStringLiteral("settings")).toObject()
			.value(QStringLiteral("k")).toInt(), 1);

	QTRY_COMPARE_WITH_TIMEOUT(
			readObject(m_path).value(QStringLiteral("CardExample")).toObject()
				.value(QStringLiteral("settings")).toObject()
				.value(QStringLiteral("k")).toInt(),
			12, 1000);
	qunsetenv("VENUS_PLUGIN_UI_STATE_SAVE_MS");
}

int main(int argc, char **argv)
{
	QGuiApplication app(argc, argv);
	tst_GuiPlugins tc;
	return QTest::qExec(&tc, argc, argv);
}

#include "tst_guiplugins.moc"
