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

QString Enums::acInputIcon(AcInputs_InputType type)
{
	switch (type) {
	case AcInputs_InputType_Unused:
		return "";
	case AcInputs_InputType_Grid:
		return "qrc:/images/grid.svg";
	case AcInputs_InputType_Generator:
		return "qrc:/images/generator.svg";
	case AcInputs_InputType_Shore:
		return "qrc:/images/shore.svg";
	default:
		break;
	}
	return QString();
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
