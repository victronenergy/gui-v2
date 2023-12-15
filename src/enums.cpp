/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "enums.h"

namespace Victron {
namespace VenusOS {

QObject* Enums::instance(QQmlEngine *, QJSEngine *)
{
	return new Enums;
}

Enums::Enums(QObject *parent)
	: QObject(parent)
{
}

Enums::~Enums()
{
}

QString Enums::dcInputIcon(DcInputs_InputType type)
{
	switch (type) {
	case DcInputs_InputType_Alternator:
		return "qrc:/images/alternator.svg";
	case DcInputs_InputType_DcGenerator:
		return "qrc:/images/generator.svg";
	case DcInputs_InputType_Wind:
		return "qrc:/images/wind.svg";
	default:
		return "qrc:/images/icon_dc_24.svg";
	}
}

}
}
