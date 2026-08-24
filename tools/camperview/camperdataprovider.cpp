/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "camperdataprovider.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QTimer>

#include <cmath>
#include <limits>

#if defined(__EMSCRIPTEN__)
#include <emscripten/emscripten.h>
#endif

namespace {

QString normalizeInputSource(const QString &input)
{
	const QString lowered = input.trimmed().toLower();
	if (lowered == QStringLiteral("grid")
			|| lowered == QStringLiteral("shore")
			|| lowered == QStringLiteral("generator")) {
		return lowered;
	}
	return QStringLiteral("none");
}

QVariant readFiniteNumber(const QVariantMap &map, const char *key)
{
	const QString mapKey = QString::fromLatin1(key);
	const QVariant value = map.value(mapKey);
	bool ok = false;
	const double number = value.toDouble(&ok);
	return ok && std::isfinite(number) ? QVariant(number) : QVariant();
}

QVariantMap normalizeHostData(const QVariantMap &hostData)
{
	QVariantMap normalized;
	normalized.insert(QStringLiteral("activeInputSource"),
			normalizeInputSource(hostData.value(QStringLiteral("activeInputSource")).toString()));
	normalized.insert(QStringLiteral("gridShorePower"), readFiniteNumber(hostData, "gridShorePower"));
	normalized.insert(QStringLiteral("generatorPower"), readFiniteNumber(hostData, "generatorPower"));
	normalized.insert(QStringLiteral("solarPower"), readFiniteNumber(hostData, "solarPower"));
	normalized.insert(QStringLiteral("batteryPower"), readFiniteNumber(hostData, "batteryPower"));
	normalized.insert(QStringLiteral("batterySoc"), readFiniteNumber(hostData, "batterySoc"));
	normalized.insert(QStringLiteral("alternatorPower"), readFiniteNumber(hostData, "alternatorPower"));
	normalized.insert(QStringLiteral("dcLoadsPower"), readFiniteNumber(hostData, "dcLoadsPower"));
	normalized.insert(QStringLiteral("acLoadsPower"), readFiniteNumber(hostData, "acLoadsPower"));
	return normalized;
}

}

CamperDataProvider::CamperDataProvider(QObject *parent)
	: QObject(parent)
{
	m_refreshTimer = new QTimer(this);
	m_refreshTimer->setInterval(750);
	connect(m_refreshTimer, &QTimer::timeout, this, &CamperDataProvider::refresh);
	m_refreshTimer->start();
	refresh();
}

QVariantMap CamperDataProvider::data() const
{
	return m_data;
}

QString CamperDataProvider::sourceName() const
{
	return m_sourceName;
}

bool CamperDataProvider::hostDataAvailable() const
{
	return m_hostDataAvailable;
}

void CamperDataProvider::refresh()
{
	QVariantMap hostData;
	if (tryReadHostData(&hostData)) {
		applyData(hostData, QStringLiteral("host-js"), true);
		return;
	}

	applyData(buildMockData(), QStringLiteral("mock"), false);
}

QVariantMap CamperDataProvider::buildMockData()
{
	m_mockPhase += 0.18;
	const int mode = (static_cast<int>(m_mockPhase / 6.0)) % 4;
	const double waveA = std::sin(m_mockPhase);
	const double waveB = std::sin(m_mockPhase * 0.77 + 0.6);
	const double waveC = std::sin(m_mockPhase * 0.53 + 0.8);
	const double nan = std::numeric_limits<double>::quiet_NaN();

	QString activeInputSource = QStringLiteral("none");
	double gridShorePower = nan;
	double generatorPower = nan;
	double alternatorPower = 25.0 + 15.0 * waveC; // Stationary default.
	double solarPower = 950.0 + 500.0 * waveB;
	double batteryPower = 180.0 + 260.0 * waveA;
	double batterySoc = 74.0 + 12.0 * waveB;
	double dcLoadsPower = 220.0 + 140.0 * waveC;
	double acLoadsPower = 900.0 + 420.0 * waveB;

	if (mode == 0) {
		activeInputSource = QStringLiteral("shore");
		gridShorePower = 1800.0 + 800.0 * waveA;
		batteryPower = -360.0 - 200.0 * waveA;
		batterySoc = 82.0 + 8.0 * waveB;
		alternatorPower = nan;
	} else if (mode == 1) {
		alternatorPower = 420.0 + 220.0 * waveC; // Driving profile.
		gridShorePower = nan;
		generatorPower = nan;
		solarPower = 560.0 + 360.0 * waveB;
		batteryPower = -120.0 + 220.0 * waveA;
		batterySoc = 66.0 + 9.0 * waveB;
	} else if (mode == 2) {
		activeInputSource = QStringLiteral("generator");
		generatorPower = 2200.0 + 600.0 * waveA;
		solarPower = nan;
		batteryPower = -280.0 - 180.0 * waveB;
		batterySoc = 58.0 + 10.0 * waveA;
		alternatorPower = nan;
	} else {
		activeInputSource = QStringLiteral("none");
		alternatorPower = 30.0 + 15.0 * waveC; // Off-grid profile.
		generatorPower = nan;
		solarPower = 340.0 + 200.0 * waveB;
		batteryPower = 340.0 + 220.0 * waveA;
		batterySoc = 18.0 + 8.0 * waveB;
		acLoadsPower = batterySoc < 13.0 ? nan : acLoadsPower;
	}

	QVariantMap nextData;
	nextData.insert(QStringLiteral("activeInputSource"), activeInputSource);
	nextData.insert(QStringLiteral("gridShorePower"), gridShorePower);
	nextData.insert(QStringLiteral("generatorPower"), generatorPower);
	nextData.insert(QStringLiteral("solarPower"), solarPower);
	nextData.insert(QStringLiteral("batteryPower"), batteryPower);
	nextData.insert(QStringLiteral("batterySoc"), batterySoc);
	nextData.insert(QStringLiteral("alternatorPower"), alternatorPower);
	nextData.insert(QStringLiteral("dcLoadsPower"), dcLoadsPower);
	nextData.insert(QStringLiteral("acLoadsPower"), acLoadsPower);
	return nextData;
}

bool CamperDataProvider::tryReadHostData(QVariantMap *data) const
{
#if defined(__EMSCRIPTEN__)
	static const char script[] =
			"(function(){"
			"  const src = window.camperViewData;"
			"  return JSON.stringify(src ?? null);"
			"})()";
	const char *jsonText = emscripten_run_script_string(script);
	if (!jsonText) {
		return false;
	}

	const QByteArray jsonUtf8(jsonText);
	const QJsonDocument doc = QJsonDocument::fromJson(jsonUtf8);
	if (!doc.isObject()) {
		return false;
	}

	const QVariantMap normalized = normalizeHostData(doc.object().toVariantMap());
	if (normalized.isEmpty()) {
		return false;
	}
	*data = normalized;
	return true;
#else
	Q_UNUSED(data);
	return false;
#endif
}

void CamperDataProvider::applyData(const QVariantMap &data, const QString &sourceName, bool hostDataAvailable)
{
	if (m_data != data) {
		m_data = data;
		emit dataChanged();
	}
	if (m_sourceName != sourceName) {
		m_sourceName = sourceName;
		emit sourceNameChanged();
	}
	if (m_hostDataAvailable != hostDataAvailable) {
		m_hostDataAvailable = hostDataAvailable;
		emit hostDataAvailableChanged();
	}
}
