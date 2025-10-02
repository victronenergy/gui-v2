/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_MOCKMANAGER_H
#define VICTRON_GUIV2_MOCKMANAGER_H

#include <QQmlEngine>

namespace Victron {
namespace VenusOS {

class VeQItemMockProducer;

class MockManager : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON
	Q_PROPERTY(bool timersActive READ timersActive WRITE setTimersActive NOTIFY timersActiveChanged FINAL)

public:
	bool timersActive() const;
	void setTimersActive(bool active);

	Q_INVOKABLE void setValue(const QString &uid, const QVariant &value);
	Q_INVOKABLE QVariant value(const QString &uid) const;
	Q_INVOKABLE void removeValue(const QString &uid);
	Q_INVOKABLE void removeServices(const QString &serviceType);

	Q_INVOKABLE bool loadConfiguration(const QString &fileName);
	Q_INVOKABLE void dumpValues();

	static MockManager* create(QQmlEngine *engine = nullptr, QJSEngine *jsEngine = nullptr);

Q_SIGNALS:
	void timersActiveChanged();
	void addDummyNotification(bool isAlarm);

private:
	explicit MockManager(QObject *parent = nullptr);
	bool setValuesFromJson(const QString &fileName);
	void setServiceValues(const QJsonObject &object);
	VeQItemMockProducer *producer() const;

	bool m_timersActive = false;
};

}
}

#endif // VICTRON_GUIV2_MOCKMANAGER_H
