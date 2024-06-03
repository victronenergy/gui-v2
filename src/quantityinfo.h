/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef QUANTITYINFO_H
#define QUANTITYINFO_H

#include <QObject>
#include <QQmlEngine>
#include <QElapsedTimer>
#include <QQmlPropertyValueSource>
#include <QQmlProperty>
#include "units.h"

namespace Victron {
namespace Units {

class QuantityInfo : public QObject
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(QString number READ getNumber NOTIFY numberChanged FINAL)
	Q_PROPERTY(QString unit READ getUnit NOTIFY unitChanged FINAL)
	Q_PROPERTY(VenusOS::Enums::Units_Scale scale READ getScale NOTIFY scaleChanged FINAL)

	Q_PROPERTY(qreal value MEMBER value NOTIFY valueChanged FINAL)
	Q_PROPERTY(qreal unitMatchValue MEMBER unitMatchValue NOTIFY unitMatchValueChanged FINAL)
	Q_PROPERTY(int precision MEMBER precision NOTIFY precisionChanged FINAL)
	Q_PROPERTY(Victron::VenusOS::Enums::Units_Type unitType MEMBER unitType NOTIFY inputChanged FINAL)
	Q_PROPERTY(int formatHints MEMBER formatHints NOTIFY formatHintsChanged FINAL)

public:
	explicit QuantityInfo(QObject *parent = nullptr);
	~QuantityInfo() override;

	QString getNumber() const { return m_number; }
	QString getUnit() const { return m_unit; }
	VenusOS::Enums::Units_Scale getScale() const { return m_scale; }

signals:
	void updated();
	void numberChanged();
	void unitChanged();
	void scaleChanged();
	void inputChanged();
	void valueChanged();
	void precisionChanged();
	void unitMatchValueChanged();
	void formatHintsChanged();
private:
	void update();

	quantityInfo quantity;
	QString m_number;
	QString m_unit;
	VenusOS::Enums::Units_Scale m_scale = Victron::VenusOS::Enums::Units_Scale_None;

	qreal value = qQNaN();
	Victron::VenusOS::Enums::Units_Type unitType = Victron::VenusOS::Enums::Units_None;
	int precision = -1;
	qreal unitMatchValue = qQNaN();
	bool completed = false;
	int formatHints = 0;
};

}
}

#endif // VICTRON_VENUSOS_GUI_V2_UNITS_H
