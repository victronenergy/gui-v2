/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "camperdataprovider.h"

#include <QTimer>

#if defined(__EMSCRIPTEN__)
#include <QJsonDocument>
#include <QJsonObject>
#include <emscripten/emscripten.h>
#endif

CamperDataProvider::CamperDataProvider(QObject *parent)
	: QObject(parent)
{
	m_refreshTimer = new QTimer(this);
#if defined(__EMSCRIPTEN__)
	m_refreshTimer->setInterval(750);
#else
	m_refreshTimer->setInterval(3000);
#endif
	connect(m_refreshTimer, &QTimer::timeout, this, &CamperDataProvider::refresh);
	m_refreshTimer->start();
	refresh();
}

QVariantMap CamperDataProvider::data() const
{
	return m_data;
}

void CamperDataProvider::refresh()
{
	const QVariantMap data = readData();
	if (m_data != data) {
		m_data = data;
		emit dataChanged();
	}
}

QVariantMap CamperDataProvider::readData()
{
#if defined(__EMSCRIPTEN__)
	const char *jsonText = emscripten_run_script_string("JSON.stringify(window.camperViewData ?? null)");
	const QJsonDocument doc = QJsonDocument::fromJson(QByteArray(jsonText));
	return doc.isObject() ? doc.object().toVariantMap() : QVariantMap();
#else
	static const QList<QVariantMap> samples = {
		// Shore charging
		{ { "activeInputSource", 3 }, { "systemState", 3 }, { "activeInputPower", 1800 },
		  { "batteryPower", 560 }, { "batterySoc", 82 }, { "solarPresent", true }, { "solarPower", 300 },
		  { "generatorPresent", true }, { "dcLoadsPower", 220 }, { "acLoadsPower", 900 },
		  { "alternatorState", 0 } },
		// Driving
		{ { "activeInputSource", 240 }, { "systemState", 9 }, { "alternatorState", 4 },
		  { "alternatorPower", 420 }, { "batteryPower", 150 }, { "batterySoc", 66 },
		  { "solarPresent", true }, { "solarPower", 560 }, { "generatorPresent", true },
		  { "dcLoadsPower", 220 }, { "acLoadsPower", 0 } },
		// Off-grid, discharging
		{ { "activeInputSource", 240 }, { "systemState", 9 }, { "alternatorState", 0 },
		  { "alternatorPower", 0 }, { "batteryPower", -400 }, { "batterySoc", 58 },
		  { "solarPresent", true }, { "solarPower", 340 }, { "generatorPresent", true },
		  { "dcLoadsPower", 220 }, { "acLoadsPower", 520 } },
		// Low battery alarm, with the inverter/charger cutting the AC output
		{ { "activeInputSource", 240 }, { "systemState", 2 }, { "alternatorState", 0 },
		  { "alternatorPower", 0 }, { "lowSocAlarm", 2 }, { "veBusLowBatteryAlarm", 2 },
		  { "batteryPower", -300 }, { "batterySoc", 9 }, { "solarPresent", true }, { "solarPower", 0 },
		  { "generatorPresent", true }, { "dcLoadsPower", 220 }, { "acLoadsPower", 0 } },
	};
	const QVariantMap sample = samples.at(m_sampleIndex);
	m_sampleIndex = (m_sampleIndex + 1) % samples.count();
	return sample;
#endif
}
