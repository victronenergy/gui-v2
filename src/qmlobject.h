/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_QMLOBJECT_H
#define VICTRON_GUIV2_QMLOBJECT_H

#include <QObject>
#include <qqmlintegration.h>
#include <QQmlListProperty>

namespace Victron {
namespace VenusOS {

class QmlObject : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(QQmlListProperty<QObject> data READ data NOTIFY dataChanged FINAL)
	Q_CLASSINFO("DefaultProperty", "data")

public:
	explicit QmlObject(QObject *parent = nullptr);

	QQmlListProperty<QObject> data();

	static void qmlObjectAppend(QQmlListProperty<QObject> *prop, QObject *object);
	static qsizetype qmlObjectCount(QQmlListProperty<QObject> *prop);
	static QObject *qmlObjectAt(QQmlListProperty<QObject> *prop, qsizetype index);
	static void qmlObjectClear(QQmlListProperty<QObject> *prop);
	static void qmlObjectRemoveLast(QQmlListProperty<QObject> *prop);

signals:
	void dataChanged();

private:
	QVector<QObject*> m_data;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_QMLOBJECT_H
