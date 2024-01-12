/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "theme.h"

#include <QFontMetricsF>
#include <QRectF>

namespace Victron {
namespace VenusOS {

qreal Theme::characterWidthNumber(const QFont &font) const
{
	return fontInfo(font).numberWidth;
}

qreal Theme::characterWidthAlpha(const QFont &font) const
{
	return fontInfo(font).alphaWidth;
}

qreal Theme::characterAdvanceWidth(const QFont &font) const
{
	return fontInfo(font).advanceWidth;
}

qreal Theme::characterDotDeltaWidth(const QFont &font) const
{
	return fontInfo(font).dotDeltaWidth;
}

qreal Theme::characterMinusDeltaWidth(const QFont &font) const
{
	return fontInfo(font).minusDeltaWidth;
}

// special case for temperatures/percentages
// since 444 is much wider than 100.
qreal Theme::charactersOneHundredWidth(const QFont &font) const
{
	return fontInfo(font).oneHundredWidth;
}

const FontInfo& Theme::fontInfo(const QFont &font) const
{
	for (const FontInfo &fi : qAsConst(m_fontInfo)) {
		if (fi.font == font) {
			return fi;
		}
	}

	// It would be better if we had QFontMetrics::maxDigitWidth(),
	// but by experimentation we find that "4" is the widest in our font.
	QFontMetricsF metrics(font);
	FontInfo newFi;
	newFi.font = font;
	newFi.numberWidth = metrics.boundingRect(QChar('4')).width();
	newFi.alphaWidth = metrics.boundingRect(QChar('W')).width(); // could use maxWidth()...
	newFi.advanceWidth = metrics.boundingRect(QStringLiteral("44")).width() - (2*newFi.numberWidth);
	newFi.dotDeltaWidth = newFi.numberWidth - metrics.boundingRect(QChar('.')).width();
	newFi.minusDeltaWidth = newFi.numberWidth - metrics.boundingRect(QChar('-')).width();
	newFi.oneHundredWidth = metrics.boundingRect(QStringLiteral("100")).width() + 6; // fudge factor...
	m_fontInfo.append(newFi);
	return m_fontInfo[m_fontInfo.count() - 1];
}

} // VenusOS
} // Victron
