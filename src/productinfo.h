/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_PRODUCTINFO_H
#define VICTRON_VENUSOS_GUI_V2_PRODUCTINFO_H

#include <QQmlEngine>
#include <QObject>

namespace Victron {
namespace VenusOS {

class ProductInfo : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	QML_SINGLETON

public:
	explicit ProductInfo(QObject * = nullptr) {}
	~ProductInfo() override {}

	enum ProductId_Alternator {
		ProductId_Alternator_Wakespeed = 0xB080, // VE_PROD_ID_WAKESPEED_WS500
		ProductId_Alternator_Arco = 0xB090,
		ProductId_Alternator_Generic = 0xB091,
		ProductId_Alternator_Integrel = 0xB092,
		ProductId_Alternator_MgAfc = 0xB0F0,
		ProductId_Alternator_Altion = 0xB093,
	};
	Q_ENUM(ProductId_Alternator)

	enum ProductId_Battery {
		ProductId_Battery_ParallelBms = 0xA3E3,
		ProductId_Battery_Fiamm48TL = 0xB012,
	};
	Q_ENUM(ProductId_Battery)

	enum ProductId_Genset {
		ProductId_Genset_FischerPandaAc = 0xB040,
		ProductId_Genset_ComAp = 0xB044,
		ProductId_Genset_Hatz = 0xB045,
		ProductId_Genset_Dse = 0xB046,
		ProductId_Genset_FischerPandaDc = 0xB047,
		ProductId_Genset_Cre = 0xB048,
		ProductId_Genset_Deif = 0xB049,
		ProductId_Genset_Cummins = 0xB04A,
	};
	Q_ENUM(ProductId_Genset)

	enum ProductId_Misc {
		ProductId_EnergyMeter_CarloGavazzi = 0xB002, // VE_PROD_ID_CARLO_GAVAZZI_EM
		ProductId_EnergyMeter_Em24 = 0xB017,
		ProductId_OrionXs_Min = 0xA3F0,
		ProductId_OrionXs_Max = 0xA3FF,
		ProductId_PowerBox_Smappee = 0xB018,
		ProductId_PvInverter_Fronius = 0xA142, // VE_PROD_ID_PV_INVERTER_FRONIUS
		ProductId_TankSensor_Generic = 0xA160,
		ProductId_MeteoSensor_Imt = 0xB030, // VE_PROD_ID_IMT_SI_RS485_SOLAR_IRRADIANCE_SENSOR
	};
	Q_ENUM(ProductId_Misc)

	Q_INVOKABLE bool isGensetProduct(int productId) {
		switch (productId) {
		case ProductId_Genset_FischerPandaAc:
		case ProductId_Genset_ComAp:
		case ProductId_Genset_Hatz:
		case ProductId_Genset_Dse:
		case ProductId_Genset_FischerPandaDc:
		case ProductId_Genset_Cre:
		case ProductId_Genset_Deif:
		case ProductId_Genset_Cummins:
			return true;
		default:
			return false;
		};
	}

	Q_INVOKABLE bool isOrionXsProduct(int productId) {
		return productId >= ProductId_OrionXs_Min && productId <= ProductId_OrionXs_Max;
	}

	Q_INVOKABLE bool isRealAlternatorProduct(int productId) {
		switch (productId) {
		case ProductId_Alternator_Arco:
		case ProductId_Alternator_Wakespeed:
		case ProductId_Alternator_MgAfc:
		case ProductId_Alternator_Generic:
		case ProductId_Alternator_Integrel:
		case ProductId_Alternator_Altion:
			return true;
		default:
			return false;
		};
	}
};

}
}

#endif // VICTRON_VENUSOS_GUI_V2_PRODUCTINFO_H
