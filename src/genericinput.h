/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_GENERICINPUT_H
#define VICTRON_GUIV2_GENERICINPUT_H

#include <QtGlobal>
#include <QObject>
#include <qqmlintegration.h>

#include "iochannel.h"

namespace Victron {
namespace VenusOS {

/*
	An interface for an input with displayable read-only values.

	The main details for each input are provided under the /GenericInput. For example, for an input
	provided by a 'switch' service, the details are under:
		com.victronenergy.switch[.suffix]/GenericInput/<channelId>

	Further settings are provided under the /Settings path:
		com.victronenergy.switch[.suffix]/GenericInput/<channelId>/Settings/<Group|Type|[etc]>

	Labels
	------
	When inputs of the GenericInput_Type_Discrete type also define a /Settings/Labels value, the
	appropriate value is provided as GenericInput::textValue. For example:

	[input-service]/GenericInput/<inputId>/Value: 1
	[input-service]/GenericInput/<inputId>/Settings/Labels: ["off", "eco", "auto"]

	Here, GenericInput::value=1 and GenericInput::textValue="eco", as the label at index 1 is "eco".

	If a label starts with a '/' character, this indicates it is a reserved keyboard for which
	GenericInput will automatically provide a translated string.
*/
class GenericInput : public IOChannel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(qreal value READ value NOTIFY valueChanged FINAL)
	Q_PROPERTY(QString textValue READ textValue NOTIFY textValueChanged FINAL)
	Q_PROPERTY(QString primaryLabel READ primaryLabel NOTIFY primaryLabelChanged FINAL)
	Q_PROPERTY(qreal rangeMin READ rangeMin NOTIFY rangeMinChanged FINAL)
	Q_PROPERTY(qreal rangeMax READ rangeMax NOTIFY rangeMaxChanged FINAL)

public:
	explicit GenericInput(QObject *parent = nullptr);
	GenericInput(QObject *parent, VeQItem *inputItem);

	// Main input values
	qreal value() const;

	// Text representation of the value, according to the /Settings/Labels value.
	// Returns an empty string if no custom labels are set.
	QString textValue() const;

	// Input settings (under /Settings sub-path)
	QString primaryLabel() const;
	qreal rangeMin() const;
	qreal rangeMax() const;

Q_SIGNALS:
	void valueChanged();
	void textValueChanged();
	void primaryLabelChanged();
	void rangeMinChanged();
	void rangeMaxChanged();

protected:
	void initialize(VeQItem *inputItem) override;
	bool getAllowedInGroupModel() const override;
	int minimumType() const override;
	int maximumType() const override;

private:
	void setValue(const QVariant &variant);
	void setLabels(const QVariant &variant);
	void setPrimaryLabel(const QVariant &variant);
	void setRangeMin(const QVariant &variant);
	void setRangeMax(const QVariant &variant);
	void updateTextValue();

	QVariant m_showUIInput;
	QStringList m_labels;
	QString m_textValue;
	QString m_primaryLabel;
	qreal m_value;
	qreal m_rangeMin = 0;
	qreal m_rangeMax = 100;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_GENERICINPUT_H
