/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "quantityobject.h"

#include <QQmlInfo>

using namespace Victron::VenusOS;

namespace {
	static const QString DefaultKey = QStringLiteral("value");
}

QuantityObject::QuantityObject(QObject *parent)
	: QObject(parent)
	, m_key(DefaultKey)
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
		updateValue();
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
		updateValue();
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

QVariant QuantityObject::defaultValue() const
{
	return m_defaultValue;
}

void QuantityObject::setDefaultValue(const QVariant &value)
{
	if (m_defaultValue != value) {
		m_defaultValue = value;
		updateValue();
		emit defaultValueChanged();
	}
}

qreal QuantityObject::numberValue() const
{
	const QVariant &v = m_value.isValid() ? m_value : m_defaultValue;
	return v.value<qreal>();
}

QString QuantityObject::textValue() const
{
	const QVariant &v = m_value.isValid() ? m_value : m_defaultValue;
	return v.metaType() == QMetaType(QMetaType::QString) ? v.toString() : QString();
}

bool QuantityObject::hasValue() const
{
	return m_hasValue;
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
		} else if (m_key != DefaultKey) {
			qmlInfo(this) << "Object does not have property: " << m_key;
		}
	}
}

void QuantityObject::updateValue()
{
	const qreal prevNumberValue = numberValue();
	const QString prevTextValue = textValue();
	const bool prevHasValue = m_hasValue;

	if (m_object && m_property.isValid()) {
		m_value = m_property.read(m_object);
	} else {
		m_value.clear();
	}

	// hasValue=true if there is a valid number or string.
	m_hasValue = m_object && m_key.length()
			&& (m_value.isValid() || m_defaultValue.isValid())
			&& (!qIsNaN(numberValue()) || textValue().length() > 0);

	if (prevNumberValue != numberValue()) {
		emit numberValueChanged();
	}
	if (prevTextValue != textValue()) {
		emit textValueChanged();
	}
	if (prevHasValue != m_hasValue) {
		emit hasValueChanged();
	}
}
