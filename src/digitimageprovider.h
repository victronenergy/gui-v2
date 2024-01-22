/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef DIGITIMAGEPROVIDER_H
#define DIGITIMAGEPROVIDER_H

#include <QQuickImageProvider>

namespace Victron {

namespace VenusOS {

class DigitImageProvider : public QQuickImageProvider
{
	Q_OBJECT

public:
	DigitImageProvider();
	~DigitImageProvider();

	QPixmap requestPixmap(const QString &identifier, QSize *size, const QSize &requestedSize) override;

private:
	QStringList m_fontFamilies;
};

} /* VenusOS */

} /* Victron */
#endif // DIGITIMAGEPROVIDER_H
