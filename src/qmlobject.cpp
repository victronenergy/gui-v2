/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "qmlobject.h"

using namespace Victron::VenusOS;

QmlObject::QmlObject(QObject *parent)
	: QObject{parent}
{}

QQmlListProperty<QObject> QmlObject::data()
{
	return QQmlListProperty<QObject>(this, this,
										QmlObject::qmlObjectAppend,
										QmlObject::qmlObjectCount,
										QmlObject::qmlObjectAt,
										QmlObject::qmlObjectClear,
										nullptr, // no replace
										QmlObject::qmlObjectRemoveLast);
}

void QmlObject::qmlObjectAppend(QQmlListProperty<QObject> *prop, QObject *object)
{
	QmlObject *qmlObject = static_cast<QmlObject *>(prop->data);
	qmlObject->m_data.append(object);
	emit qmlObject->dataChanged();
}

qsizetype QmlObject::qmlObjectCount(QQmlListProperty<QObject> *prop)
{
	QmlObject *qmlObject = static_cast<QmlObject *>(prop->data);
	return qmlObject->m_data.count();
}

QObject *QmlObject::qmlObjectAt(QQmlListProperty<QObject> *prop, qsizetype index)
{
	QmlObject *qmlObject = static_cast<QmlObject *>(prop->data);
	if (index >= 0 && index < qmlObject->m_data.count()) {
		return qmlObject->m_data.at(index);
	}
	return nullptr;
}

void QmlObject::qmlObjectClear(QQmlListProperty<QObject> *prop)
{
	QmlObject *qmlObject = static_cast<QmlObject *>(prop->data);
	qmlObject->m_data.clear();
	emit qmlObject->dataChanged();
}

void QmlObject::qmlObjectRemoveLast(QQmlListProperty<QObject> *prop)
{
	QmlObject *qmlObject = static_cast<QmlObject *>(prop->data);
	qmlObject->m_data.removeLast();
	emit qmlObject->dataChanged();
}
