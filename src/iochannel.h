/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_IOCHANNEL_H
#define VICTRON_GUIV2_IOCHANNEL_H

#include <QtGlobal>
#include <QObject>
#include <QPointer>

#include "basedevice.h"
#include "enums.h"

#include <veutil/qt/ve_qitem.hpp>

namespace Victron {
namespace VenusOS {

/*
	A base type for Generic Inputs and Switchable Outputs.

	Any service can provide a generic input or switchable output, under the /GenericInput and
	/SwitchableOutput paths respectively, like this:

		com.victronenergy.custom[.suffix]/GenericInput/<inputId>
		com.victronenergy.custom[.suffix]/SwitchableOutput/<channelId>

	See GenericInput and SwitchableOutput for further details.

	Units
	-----

	The /Settings/Unit value may be one of these special strings:
	  "\Speed" (speed - metres/sec)
	  "\Temperature" (temperature - celsius)
	  "\Volume" (volume - m3)

	If so, the unitType reflects the unit type according to Enums::Units_Type.
	The raw /Settings/Unit value is provided by the unitText property.
*/
class IOChannel : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	QML_UNCREATABLE("Abstract type")
	Q_PROPERTY(QString uid READ uid WRITE setUid NOTIFY uidChanged FINAL)
	Q_PROPERTY(QString serviceUid READ serviceUid NOTIFY serviceUidChanged FINAL)
	Q_PROPERTY(QString channelId READ channelId NOTIFY channelIdChanged FINAL)
	Q_PROPERTY(QString formattedName READ formattedName NOTIFY formattedNameChanged FINAL)
	Q_PROPERTY(int status READ status NOTIFY statusChanged FINAL)
	Q_PROPERTY(int type READ type NOTIFY typeChanged FINAL)
	Q_PROPERTY(int validTypes READ validTypes NOTIFY validTypesChanged FINAL)
	Q_PROPERTY(bool hasValidType READ hasValidType NOTIFY hasValidTypeChanged FINAL)
	Q_PROPERTY(QString group READ group NOTIFY groupChanged FINAL)
	Q_PROPERTY(bool allowedInGroupModel READ allowedInGroupModel NOTIFY allowedInGroupModelChanged FINAL)
	Q_PROPERTY(QString unitText READ unitText NOTIFY unitTextChanged FINAL)
	Q_PROPERTY(int unitType READ unitType NOTIFY unitTypeChanged FINAL)
	Q_PROPERTY(int decimals READ decimals NOTIFY decimalsChanged FINAL)

public:
	explicit IOChannel(QObject *parent = nullptr);

	// The fully qualified uid for the output. For example, for an output on the 'switch' service
	// on D-Bus, it is: com.victronenergy.switch[.suffix]/SwitchableOutput/<channelId>
	QString uid() const;
	void setUid(const QString &uid);

	// The service to which this channel belongs.
	QString serviceUid() const;

	// The identifier for the channel on the service (not necessarily an integer).
	QString channelId() const;

	// A name for the channel, with additional details: if it has no custom name and is in a
	// named group (rather than its default device group), the returned text includes the device
	// name and instance.
	QString formattedName() const;

	// Whether the Type is a supported Type value, and matches the ValidTypes.
	bool hasValidType() const;

	// Whether the channel should be included in a IOChannelGroupModel.
	bool allowedInGroupModel() const;

	// Main operational paths
	int status() const;

	// Settings (under /Settings sub-path)
	int type() const;
	int validTypes() const;
	QString group() const;
	QString unitText() const; // The raw /Unit value
	int unitType() const; // The unit, converted to a Unit_Type value (if applicable)
	int decimals() const;

Q_SIGNALS:
	void uidChanged();
	void serviceUidChanged();
	void channelIdChanged();
	void formattedNameChanged();
	void statusChanged();
	void typeChanged();
	void validTypesChanged();
	void hasValidTypeChanged();
	void groupChanged();
	void allowedInGroupModelChanged();
	void unitTextChanged();
	void unitTypeChanged();
	void decimalsChanged();

protected:
	// Called when the uid changes.
	// Subclasses must also call this when setting the VeQItem for the channel.
	virtual void initialize(VeQItem *item);

	// Called from updateDecimals() to update the decimals property value.
	// The default implementation returns the /Settings/Decimals value.
	virtual int getDecimals() const;

	// Returns true if the channel should be allowed in a group model.
	// The default implementation returns true if hasValidType() is true.
	virtual bool getAllowedInGroupModel() const;

	// Returns the expected minimum and maximum /Type values.
	virtual int minimumType() const = 0;
	virtual int maximumType() const = 0;

	// Returns true if a /ShowUIControl or /ShowUIInput value indicates the control/indicator for
	// the channel can be shown.
	bool canShowUI(const QVariant &showUIValue) const;

	void updateHasValidType();
	void updateAllowedInGroupModel();
	void updateFormattedName();
	void updateDecimals();

private:
	void setStatus(const QVariant &variant);
	void setType(const QVariant &variant);
	void setValidTypes(const QVariant &variant);
	void setGroup(const QVariant &variant);
	void setUnit(const QVariant &variant);
	void setDecimals(const QVariant &variant);

protected:
	// The VeQItem for the input/output, with a uid like this:
	// D-Bus/Mock: <dbus|mock>/com.victronenergy.<serviceType>[.suffix]/<GenericInput|SwitchableOutput>/<channelId>
	// MQTT: mqtt/<serviceType>/<deviceInstance>/<GenericInput|SwitchableOutput>/<channelId>
	QPointer<VeQItem> m_item;

	// The device to which this channel belongs (may be null, e.g. if it belongs to the system service)
	QPointer<BaseDevice> m_device;

	QVariant m_decimalsVariant;
	QString m_serviceUid;
	QString m_name;
	QString m_customName;
	QString m_formattedName;
	QString m_group;
	QString m_unitText;
	int m_status = 0; // Default status is 0 (off)
	int m_type = -1;
	int m_unitType = Enums::Units_None;
	int m_decimals = 0;
	int m_validTypes = 0;
	bool m_hasValidType = false;
	bool m_allowedInGroupModel = false;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_IOCHANNEL_H
