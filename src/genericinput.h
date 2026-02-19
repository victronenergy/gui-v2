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
*/
class GenericInput : public IOChannel
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(qreal value READ value NOTIFY valueChanged FINAL)
	Q_PROPERTY(QString textValue READ textValue NOTIFY textValueChanged FINAL)
	Q_PROPERTY(qreal rangeMin READ rangeMin NOTIFY rangeMinChanged FINAL)
	Q_PROPERTY(qreal rangeMax READ rangeMax NOTIFY rangeMaxChanged FINAL)

public:
	explicit GenericInput(QObject *parent = nullptr);
	GenericInput(QObject *parent, VeQItem *inputItem);

	// Main input values
	qreal value() const;

	// Text representation of the value, according to the custom labels.
	// Returns an empty string if no custom labels are set.
	QString textValue() const;

	// Input settings (under /Settings sub-path)
	qreal rangeMin() const;
	qreal rangeMax() const;

Q_SIGNALS:
	void valueChanged();
	void textValueChanged();
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
	void setRangeMin(const QVariant &variant);
	void setRangeMax(const QVariant &variant);
	void updateTextValue();

	QVariant m_showUIInput;
	QStringList m_labels;
	QString m_textValue;
	qreal m_value;
	qreal m_rangeMin = 0;
	qreal m_rangeMax = 100;
};

} /* VenusOS */
} /* Victron */

#endif // VICTRON_GUIV2_GENERICINPUT_H
