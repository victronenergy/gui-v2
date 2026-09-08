/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "genericinput.h"
#include "enums.h"
#include "language.h"

#include <QQmlInfo>

#include <veutil/qt/ve_qitem.hpp>

using namespace Victron::VenusOS;

namespace {

// Translate reserved label keywords at call time (not via a static map of qtTrId
// results) so lupdate extracts them reliably and language changes take effect.
QString translateReservedLabel(const QString &label)
{
	if (label == QLatin1String("/low")) {
		//% "Low"
		return qtTrId("generic_input_label_low");
	}
	if (label == QLatin1String("/high")) {
		//% "High"
		return qtTrId("generic_input_label_high");
	}
	if (label == QLatin1String("/off")) {
		//% "Off"
		return qtTrId("generic_input_label_off");
	}
	if (label == QLatin1String("/on")) {
		//% "On"
		return qtTrId("generic_input_label_on");
	}
	if (label == QLatin1String("/no")) {
		//% "No"
		return qtTrId("generic_input_label_no");
	}
	if (label == QLatin1String("/yes")) {
		//% "Yes"
		return qtTrId("generic_input_label_yes");
	}
	if (label == QLatin1String("/open")) {
		//% "Open"
		return qtTrId("generic_input_label_open");
	}
	if (label == QLatin1String("/closed")) {
		//% "Closed"
		return qtTrId("generic_input_label_closed");
	}
	if (label == QLatin1String("/ok")) {
		//% "OK"
		return qtTrId("generic_input_label_ok");
	}
	if (label == QLatin1String("/alarm")) {
		//% "Alarm"
		return qtTrId("generic_input_label_alarm");
	}
	if (label == QLatin1String("/stopped")) {
		//% "Stopped"
		return qtTrId("generic_input_label_stopped");
	}
	if (label == QLatin1String("/running")) {
		//% "Running"
		return qtTrId("generic_input_label_running");
	}
	if (label == QLatin1String("/released")) {
		//% "Released"
		return qtTrId("generic_input_label_released");
	}
	if (label == QLatin1String("/pressed")) {
		//% "Pressed"
		return qtTrId("generic_input_label_pressed");
	}
	if (label == QLatin1String("/holding")) {
		//% "Holding"
		return qtTrId("generic_input_label_holding");
	}
	return label;
}

} // namespace

GenericInput::GenericInput(QObject *parent)
	: IOChannel(IOChannel::Input, parent)
{
	connect(this, &IOChannel::unitTypeChanged, this, &GenericInput::updatePrimaryLabel);
	connect(Language::create(), &Language::currentLanguageChanged, this, [this]() {
		updateTextValue();
		updatePrimaryLabel();
	});
}

GenericInput::GenericInput(QObject *parent, VeQItem *inputItem)
	: IOChannel(IOChannel::Input, parent)
{
	connect(this, &IOChannel::unitTypeChanged, this, &GenericInput::updatePrimaryLabel);
	connect(Language::create(), &Language::currentLanguageChanged, this, [this]() {
		updateTextValue();
		updatePrimaryLabel();
	});
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
		if (VeQItem *primaryLabelItem = m_item->itemGetOrCreate(QStringLiteral("Settings/PrimaryLabel"))) {
			connect(primaryLabelItem, &VeQItem::valueChanged, this, &GenericInput::setPrimaryLabel);
			setPrimaryLabel(primaryLabelItem->getValue());
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
		setPrimaryLabel(QVariant());
		setRangeMin(QVariant());
		setRangeMax(QVariant());

		m_showUIInput.clear();
		updateAllowedInGroupModel();
		updatePrimaryLabel();
	}
}

qreal GenericInput::value() const
{
	return m_value;
}

void GenericInput::setValue(const QVariant &variant)
{
	m_value = variant.isValid() && variant.canConvert<qreal>() ? variant.value<qreal>() : 0;
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
		const QString label = m_labels.value(static_cast<int>(m_value));
		newTextValue = label.startsWith(QLatin1Char('/'))
				? translateReservedLabel(label)
				: label;
	}
	if (newTextValue != m_textValue) {
		m_textValue = newTextValue;
		emit textValueChanged();
	}
}

void GenericInput::setLabels(const QVariant &variant)
{
	// Store raw labels (including "/keyword" reserved forms). Translation is
	// applied in updateTextValue() so qtTrId() runs whenever the value or
	// language changes, rather than once into a static map.
	m_labels = variant.toStringList();
	updateTextValue();
}

QString GenericInput::primaryLabel() const
{
	return m_primaryLabel;
}

void GenericInput::setPrimaryLabel(const QVariant &variant)
{
	m_rawPrimaryLabel = variant.toString();
	updatePrimaryLabel();
}

void GenericInput::updatePrimaryLabel()
{
	const QString prevLabel = m_primaryLabel;

	if (!m_rawPrimaryLabel.isEmpty()) {
		m_primaryLabel = m_rawPrimaryLabel;
	} else {
		switch (unitType()) {
		case Enums::Units_Speed_MetresPerSecond:
			//% "Speed"
			m_primaryLabel = qtTrId("generic_input_primaryLabel_speed");
			break;
		case Enums::Units_Temperature_Celsius:
			//% "Temperature"
			m_primaryLabel = qtTrId("generic_input_primaryLabel_temperature");
			break;
		case Enums::Units_Volume_CubicMetre:
			//% "Volume"
			m_primaryLabel = qtTrId("generic_input_primaryLabel_volume");
			break;
		default:
			m_primaryLabel.clear();
			break;
		}
	}

	if (prevLabel != m_primaryLabel) {
		emit primaryLabelChanged();
	}
}

qreal GenericInput::rangeMin() const
{
	return m_rangeMin;
}

void GenericInput::setRangeMin(const QVariant &variant)
{
	m_rangeMin = variant.isValid() && variant.canConvert<qreal>() ? variant.value<qreal>() : 0;
	emit rangeMinChanged();
}

qreal GenericInput::rangeMax() const
{
	return m_rangeMax;
}

void GenericInput::setRangeMax(const QVariant &variant)
{
	m_rangeMax = variant.isValid() && variant.canConvert<qreal>() ? variant.value<qreal>() : 100;
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
