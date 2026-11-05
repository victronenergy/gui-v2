/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUIV2_TINTEDIMAGEPROVIDER_H
#define VICTRON_VENUSOS_GUIV2_TINTEDIMAGEPROVIDER_H

#include <QQuickImageProvider>

namespace Victron {
namespace VenusOS {

/*
	Provides an image from the resources, with every pixel painted in one color. Each pixel keeps
	its transparency, as with ColorImage. This is for single-color art that an Image cannot tint,
	such as the image of a BorderImage.

	The URL is image://tinted/<color>/<path>, where <color> is a hex color without the leading '#'
	("rrggbb" or "aarrggbb"), and <path> is the image's path in the resources. For example:
		image://tinted/72b84c/images/key_navigation_highlight.svg

	If the item sets sourceSize, the image is read at that size. If only the width or only the
	height is set, the image keeps its aspect ratio.
*/
class TintedImageProvider : public QQuickImageProvider
{
public:
	static constexpr QLatin1StringView ProviderId = QLatin1StringView("tinted");

	TintedImageProvider();

	QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;
};

}
}

#endif // VICTRON_VENUSOS_GUIV2_TINTEDIMAGEPROVIDER_H
