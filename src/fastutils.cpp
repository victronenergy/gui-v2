/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "fastutils.h"

#include <QFontMetricsF>

namespace Victron {
namespace VenusOS {

FastUtils::FastUtils(QObject *parent)
	: QObject(parent)
{
}

FastUtils::~FastUtils()
{
}

// this properly belongs in a utils class, but there is no cpp utils currently.
QList<qreal> FastUtils::calculateLoadGraphYValues(const QList<qreal> &data, int dataLen, qreal height) const
{
	QList<qreal> ret;
	ret.reserve(dataLen);
	for (int i = 0; i < dataLen; ++i) {
		ret.append((1.0 - (data.count() <= i ? 0.0 : data[i])) * height);
	}
	return ret;
}

qreal FastUtils::degreesToRadians(const qreal degrees) const
{
	return degrees * 0.017453292519943295;  // Math.PI/180
}

// Find the largest pixel size for text which will fit in the specified maxWidth.
// If the Theme singleton is specified, check the various theme values from largest to smallest.
// Otherwise, use binary search to find an arbitrary font size which works.
int FastUtils::fittedPixelSize(const QString &text, const qreal maxWidth, int minPixelSize, int maxPixelSize, const QFont &font, ThemeSingleton *theme) const
{
	if (maxWidth <= 0 || maxPixelSize <= 0 || minPixelSize == maxPixelSize || text.isEmpty()) {
		return minPixelSize;
	}

	int currPixelSize;
	QFont fittedFont(font);

	if (theme) {
		static const QList<int> fontSizes {
			theme->font_size_h5(),
			theme->font_size_h4(),
			theme->font_size_h3(),
			theme->font_size_h2(),
			theme->font_size_h1(),
			theme->font_size_body3(),
			theme->font_size_body2(),
			theme->font_size_body1(),
			theme->font_size_caption(),
			theme->font_size_phase_medium(),
			theme->font_size_phase_small(),
			theme->font_size_phase_number(),
		};

		for (int i = 0; i < fontSizes.size(); ++i) {
			currPixelSize = fontSizes[i];
			if (currPixelSize > maxPixelSize) {
				continue;
			} else if (currPixelSize <= minPixelSize) {
				break;
			}
			fittedFont.setPixelSize(currPixelSize);
			const QFontMetricsF fm(fittedFont);
			const QRectF rect = fm.tightBoundingRect(text);
			if ((rect.x() + rect.width()) <= maxWidth) {
				return currPixelSize;
			}
		}

		return minPixelSize;
	}

	// fall back to binary search.
	while (minPixelSize < maxPixelSize) {
		currPixelSize = minPixelSize + (maxPixelSize - minPixelSize + 1) / 2;
		fittedFont.setPixelSize(currPixelSize);
		const QFontMetricsF fm(fittedFont);
		const QRectF rect = fm.tightBoundingRect(text);
		if ((rect.x() + rect.width()) <= maxWidth) {
			minPixelSize = currPixelSize;
		} else {
			maxPixelSize = currPixelSize - 1;
		}
	}
	return minPixelSize;
}

}
}
