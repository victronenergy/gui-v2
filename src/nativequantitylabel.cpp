/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "nativequantitylabel.h"

#include <QtQuick/private/qquickanchors_p_p.h>
#include <QtQuick/private/qquickitem_p.h>

NativeQuantityLabel::NativeQuantityLabel(QQuickItem *parent)
	: QQuickItem(parent)
	, m_row(new QQuickRow(this))
	, m_valueLabel(new QQuickLabel(m_row))
	, m_unitLabel(new QQuickLabel(m_row))
{
	for (QQuickItem *item : QList<QQuickItem *> { m_row, m_valueLabel, m_unitLabel }) {
		static_cast<QQmlParserStatus *>(item)->classBegin();
	}

	QQuickItemPrivate::get(m_unitLabel)->anchors()->setBaseline(
			QQuickAnchorLine(m_valueLabel, QQuickAnchors::BaselineAnchor));
	connect(m_row, &QQuickItem::widthChanged, this, [this]() { setImplicitWidth(m_row->width()); });
	connect(m_row, &QQuickItem::heightChanged, this, [this]() { setImplicitHeight(m_row->height()); });
	connect(this, &NativeQuantityLabel::alignmentChanged, this, &NativeQuantityLabel::updateAlignment);
	connect(this, &NativeQuantityLabel::valueFontFamilyChanged, this, &NativeQuantityLabel::updateValueFont);
	connect(this, &NativeQuantityLabel::baselineRoundingPixelSizeChanged, this,
			&NativeQuantityLabel::updateValueFont);
	connect(m_unitLabel, &QQuickLabel::fontChanged, this, &NativeQuantityLabel::updateValueFont);
	connect(m_unitLabel, &QQuickLabel::fontChanged, this, &NativeQuantityLabel::fontChanged);
	connect(m_valueLabel, &QQuickText::textChanged, this, &NativeQuantityLabel::valueTextChanged);
	connect(m_unitLabel, &QQuickText::textChanged, this, &NativeQuantityLabel::unitTextChanged);
	connect(m_valueLabel, &QQuickText::colorChanged, this, &NativeQuantityLabel::valueColorChanged);
	connect(m_unitLabel, &QQuickText::colorChanged, this, &NativeQuantityLabel::unitColorChanged);
	connect(m_row, &QQuickRow::leftPaddingChanged, this, &NativeQuantityLabel::leftPaddingChanged);
	connect(m_row, &QQuickRow::rightPaddingChanged, this, &NativeQuantityLabel::rightPaddingChanged);
	updateAlignment();
}

void NativeQuantityLabel::componentComplete()
{
	for (QQuickItem *item : QList<QQuickItem *> { m_valueLabel, m_unitLabel, m_row }) {
		QQmlEngine::setContextForObject(item, qmlContext(this));
		static_cast<QQmlParserStatus *>(item)->componentComplete();
	}
	QQuickItem::componentComplete();
	m_row->forceLayout();
	setImplicitSize(m_row->width(), m_row->height());
}

void NativeQuantityLabel::updateValueFont()
{
	// Only size and weight follow the unit font. The value keeps the quantity font and
	// inherits the other font attributes from its enclosing Control, as Label did.
	QFont font;
	font.setFamily(m_valueFontFamily);
	if (m_unitLabel->font().pixelSize() > 0) {
		font.setPixelSize(m_unitLabel->font().pixelSize());
	}
	font.setWeight(m_unitLabel->font().weight());
	m_valueLabel->setFont(font);
	QQuickItemPrivate::get(m_unitLabel)->anchors()->setAlignWhenCentered(
			m_unitLabel->font().pixelSize() >= m_baselineRoundingPixelSize);
}

void NativeQuantityLabel::updateAlignment()
{
	auto *anchors = QQuickItemPrivate::get(m_row)->anchors();
	anchors->resetHorizontalCenter();
	anchors->resetVerticalCenter();
	anchors->resetLeft();
	anchors->resetRight();
	anchors->resetBottom();
	if (m_alignment & Qt::AlignHCenter) {
		anchors->setHorizontalCenter(QQuickAnchorLine(this, QQuickAnchors::HCenterAnchor));
	}
	if (m_alignment & Qt::AlignVCenter) {
		anchors->setVerticalCenter(QQuickAnchorLine(this, QQuickAnchors::VCenterAnchor));
	}
	if (m_alignment & Qt::AlignLeft) {
		anchors->setLeft(QQuickAnchorLine(this, QQuickAnchors::LeftAnchor));
	}
	if (m_alignment & Qt::AlignRight) {
		anchors->setRight(QQuickAnchorLine(this, QQuickAnchors::RightAnchor));
	}
	if (m_alignment & Qt::AlignBottom) {
		anchors->setBottom(QQuickAnchorLine(this, QQuickAnchors::BottomAnchor));
	}
}
