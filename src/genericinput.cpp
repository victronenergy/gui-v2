/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "genericinput.h"
#include "enums.h"

#include <QQmlInfo>

#include <veutil/qt/ve_qitem.hpp>

using namespace Victron::VenusOS;

namespace {

QStringList labelsFromString(const QString &labelsText)
{
	if (labelsText == QStringLiteral("/low-high")) {
		return {
			//% "Low"
			qtTrId("generic_input_label_low"),
			//% "High"
			qtTrId("generic_input_label_high")
		};
	} else if (labelsText == QStringLiteral("/off-on")) {
		return {
			//% "Off"
			qtTrId("generic_input_label_off"),
			//% "On"
			qtTrId("generic_input_label_on")
		};
	} else if (labelsText == QStringLiteral("/no-yes")) {
		return {
			//% "No"
			qtTrId("generic_input_label_no"),
			//% "Yes"
			qtTrId("generic_input_label_yes")
		};
	} else if (labelsText == QStringLiteral("/open-closed")) {
		return {
			//% "Open"
			qtTrId("generic_input_label_open"),
			//% "Closed"
			qtTrId("generic_input_label_closed")
		};
	} else if (labelsText == QStringLiteral("/ok-alarm")) {
		return {
			//% "OK"
			qtTrId("generic_input_label_ok"),
			//% "Alarm"
			qtTrId("generic_input_label_alarm")
		};
	} else if (labelsText == QStringLiteral("/stopped-running")) {
		return {
			//% "Stopped"
			qtTrId("generic_input_label_stopped"),
			//% "Running"
			qtTrId("generic_input_label_running")
		};
	} else {
		return labelsText.split('|');
	}
}

}

GenericInput::GenericInput(QObject *parent)
	: IOChannel(IOChannel::Input, parent)
{
}

GenericInput::GenericInput(QObject *parent, VeQItem *inputItem)
	: IOChannel(IOChannel::Input, parent)
{
	initialize(inputItem);
}

void GenericInput::initialize(VeQItem *inputItem)
{
	IOChannel::initialize(inputItem);

	if (m_item) {
		if (VeQItem *valueItem = m_item->itemGetOrCreate(QStringLiteral("Value"))) {
			connect(valueItem, &VeQItem::valueChanged, this, &GenericInput::setValue);
			setValue(valueItem->getValue());
		}
		if (VeQItem *labelsItem = m_item->itemGetOrCreate(QStringLiteral("Settings/Labels"))) {
			connect(labelsItem, &VeQItem::valueChanged, this, &GenericInput::setLabels);
			setLabels(labelsItem->getValue());
		}
		if (VeQItem *rangeMinItem = m_item->itemGetOrCreate(QStringLiteral("Settings/RangeMin"))) {
			connect(rangeMinItem, &VeQItem::valueChanged, this, &GenericInput::setRangeMin);
			setRangeMin(rangeMinItem->getValue());
		}
		if (VeQItem *rangeMaxItem = m_item->itemGetOrCreate(QStringLiteral("Settings/RangeMax"))) {
			connect(rangeMaxItem, &VeQItem::valueChanged, this, &GenericInput::setRangeMax);
			setRangeMax(rangeMaxItem->getValue());
		}
		if (VeQItem *showUIInputItem = m_item->itemGetOrCreate(QStringLiteral("Settings/ShowUIInput"))) {
			connect(showUIInputItem, &VeQItem::valueChanged, this, [this](QVariant variant) {
				m_showUIInput = variant;
				updateAllowedInGroupModel();
			});
			m_showUIInput = showUIInputItem->getValue();
			updateAllowedInGroupModel();
		}
	} else {
		setValue(QVariant());
		setLabels(QVariant());
		setRangeMin(QVariant());
		setRangeMax(QVariant());

		m_showUIInput.clear();
		updateAllowedInGroupModel();
	}
}

qreal GenericInput::value() const
{
	return m_value;
}

void GenericInput::setValue(const QVariant &variant)
{
	m_value = variant.isValid() ? variant.value<qreal>() : 0;
	updateAllowedInGroupModel();
	updateTextValue();
	emit valueChanged();
}

QString GenericInput::textValue() const
{
	return m_textValue;
}

void GenericInput::updateTextValue()
{
	QString newTextValue;
	if (m_labels.size()) {
		newTextValue = m_labels.value(m_value);
	}
	if (newTextValue != m_textValue) {
		m_textValue = newTextValue;
		emit textValueChanged();
	}
}

void GenericInput::setLabels(const QVariant &variant)
{
	m_labels = labelsFromString(variant.toString());
	updateTextValue();
}

qreal GenericInput::rangeMin() const
{
	return m_rangeMin;
}

void GenericInput::setRangeMin(const QVariant &variant)
{
	m_rangeMin = variant.isValid() ? variant.value<qreal>() : 0;
	emit rangeMinChanged();
}

qreal GenericInput::rangeMax() const
{
	return m_rangeMax;
}

void GenericInput::setRangeMax(const QVariant &variant)
{
	m_rangeMax = variant.isValid() ? variant.value<qreal>() : 100;
	emit rangeMaxChanged();
}

bool GenericInput::getAllowedInGroupModel() const
{
	if (!IOChannel::getAllowedInGroupModel() || !canShowUI(m_showUIInput)) {
		return false;
	}

	return true;
}

int GenericInput::minimumType() const
{
	return static_cast<int>(Enums::GenericInput_Type_Discrete);
}

int GenericInput::maximumType() const
{
	return static_cast<int>(Enums::GenericInput_Type_MaxSupportedType);
}
