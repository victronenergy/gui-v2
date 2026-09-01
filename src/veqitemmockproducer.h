/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_VEQITEMMOCKPRODUCER_H
#define VICTRON_VENUSOS_GUI_V2_VEQITEMMOCKPRODUCER_H

#include "veutil/qt/ve_qitem.hpp"

#include <QtCore/QSet>
#include <QtQml/QQmlEngine>
#include <QtQml/QJSEngine>

namespace Victron {

namespace VenusOS {

class VeQItemMockProducer;

class VeQItemMock : public VeQItem
{
	Q_OBJECT

public:
	VeQItemMock(VeQItemMockProducer *producer);

	int setValue(QVariant const &value) override;

	// True if this item is a path in its own right, i.e. something asked the backend for exactly
	// this uid, rather than for one below it.
	bool isRequestedPath() const { return m_isRequestedPath; }

protected:
	void afterAdd() override;

private:
	VeQItemMockProducer *m_producer = nullptr;
	bool m_isRequestedPath = false;
};

class VeQItemMockProducer : public VeQItemProducer
{
	Q_OBJECT

public:
	VeQItemMockProducer(VeQItem *root, const QString &id, QObject *parent = nullptr);

	void setValue(const QString &uid, const QVariant &value);
	QVariant value(const QString &uid) const;
	void setProperty(const QString &uid, const QString &name, const QVariant &value);
	void removeValue(const QString &uid);
	void removeServices(const QString &serviceType);
	void dumpValues();

	// Returns the uids of the items that the UI requested but for which the mock backend does not
	// provide a value.
	QStringList missingValueUids() const;

	void trackUndefinedUid(VeQItem *item, const QVariant &value);

	VeQItem *createItem() override;

	static QObject* instance(QQmlEngine *engine, QJSEngine *);

Q_SIGNALS:
	void dbusUidChanged();
	void mqttUidChanged();

private:
	static QString normalizedUid(const QString &uid);
	void forgetUndefinedUids(VeQItem *item);

	// The uids that were deliberately set to an undefined value, to indicate that the mocked
	// device does not publish them. A mock configuration does this with a JSON null, and the
	// application may also clear a value at runtime.
	QSet<QString> m_undefinedUids;
};

} /* VenusOS */

} /* Victron */

#endif // VICTRON_VENUSOS_GUI_V2_VEQITEMMOCKPRODUCER_H

