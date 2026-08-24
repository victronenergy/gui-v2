/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_UITEST_H
#define VICTRON_GUIV2_UITEST_H

#include <QList>
#include <QMetaObject>
#include <QSet>
#include <QVariantMap>
#include <QQmlError>
#include <QQmlEngine>

namespace Victron {
namespace VenusOS {

class UiTestConfiguration
{
public:
	UiTestConfiguration();
	~UiTestConfiguration();

	// Loads a configuration from the specified directory. This is a relative dir under tests/ui,
	// and it must contain a JSON file of the same name.
	// E.g. if dirName="smoke/mock-maximal", then this attempts to load a JSON file from
	// qrc:tests/ui/smoke/mock-maximal/mock-maximal.json.
	void load(const QString &dirName);
	bool exists(const QString &dirName) const;
	void loadTargetPageNavigation(const QString &targetPage);

	bool isValid() const { return !dirName().isEmpty(); }
	QString dirName() const;
	const QVariantMap &settingsMap() const;
	bool hasMockConfiguration() const;

private:
	QVariantMap m_settings;
	QString m_dirName;
};

/*
	Configures and executes the UI testing.

	Call loadConfiguration() to load a JSON configuration file. For example:

	{
		"ExitWhenFinished": true,
		"Tests": [
			"tst_cards.qml",
			"tst_overview.qml"
		]
		"Mock": {
			"Configuration": "/data/mock/conf/maximal.json",
			"TimersActive": false,
		},
		"Steps": {
			"CaptureAndCompare": {
				"StabilizationInterval": 16,
				"ImageDir": "image-captures",
			},
			"WaitUntil": {
				"DefaultTimeout": 5000
			}
		}
	}
*/
class UiTest : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON
	Q_PROPERTY(int testCaseCount READ testCaseCount NOTIFY testCaseCountChanged FINAL)
	Q_PROPERTY(Status status READ status NOTIFY statusChanged FINAL)

public:
	enum Status {
		NotConfigured,
		Ready,
		Running,
		Finished
	};
	Q_ENUM(Status);

	void loadConfiguration(const UiTestConfiguration &conf);
	Q_INVOKABLE void start();

	Status status() const;
	int testCaseCount() const;

	Q_INVOKABLE QVariant settingValue(const QString &key, const QVariant &defaultValue = QVariant()) const;

	static UiTest* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);

Q_SIGNALS:
	void testCaseCountChanged();
	void statusChanged();

private:
	explicit UiTest(QObject *parent = nullptr);
	void setStatus(Status status);
	void startNextTestCase();
	bool exitWhenFinished() const;
	bool isTargetPageMode() const;
	void setTargetPageWarningMonitoringEnabled(bool enabled);
	void onQmlWarnings(const QList<QQmlError> &warnings);
	void testCaseFinished(int passCount, int failCount, int elapsed);

	QVariantMap m_settings;
	QStringList m_testFileNames;
	QString m_relativeTestDir;
	int m_currentTestIndex = -1;
	int m_passCount = 0;
	int m_failCount = 0;
	int m_runtimeQmlErrorCount = 0;
	int m_elapsed = 0;
	Status m_status = NotConfigured;
	QSet<QString> m_recordedQmlWarnings;
	QMetaObject::Connection m_qmlWarningsConnection;
};

}
}

#endif // VICTRON_GUIV2_UITEST_H
