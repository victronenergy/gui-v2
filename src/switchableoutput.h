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
	Q_PROPERTY(int type READ type NOTIFY typeChanged FINAL)
	Q_PROPERTY(QString group READ group NOTIFY groupChanged FINAL)
	Q_PROPERTY(bool allowedInGroupModel READ allowedInGroupModel NOTIFY allowedInGroupModelChanged FINAL)

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

	// Whether the output should be included in a SwitchableOutputGroupModel.
	bool allowedInGroupModel() const;

	// Output/channel operational paths
	int state() const;
	int status() const;
	qreal dimming() const;

	// Output/channel settings (under /Settings sub-path)
	int type() const;
	QString group() const;

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
	void groupChanged();
	void allowedInGroupModelChanged();

private:
	void initialize(VeQItem *outputItem);
	void reset();
	void setType(const QVariant &typeValue);
	void updateAllowedInGroupModel();
	void updateFormattedName();

	QPointer<VeQItem> m_outputItem;

	// Main output properties
	QPointer<VeQItem> m_stateItem;
	QPointer<VeQItem> m_statusItem;
	QPointer<VeQItem> m_nameItem;
	QPointer<VeQItem> m_dimmingItem;

	// Settings properties (under /Settings path)
	QPointer<VeQItem> m_typeItem;
	QPointer<VeQItem> m_groupItem;
	QPointer<VeQItem> m_customNameItem;
	QPointer<VeQItem> m_showUIControlItem;

	// The device to which this output belongs (null if this is on the system service)
	QPointer<BaseDevice> m_device;

	// Value of /Relay/Function if this is on the system service
	QPointer<VeQItem> m_relayFunctionItem;

	QString m_serviceUid;
	QString m_formattedName;
	bool m_allowedInGroupModel = false;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_SWITCHABLEOUTPUT_H
