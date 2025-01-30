/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "quantityobject.h"

#include <QQmlInfo>

using namespace Victron::VenusOS;

QuantityObject::QuantityObject(QObject *parent)
	: QObject(parent)
{
}

QObject* QuantityObject::object() const
{
	return m_object;
}

void QuantityObject::setObject(QObject* object)
{
	if (m_object != object) {
		m_object = object;
		connectNotifySignal();
		emit objectChanged();
	}
}

QString QuantityObject::key() const
{
	return m_key;
}

void QuantityObject::setKey(const QString &key)
{
	if (m_key != key) {
		m_key = key;
		connectNotifySignal();
		emit keyChanged();
	}
}

Victron::VenusOS::Enums::Units_Type QuantityObject::unit() const
{
	return m_unit;
}

void QuantityObject::setUnit(Victron::VenusOS::Enums::Units_Type unit)
{
	if (m_unit != unit) {
		m_unit = unit;
		emit unitChanged();
	}
}

int QuantityObject::precision() const
{
	return m_precision;
}

void QuantityObject::setPrecision(int precision)
{
	if (m_precision != precision) {
		m_precision = precision;
		emit precisionChanged();
	}
}

qreal QuantityObject::numberValue() const
{
	return m_value.value<qreal>();
}

QString QuantityObject::textValue() const
{
	return m_value.metaType() == QMetaType(QMetaType::QString) ? m_value.toString() : QString();
}

bool QuantityObject::hasValue() const
{
	// Return true if the value is not NaN or the text is not empty.
	return m_object && m_key.length() && m_value.isValid()
			&& (!qIsNaN(numberValue()) || textValue().length() > 0);
}

void QuantityObject::connectNotifySignal()
{
	if (m_notifySignalConnection) {
		QObject::disconnect(m_notifySignalConnection);
	}

	static const QMetaMethod updateValueMethod =
			staticMetaObject.method(staticMetaObject.indexOfMethod("updateValue()"));
	if (!updateValueMethod.isValid()) {
		qmlInfo(this) << "Failed to find updateValue() method!";
		return;
	}

	if (m_object && m_key.length()) {
		const QMetaObject *metaObject = m_object->metaObject();
		m_property = metaObject->property(metaObject->indexOfProperty(m_key.toLatin1()));
		if (m_property.isValid()) {
			m_notifySignalConnection = QObject::connect(m_object.data(), m_property.notifySignal(), this, updateValueMethod);
			if (!m_notifySignalConnection) {
				qmlInfo(this) << "Failed to connect to notify signal for: " << m_key;
			}
			updateValue();
		} else {
			qmlInfo(this) << "Cannot find property: " << m_key;
		}
	}
}

void QuantityObject::updateValue()
{
	const qreal prevNumberValue = numberValue();
	const QString prevTextValue = textValue();
	const bool prevHasValue = hasValue();

	if (m_object && m_property.isValid()) {
		m_value = m_property.read(m_object);
	} else {
		m_value.clear();
	}

	if (prevNumberValue != numberValue()) {
		emit numberValueChanged();
	}
	if (prevTextValue != textValue()) {
		emit textValueChanged();
	}
	if (prevHasValue != hasValue()) {
		emit hasValueChanged();
	}
}
