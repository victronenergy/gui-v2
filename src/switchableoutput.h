/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_SWITCHABLEOUTPUT_H
#define VICTRON_GUIV2_SWITCHABLEOUTPUT_H

#include <QtGlobal>
#include <QObject>
#include <QPointer>
#include <QMap>
#include <qqmlintegration.h>

#include "basedevice.h"
#include "enums.h"

#include <veutil/qt/ve_qitem.hpp>

namespace Victron {
namespace VenusOS {

/*
	A switchable output (aka "channel").

	The main details for each output are provided under the output uid. For example, for an output
	provided by a 'switch' service, the details are under:
		com.victronenergy.switch[.suffix]/SwitchableOutput/<outputId>

	Further settings are provided under the /Settings path:
		com.victronenergy.switch[.suffix]/SwitchableOutput/<outputId>/Settings/<Group|Type|[etc]>

	System relays configured with a "manual" function are also published as switchable outputs, at:
		com.victronenergy.system/SwitchableOutput/<outputId>


	Units
	-----

	The /Settings/Unit value may be one of these special strings:
	  "\S" (speed - metres/sec)
	  "\T" (temperature - celsius)
	  "\V" (volume - m3)

	If so, the unitType reflects the unit type according to Enums::Units_Type.
	The raw /Settings/Unit value is provided by the unitText property.
*/
class SwitchableOutput : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(QString uid READ uid WRITE setUid NOTIFY uidChanged FINAL)
	Q_PROPERTY(QString outputId READ outputId NOTIFY outputIdChanged FINAL)
	Q_PROPERTY(QString serviceUid READ serviceUid NOTIFY serviceUidChanged FINAL)
	Q_PROPERTY(QString formattedName READ formattedName NOTIFY formattedNameChanged FINAL)
	Q_PROPERTY(int state READ state NOTIFY stateChanged FINAL)
	Q_PROPERTY(int status READ status NOTIFY statusChanged FINAL)
	Q_PROPERTY(qreal dimming READ dimming NOTIFY dimmingChanged FINAL)
	Q_PROPERTY(int type READ type WRITE setType NOTIFY typeChanged FINAL)
	Q_PROPERTY(int validTypes READ validTypes NOTIFY validTypesChanged FINAL)
	Q_PROPERTY(bool hasValidType READ hasValidType NOTIFY hasValidTypeChanged FINAL)
	Q_PROPERTY(int function READ function WRITE setFunction NOTIFY functionChanged FINAL)
	Q_PROPERTY(int validFunctions READ validFunctions NOTIFY validFunctionsChanged FINAL)
	Q_PROPERTY(bool hasValidFunction READ hasValidFunction NOTIFY hasValidFunctionChanged FINAL)
	Q_PROPERTY(QString group READ group NOTIFY groupChanged FINAL)
	Q_PROPERTY(bool allowedInGroupModel READ allowedInGroupModel NOTIFY allowedInGroupModelChanged FINAL)
	Q_PROPERTY(QString unitText READ unitText NOTIFY unitTextChanged FINAL)
	Q_PROPERTY(int unitType READ unitType NOTIFY unitTypeChanged FINAL)
	Q_PROPERTY(int decimals READ decimals NOTIFY decimalsChanged FINAL)

public:
	// Construct without a uid.
	explicit SwitchableOutput(QObject *parent = nullptr);

	// Construct with the uid specified by the outputItem.
	SwitchableOutput(QObject *parent, VeQItem *outputItem);

	// The fully qualified uid for the output. For example, for an output on the 'switch' service
	// on D-Bus, it is: com.victronenergy.switch[.suffix]/SwitchableOutput/<outputId>
	QString uid() const;
	void setUid(const QString &uid);

	// The identifier for the output on its device (not necessarily an integer)
	QString outputId() const;

	// The service to which this output belongs.
	QString serviceUid() const;

	// A name for the output, with additional details: if the output has no custom name and is in a
	// named group (rather than its default device group), the returned text includes the device
	// name and instance.
	QString formattedName() const;

	// Whether the Type is a supported Type value, and matches the ValidTypes.
	bool hasValidType() const;

	// Whether the Function is a supported Type value, and matches the ValidFunctions.
	bool hasValidFunction() const;

	// Whether the output should be included in a SwitchableOutputGroupModel.
	bool allowedInGroupModel() const;

	// Output/channel operational paths
	int state() const;
	int status() const;
	qreal dimming() const;

	// Output/channel settings (under /Settings sub-path)
	int type() const;
	void setType(int type);
	int validTypes() const;
	int function() const;
	void setFunction(int function);
	int validFunctions() const;
	QString group() const;
	QString unitText() const; // The raw /Unit value
	int unitType() const; // The unit, converted to a Unit_Type value (if applicable)
	int decimals() const; // The number of decimals from /Decimals or the /StepSize

	Q_INVOKABLE void setState(int state);
	Q_INVOKABLE void setDimming(qreal dimming);

Q_SIGNALS:
	void uidChanged();
	void outputIdChanged();
	void serviceUidChanged();
	void formattedNameChanged();
	void stateChanged();
	void statusChanged();
	void dimmingChanged();
	void typeChanged();
	void validTypesChanged();
	void hasValidTypeChanged();
	void functionChanged();
	void validFunctionsChanged();
	void hasValidFunctionChanged();
	void groupChanged();
	void allowedInGroupModelChanged();
	void unitTextChanged();
	void unitTypeChanged();
	void decimalsChanged();

private:
	void initialize(VeQItem *outputItem);
	void reset();
	void setTypeFromVariant(const QVariant &typeValue);
	void setValidTypes(const QVariant &validTypesValue);
	void setFunctionFromVariant(const QVariant &typeValue);
	void setValidFunctions(const QVariant &validTypesValue);
	void setUnit(const QVariant &unitValue);
	void setDecimals(const QVariant &decimalsVariant);
	void updateDecimalsFromStepSize(const QVariant &stepSizeVariant);
	void updateDecimals();
	void updateHasValidType();
	void updateHasValidFunction();
	void updateAllowedInGroupModel();
	void updateFormattedName();
	bool shouldShowUiControl() const;

	QPointer<VeQItem> m_outputItem;

	// Main output properties
	QPointer<VeQItem> m_stateItem;
	QPointer<VeQItem> m_statusItem;
	QPointer<VeQItem> m_nameItem;
	QPointer<VeQItem> m_dimmingItem;

	// Settings properties (under /Settings path)
	QPointer<VeQItem> m_typeItem;
	QPointer<VeQItem> m_validTypesItem;
	QPointer<VeQItem> m_functionItem;
	QPointer<VeQItem> m_validFunctionsItem;
	QPointer<VeQItem> m_groupItem;
	QPointer<VeQItem> m_customNameItem;
	QPointer<VeQItem> m_showUIControlItem;

	// The device to which this output belongs (null if this is on the system service)
	QPointer<BaseDevice> m_device;

	QString m_serviceUid;
	QString m_formattedName;
	QString m_unitText;
	QString m_stepSizeString;
	int m_unitType = Enums::Units_None;
	int m_rawDecimals = -1;
	int m_decimals = 0;
	bool m_hasValidType = false;
	bool m_hasValidFunction = false;
	bool m_allowedInGroupModel = false;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_SWITCHABLEOUTPUT_H
