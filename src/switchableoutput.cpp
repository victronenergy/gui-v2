/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "switchableoutput.h"
#include "enums.h"

#include <QQmlInfo>

#include <veutil/qt/ve_qitem.hpp>

using namespace Victron::VenusOS;

SwitchableOutput::SwitchableOutput(QObject *parent)
	: IOChannel(IOChannel::Output, parent)
{
}

SwitchableOutput::SwitchableOutput(QObject *parent, VeQItem *outputItem)
	: IOChannel(IOChannel::Output, parent)
{
	initialize(outputItem);
}

void SwitchableOutput::initialize(VeQItem *outputItem)
{
	IOChannel::initialize(outputItem);

	if (m_item) {
		if (VeQItem *stateItem = m_item->itemGetOrCreate(QStringLiteral("State"))) {
			connect(stateItem, &VeQItem::valueChanged, this, &SwitchableOutput::setState);
			setState(stateItem->getValue());
		}
		if (VeQItem *dimmingItem = m_item->itemGetOrCreate(QStringLiteral("Dimming"))) {
			connect(dimmingItem, &VeQItem::valueChanged, this, &SwitchableOutput::setDimming);
			setDimming(dimmingItem->getValue());
		}
		if (VeQItem *functionItem = m_item->itemGetOrCreate(QStringLiteral("Settings/Function"))) {
			connect(functionItem, &VeQItem::valueChanged, this, &SwitchableOutput::setFunction);
			setFunction(functionItem->getValue());
		}
		if (VeQItem *validFunctionsItem = m_item->itemGetOrCreate(QStringLiteral("Settings/ValidFunctions"))) {
			connect(validFunctionsItem, &VeQItem::valueChanged, this, &SwitchableOutput::setValidFunctions);
			setValidFunctions(validFunctionsItem->getValue());
		}
		if (VeQItem *showUIControlItem = m_item->itemGetOrCreate(QStringLiteral("Settings/ShowUIControl"))) {
			connect(showUIControlItem, &VeQItem::valueChanged, this, [this](QVariant variant) {
				m_showUIControl = variant;
				updateAllowedInGroupModel();
			});
			m_showUIControl = showUIControlItem->getValue();
			updateAllowedInGroupModel();
		}
		if (VeQItem *stepSizeItem = m_item->itemGetOrCreate(QStringLiteral("Settings/StepSize"))) {
			connect(stepSizeItem, &VeQItem::valueChanged, this, [this](QVariant variant) {
				m_stepSizeString = variant.toString();
				updateDecimals();
			});
			m_stepSizeString = stepSizeItem->getValue().toString();
			updateDecimals();
		}
	} else {
		setState(QVariant());
		setDimming(QVariant());
		setFunction(QVariant());
		setValidFunctions(QVariant());

		m_showUIControl.clear();
		updateAllowedInGroupModel();

		m_stepSizeString.clear();
		updateDecimals();
	}
}

int SwitchableOutput::state() const
{
	return m_state.toInt();
}

void SwitchableOutput::setState(const QVariant &variant)
{
	m_state = variant;
	updateAllowedInGroupModel();
	emit stateChanged();
}

qreal SwitchableOutput::dimming() const
{
	return m_dimming.value<qreal>();
}

void SwitchableOutput::setDimming(const QVariant &variant)
{
	m_dimming = variant;
	updateAllowedInGroupModel();
	emit stateChanged();
}

int SwitchableOutput::function() const
{
	return m_function.toInt();
}

void SwitchableOutput::setFunction(const QVariant &variant)
{
	m_function = variant.toInt();
	updateHasValidFunction();
	if (!m_serviceUid.isEmpty() && BaseDevice::serviceTypeFromUid(m_serviceUid) == QStringLiteral("system")) {
		// For outputs from system relays, the /Function affects whether the output is allowed
		// in a group model.
		updateAllowedInGroupModel();
	}
	emit functionChanged();
}

int SwitchableOutput::validFunctions() const
{
	return m_validFunctions;
}

void SwitchableOutput::setValidFunctions(const QVariant &variant)
{
	m_validFunctions = variant.toInt();
	updateHasValidFunction();
	emit validFunctionsChanged();
}

bool SwitchableOutput::hasValidFunction() const
{
	return m_hasValidFunction;
}

int SwitchableOutput::getDecimals() const
{
	// If /Decimals is set, use that. Otherwise, use the number of decimals found in the /StepSize
	// value (which may be zero).
	if (m_decimalsVariant.isValid()) {
		return m_decimalsVariant.toInt();
	} else {
		// Otherwise, use the number of decimals found in the /StepSize value (which may be zero).
		const int separatorIndex = m_stepSizeString.indexOf('.');
		if (separatorIndex >= 0) {
			return m_stepSizeString.length() - separatorIndex - 1;
		} else {
			return 0;
		}
	}
}

bool SwitchableOutput::getAllowedInGroupModel() const
{
	if (!IOChannel::getAllowedInGroupModel() || !canShowUI(m_showUIControl)) {
		return false;
	}

	// Either valid /State or /Dimming must be valid.
	if (!m_state.isValid() && !m_dimming.isValid()) {
		return false;
	}

	// If this is a system relay, only show the UI control if the function is also set to manual.
	if (!m_serviceUid.isEmpty()
			&& BaseDevice::serviceTypeFromUid(m_serviceUid) == QStringLiteral("system")
			&& (!m_function.isValid() || m_function.toInt() != Enums::SwitchableOutput_Function_Manual)) {
		return false;
	}

	return true;
}

int SwitchableOutput::minimumType() const
{
	return static_cast<int>(Enums::SwitchableOutput_Type_Momentary);
}

int SwitchableOutput::maximumType() const
{
	return static_cast<int>(Enums::SwitchableOutput_Type_MaxSupportedType);
}

void SwitchableOutput::updateHasValidFunction()
{
	const int functionInt = function();
	const bool hasValidFunction = functionInt >= Enums::SwitchableOutput_Function_Alarm
				&& functionInt <= Enums::SwitchableOutput_Function_MaxSupportedType
				&& (validFunctions() & (1 << functionInt));
	if (hasValidFunction != m_hasValidFunction) {
		m_hasValidFunction = hasValidFunction;
		emit hasValidFunctionChanged();
	}
}
