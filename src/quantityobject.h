/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef QUANTITYMODEL_H
#define QUANTITYMODEL_H

#include <qqmlintegration.h>
#include <QMetaObject>
#include <QMetaProperty>

#include "enums.h"

namespace Victron {
namespace VenusOS {

/*
	Provides QObject-based access to a quantity value.

	Example usage:

	QtObject {
		id: dataObject
		property real voltage: 0.14
		property real power: 536
	}

	QuantityObject { object: dataObject; key: "voltage"; unit: VenusOS.Units_Volt_DC }  // numberValue = 0.14
	QuantityObject { object: dataObject; key: "power"; unit: VenusOS.Units_Watt }   // numberValue = 536
  */
class QuantityObject : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(QObject* object READ object WRITE setObject NOTIFY objectChanged FINAL)
	Q_PROPERTY(QString key READ key WRITE setKey NOTIFY keyChanged FINAL)
	Q_PROPERTY(Victron::VenusOS::Enums::Units_Type unit READ unit WRITE setUnit NOTIFY unitChanged FINAL)
	Q_PROPERTY(int precision READ precision WRITE setPrecision NOTIFY precisionChanged FINAL)
	Q_PROPERTY(QVariant defaultValue READ defaultValue WRITE setDefaultValue NOTIFY defaultValueChanged FINAL)
	Q_PROPERTY(qreal numberValue READ numberValue NOTIFY numberValueChanged FINAL)
	Q_PROPERTY(QString textValue READ textValue NOTIFY textValueChanged FINAL)
	Q_PROPERTY(bool hasValue READ hasValue NOTIFY hasValueChanged FINAL)

public:
	explicit QuantityObject(QObject *parent = nullptr);

	QObject* object() const;
	void setObject(QObject* object);

	QString key() const;
	void setKey(const QString &key);

	Victron::VenusOS::Enums::Units_Type unit() const;
	void setUnit(Victron::VenusOS::Enums::Units_Type unit);

	int precision() const;
	void setPrecision(int precision);

	QVariant defaultValue() const;
	void setDefaultValue(const QVariant &value);

	qreal numberValue() const;  // NaN if the value is not a real type
	QString textValue() const;  // empty if the value is not a string type
	bool hasValue() const;

Q_SIGNALS:
	void objectChanged();
	void keyChanged();
	void unitChanged();
	void precisionChanged();
	void defaultValueChanged();
	void numberValueChanged();
	void textValueChanged();
	void hasValueChanged();

private Q_SLOTS:
	void updateValue();

private:
	void connectNotifySignal();

	QPointer<QObject> m_object;
	QString m_key;
	QVariant m_value;
	QVariant m_defaultValue;
	QMetaProperty m_property;
	QMetaObject::Connection m_notifySignalConnection;
	Victron::VenusOS::Enums::Units_Type m_unit = Victron::VenusOS::Enums::Units_None;
	int m_precision = Victron::VenusOS::Enums::Units_Precision_Default;
	bool m_hasValue = false;
};

} /* VenusOS */
} /* Victron */

#endif // QUANTITYMODEL_H
