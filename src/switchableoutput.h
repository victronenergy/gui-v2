/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_SWITCHABLEOUTPUT_H
#define VICTRON_GUIV2_SWITCHABLEOUTPUT_H

#include <QtGlobal>
#include <QObject>
#include <qqmlintegration.h>

#include "iochannel.h"

namespace Victron {
namespace VenusOS {

/*
	An interface for controllable outputs.

	These are specified on a service under the /SwitchableOutput path. For example, for an output
	provided by a 'switch' service, the details are under:
		com.victronenergy.switch[.suffix]/SwitchableOutput/<channelId>

	Further settings are provided under the /Settings path:
		com.victronenergy.switch[.suffix]/SwitchableOutput/<channelId>/Settings/<Group|Type|[etc]>

	System relays configured with a "manual" function are also published as switchable outputs, at:
		com.victronenergy.system/SwitchableOutput/<channelId>
*/
class SwitchableOutput : public IOChannel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(int state READ state NOTIFY stateChanged FINAL)
	Q_PROPERTY(qreal dimming READ dimming NOTIFY dimmingChanged FINAL)
	Q_PROPERTY(int function READ function NOTIFY functionChanged FINAL)
	Q_PROPERTY(int validFunctions READ validFunctions NOTIFY validFunctionsChanged FINAL)
	Q_PROPERTY(bool hasValidFunction READ hasValidFunction NOTIFY hasValidFunctionChanged FINAL)

public:
	explicit SwitchableOutput(QObject *parent = nullptr);
	SwitchableOutput(QObject *parent, VeQItem *outputItem);

	// Whether the Function is a supported Type value, and matches the ValidFunctions.
	bool hasValidFunction() const;

	// Output/channel operational paths
	int state() const;
	qreal dimming() const;

	// Output/channel settings (under /Settings sub-path)
	int function() const;
	int validFunctions() const;

Q_SIGNALS:
	void stateChanged();
	void dimmingChanged();
	void functionChanged();
	void validFunctionsChanged();
	void hasValidFunctionChanged();

protected:
	void initialize(VeQItem *outputItem) override;
	int getDecimals() const override;
	bool getAllowedInGroupModel() const override;
	int minimumType() const override;
	int maximumType() const override;

private:
	void setState(const QVariant &variant);
	void setDimming(const QVariant &variant);
	void setFunction(const QVariant &variant);
	void setValidFunctions(const QVariant &variant);
	void updateHasValidFunction();

	QVariant m_state;
	QVariant m_dimming;
	QVariant m_showUIControl;
	QVariant m_function;
	QString m_stepSizeString;
	int m_validFunctions = 0;
	bool m_hasValidFunction = false;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_SWITCHABLEOUTPUT_H
