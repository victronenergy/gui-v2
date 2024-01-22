/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "digitimageprovider.h"

#include <QPainter>
#include <QUrlQuery>
#include <QFontDatabase>
#include <QFontMetricsF>
#include <QGuiApplication>

using namespace Victron::VenusOS;

namespace {

QSizeF characterImageSize(const QChar &c, const QFont &font)
{
	if (c.isDigit()) {
		// For digits, return the widest horizontal advance for numbers 0-9 in this font.
		QSizeF maxSize;
		QFontMetricsF metrics(font);
		for (int i = 0; i < 10; ++i) {
			const QChar c = QString::number(i).at(0);
			maxSize = maxSize.expandedTo(QSizeF(metrics.horizontalAdvance(c), metrics.height()));
		}
		return maxSize;
	} else {
		// For symbols, just return the char width, otherwise the image is too wide in the UI.
		QFontMetricsF metrics(font);
		return QSizeF(metrics.horizontalAdvance(c), metrics.height());
	}
}

}


DigitImageProvider::DigitImageProvider()
	: QQuickImageProvider(QQuickImageProvider::Pixmap)
{
	const int fontId = QFontDatabase::addApplicationFont(":/fonts/MuseoSans-500.otf");
	if (fontId < 0) {
		qWarning() << "DigitImageProvider cannot load font!";
	} else {
		m_fontFamilies = QFontDatabase::applicationFontFamilies(fontId);
	}
}

DigitImageProvider::~DigitImageProvider()
{
}

QPixmap DigitImageProvider::requestPixmap(const QString &identifier, QSize *size, const QSize &requestedSize)
{
	// Ignore the sourceSize. Just return an image that fits the font size specified in the request.
	Q_UNUSED(requestedSize);

	const int queryIndex = identifier.indexOf(QLatin1Char('?'));
	if (queryIndex < 0) {
		qWarning() << identifier << "does not specify font size or other attributes!";
		return QPixmap();
	} else if (queryIndex < 0) {
		qWarning() << identifier << "does not specify font size or other attributes!";
		return QPixmap();
	}

	QFont font;
	font.setFamilies(m_fontFamilies);
	QPen pen;

	// Parse the query parameters
	const QUrlQuery query(identifier.mid(queryIndex + 1));
	const QList<QPair<QString, QString>> queryItems = query.queryItems();
	bool isNum = false;
	for (const auto &queryItem : queryItems) {
		if (queryItem.first == QStringLiteral("pixelSize")) {
			const int pixelSize = queryItem.second.toInt(&isNum);
			if (isNum) {
				// Apply devicePixelRatio to ensure text is not blurry.
				font.setPixelSize(pixelSize * qApp->devicePixelRatio());
			} else {
				qWarning() << identifier << "has invalid pixelSize:" << queryItem.second;
			}
		} else if (queryItem.first == QStringLiteral("weight")) {
			const int weight = queryItem.second.toInt(&isNum);
			if (isNum) {
				font.setWeight(static_cast<QFont::Weight>(weight));
			} else {
				qWarning() << identifier << "has invalid weight:" << queryItem.second;
			}
		} else if (queryItem.first == QStringLiteral("color")) {
			QColor color = QColor::fromString(queryItem.second);
			if (color.isValid()) {
				pen.setColor(color);
			} else {
				qWarning() << identifier << "has invalid color:" << queryItem.second;
			}
		}
	}

	// Find the width to use in drawing this digit or symbol.
	const QChar digitOrSymbol = identifier.at(0);
	const QSizeF imageSize = characterImageSize(digitOrSymbol, font);

	QPixmap pixmap(imageSize.toSize());
	pixmap.fill(Qt::transparent);

	// Paint the text into the image.
	QPainter painter(&pixmap);
	painter.setPen(pen);
	painter.setFont(font);

	// When the image is returned, the height adjustment resulting applying the devicePixelRatio
	// causes the quantity number to be misaligned with the unit, so make a small adjustment.
	const int yOffset = 1;
	painter.drawText(QRectF(0, yOffset, pixmap.width(), pixmap.height()), Qt::AlignCenter, digitOrSymbol);

	if (size) {
		*size = imageSize.toSize();
	}

	return pixmap;
}
