/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "tintedimageprovider.h"

#include <QColor>
#include <QImageReader>
#include <QPainter>
#include <QtDebug>

namespace Victron {
namespace VenusOS {

namespace {

QSize readSize(const QSize &originalSize, const QSize &requestedSize)
{
	const bool hasWidth = requestedSize.width() > 0;
	const bool hasHeight = requestedSize.height() > 0;
	if (hasWidth && hasHeight) {
		return requestedSize;
	}
	if (originalSize.isEmpty()) {
		return QSize();
	}
	if (hasWidth) {
		return QSize(requestedSize.width(),
				qRound(qreal(originalSize.height()) * requestedSize.width() / originalSize.width()));
	}
	if (hasHeight) {
		return QSize(qRound(qreal(originalSize.width()) * requestedSize.height() / originalSize.height()),
				requestedSize.height());
	}
	return originalSize;
}

}

TintedImageProvider::TintedImageProvider()
	: QQuickImageProvider(QQuickImageProvider::Image)
{
}

QImage TintedImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
	const qsizetype separator = id.indexOf(QLatin1Char('/'));
	const QColor color = separator > 0
			? QColor::fromString(QStringLiteral("#") + id.left(separator))
			: QColor();
	const QString path = separator > 0 ? id.mid(separator + 1) : QString();
	if (!color.isValid() || path.isEmpty()) {
		qWarning() << "Tinted image: expected <hex color>/<resource path>, but got:" << id;
		return QImage();
	}

	QImageReader reader(QStringLiteral(":/") + path);
	const QSize originalSize = reader.size();
	const QSize scaledSize = readSize(originalSize, requestedSize);
	if (!scaledSize.isEmpty()) {
		reader.setScaledSize(scaledSize);
	}
	QImage image = reader.read();
	if (image.isNull()) {
		qWarning() << "Tinted image: cannot read" << path << ":" << reader.errorString();
		return image;
	}

	image.convertTo(QImage::Format_ARGB32_Premultiplied);
	QPainter painter(&image);
	painter.setCompositionMode(QPainter::CompositionMode_SourceIn);
	painter.fillRect(image.rect(), color);
	painter.end();

	if (size) {
		*size = originalSize.isValid() ? originalSize : image.size();
	}
	return image;
}

}
}
