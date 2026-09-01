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
	//
	// isLeaf() cannot answer this, because adding any child clears it: if the UI asks for "/A" and
	// then for "/A/B", "/A" stops being a leaf even though it is still a requested path with no
	// value.
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
	void removeValue(const QString &uid);
	void removeServices(const QString &serviceType);
	void dumpValues();

	// Returns the uids of the items that the UI requested but for which the mock backend does not
	// provide a value. Such items yield 'undefined' in QML. A requested uid is reported whether or
	// not it is still a leaf: asking for a uid below it adds a child and clears isLeaf(), but it is
	// still a path that was asked for and has no value.
	//
	// A uid that already existed as the ancestor of a deeper request, and was only asked for
	// afterwards, is not recognised as requested and so is not reported; see
	// tst_mockcoverage's test_requestedPathThatAlreadyExistedIsReported().
	//
	// A value that was deliberately set to undefined is not included in this list, whether that
	// was done by a mock configuration or by the application at runtime; see trackUndefinedUid().
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

