/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_UITEST_H
#define VICTRON_GUIV2_UITEST_H

#include <QVariantMap>
#include <QQmlEngine>

namespace Victron {
namespace VenusOS {

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
			"UIAnimations": 0
		},
		"Steps": {
			"CaptureAndCompare": {
				"MaximumStabilizationAttempts": 20,
				"CaptureInterval": 16,
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

	// Loads a configuration from the specified director. This is a relative dir under tests/ui,
	// and it must contain a JSON file of the same name.
	// E.g. if confDir="smoke/mock-maximal", then this attempts to load a JSON file from
	// qrc:tests/ui/smoke/mock-maximal/mock-maximal.json.
	void loadConfiguration(const QString &relativeTestDir);

	Q_INVOKABLE void start();

	Status status() const;
	int testCaseCount() const;

	QVariant settingValue(const QString &key, const QVariant &defaultValue = QVariant()) const;

	static UiTest* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);

Q_SIGNALS:
	void testCaseCountChanged();
	void statusChanged();

private:
	explicit UiTest(QObject *parent = nullptr);
	void setStatus(Status status);
	void startNextTestCase();
	bool exitWhenFinished() const;
	void testCaseFinished();

	QVariantMap m_settings;
	QStringList m_testFileNames;
	QString m_relativeTestDir;
	int m_currentTestIndex = -1;
	Status m_status = NotConfigured;
};

}
}

#endif // VICTRON_GUIV2_UITEST_H
