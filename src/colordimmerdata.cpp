/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "colordimmerdata.h"
#include "fastutils.h"

#include <QQmlInfo>
#include <QQmlEngine>

using namespace Victron::VenusOS;

namespace {

qreal variantToReal(const QVariant &value)
{
	return static_cast<qreal>(std::min(std::numeric_limits<qreal>::max(), value.toDouble()));
}

/*
	Read/write color data from/to the given QVariantList, which is a list of doubles in this format:

	0: Hue 0-359 degrees
	1: Saturation 0-100%
	2: Brightness 0-100%
	3: White 0-100%
	4: ColorTemperature 0-65000K

	Note the H,S,V value ranges differ from the range expected for the QColor::setHsvF() and
	QColor::getHsvF() parameters, which is 0.0-1.0 for all three values.
*/
void getStorageColorData(const QVariantList &colorData, QColor *color, qreal *white, qreal *colorTemperature)
{
	if (colorData.count() != 5) {
		qWarning() << "getStorageColorData() failed: expected 5 items but list is:" << colorData;
		return;
	}
	if (color) {
		const qreal h = variantToReal(colorData.value(0));
		const qreal s = variantToReal(colorData.value(1));
		const qreal v = variantToReal(colorData.value(2));
		color->setHsvF(FastUtils::create()->scaleNumber(h, 0, 359, 0, 1), s / 100, v / 100);
	}
	if (white) {
		*white = variantToReal(colorData.value(3));
	}
	if (colorTemperature) {
		*colorTemperature = variantToReal(colorData.value(4));
	}
}
void addStorageColorData(QList<double> *colorData, const QColor color, qreal white, qreal colorTemperature)
{
	float h, s, v;
	color.getHsvF(&h, &s, &v);
	colorData->append(FastUtils::create()->scaleNumber(h, 0, 1, 0, 359));
	colorData->append(s * 100);
	colorData->append(v * 100);
	colorData->append(white);
	colorData->append(colorTemperature);
}

}

ColorDimmerData::ColorDimmerData(QObject *parent)
	: QObject(parent)
{
}

QString ColorDimmerData::dataUid() const
{
	return m_colorDataItem ? m_colorDataItem->uniqueId() : QString();
}

void ColorDimmerData::setDataUid(const QString &dataUid)
{
	if (!m_colorDataItem || m_colorDataItem->uniqueId() != dataUid) {
		m_colorDataItem = VeQItems::getRoot()->itemGet(dataUid);
		if (!m_colorDataItem) {
			qmlWarning(this) << "dataUid: " << dataUid << " has no matching VeQItem, colors will not be saved";
		}
		if (m_colorDataItem)
			connect(m_colorDataItem, &VeQItem::valueChanged, this, &ColorDimmerData::colorDataChanged);
		reload();
		emit dataUidChanged();
	}
}

QColor ColorDimmerData::color() const
{
	return m_color;
}

void ColorDimmerData::setColor(const QColor &color)
{
	if (m_color != color) {
		m_color = color;
		emit colorChanged();
	}
}

qreal ColorDimmerData::white() const
{
	return m_white;
}

void ColorDimmerData::setWhite(qreal white)
{
	if (m_white != white) {
		m_white = white;
		emit whiteChanged();
	}
}

qreal ColorDimmerData::colorTemperature() const
{
	return m_colorTemperature;
}

void ColorDimmerData::setColorTemperature(qreal colorTemperature)
{
	if (m_colorTemperature != colorTemperature) {
		m_colorTemperature = colorTemperature;
		emit colorTemperatureChanged();
	}
}

void ColorDimmerData::classBegin()
{
}

void ColorDimmerData::componentComplete()
{
	m_completed = true;
	reload();
}

void ColorDimmerData::colorDataChanged(QVariant var)
{
	reload();
}

void ColorDimmerData::reload()
{
	if (!m_completed || !m_colorDataItem) {
		return;
	}

	const QVariantList colorData = m_colorDataItem->getValue().toList();
	QColor color;
	qreal white = 0;
	qreal colorTemperature = 0;
	::getStorageColorData(colorData, &color, &white, &colorTemperature);

	setColor(color);
	setWhite(white);
	setColorTemperature(colorTemperature);
}

void ColorDimmerData::loadFromPreset(const QVariantMap &values)
{
	setColor(values.value(QStringLiteral("color")).value<QColor>());
	setWhite(values.value(QStringLiteral("white")).value<qreal>());
	setColorTemperature(values.value(QStringLiteral("colorTemperature")).value<qreal>());
	save();
}

void ColorDimmerData::save()
{
	if (m_colorDataItem) {
		QList<double> dataList;
		::addStorageColorData(&dataList, m_color, m_white, m_colorTemperature);
		m_colorDataItem->setValue(QVariant::fromValue(dataList));
	}
}


ColorPresetModel::ColorPresetModel(QObject *parent)
	: QAbstractListModel(parent)
{
}

QString ColorPresetModel::settingUid() const
{
	return m_settingItem ? m_settingItem->uniqueId() : QString();
}

void ColorPresetModel::setSettingUid(const QString &settingUid)
{
	if (!m_settingItem || m_settingItem->uniqueId() != settingUid) {
		VeQItem *settingItem = VeQItems::getRoot()->itemGet(settingUid);
		if (!settingItem) {
			qmlWarning(this) << "settingUid: " << settingUid << " has no matching VeQItem, colors will not be saved";
		}
		m_settingItem = settingItem;
		reload();
		emit settingUidChanged();
	}
}

int ColorPresetModel::count() const
{
	return m_colors.count();
}

QVariant ColorPresetModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();
	if (row < 0 || row >= m_colors.count()) {
		return QVariant();
	}

	switch (role)
	{
	case ColorRole:
		return m_colors.at(row).color;
	}
	return QVariant();
}

int ColorPresetModel::rowCount(const QModelIndex &) const
{
	return count();
}

void ColorPresetModel::classBegin()
{
}

void ColorPresetModel::componentComplete()
{
	m_completed = true;
	reload();
}

QVariantMap ColorPresetModel::get(int index) const
{
	QVariantMap map;
	if (index >= 0 && index < m_colors.count()) {
		const ColorInfo &info = m_colors.at(index);
		map.insert(QStringLiteral("color"), info.color);
		map.insert(QStringLiteral("white"), info.white);
		map.insert(QStringLiteral("colorTemperature"), info.colorTemperature);
	}
	return map;
}

QHash<int, QByteArray> ColorPresetModel::roleNames() const
{
	static const QHash<int, QByteArray> roles {
		{ ColorRole, "color" },
	};
	return roles;
}

void ColorPresetModel::setPreset(int index, const QColor &color, qreal white, qreal colorTemperature)
{
	if (index < 0 || index >= m_colors.count()) {
		qmlWarning(this) << "setColor: invalid index!";
		return;
	}
	m_colors[index].color = color;
	m_colors[index].white = white;
	m_colors[index].colorTemperature = colorTemperature;
	emit dataChanged(createIndex(index, 0), createIndex(index, 0), { ColorRole });
	save();
}

void ColorPresetModel::clearPreset(int index)
{
	if (index < 0 || index >= m_colors.count()) {
		qmlWarning(this) << "clearColor: invalid index!";
		return;
	}
	m_colors[index].color = QColor();
	m_colors[index].white = 0;
	m_colors[index].colorTemperature = 0;
	emit dataChanged(createIndex(index, 0), createIndex(index, 0), { ColorRole });
	save();
}

void ColorPresetModel::save()
{
	if (!m_settingItem) {
		qmlWarning(this) << "Cannot save, no settingUid set!";
		return;
	}

	for (int i = 0; i < m_colors.count(); ++i) {
		if (VeQItem *presetItem = m_settingItem->itemGetOrCreate(QString::number(i))) {
			const ColorInfo &info = m_colors.at(i);
			if (info.color.isValid()) {
				QList<double> colorData;
				::addStorageColorData(&colorData, info.color, info.white, info.colorTemperature);
				presetItem->setValue(QVariant::fromValue(colorData));
			} else {
				presetItem->setValue(QVariant());
			}
		}
	}
}

void ColorPresetModel::reload()
{
	if (!m_completed) {
		return;
	}
	if (!m_settingItem) {
		qmlWarning(this) << "settingsUid not set!";
		return;
	}

	if (m_colors.count()) {
		beginResetModel();
		m_colors.clear();
		endResetModel();
		emit countChanged();
	}

	static const int presetCount = 9;
	beginInsertRows(QModelIndex(), 0, presetCount - 1);
	for (int i = 0; i < presetCount; ++i) {
		QColor color;
		qreal white = 0;
		qreal colorTemperature = 0;
		if (VeQItem *presetItem = m_settingItem->itemGet(QString::number(i))) {
			const QVariantList colorData = presetItem->getValue().toList();
			if (!colorData.isEmpty()) {
				::getStorageColorData(colorData, &color, &white, &colorTemperature);
			}
		}
		m_colors.append({ color, white, colorTemperature });
	}
	endInsertRows();
	emit countChanged();
}
