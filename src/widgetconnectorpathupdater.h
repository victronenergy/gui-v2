/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_WIDGETCONNECTORPATHUPDATER_H
#define VICTRON_VENUSOS_GUI_V2_WIDGETCONNECTORPATHUPDATER_H

#include <QQuickItem>
#include <QVector>

#include "enums.h"

#include <QtQuick/private/qquickpath_p.h>

namespace Victron {
namespace VenusOS {

class WidgetConnectorPathUpdater : public QObject
{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(qreal progress MEMBER progress NOTIFY progressChanged FINAL)
	Q_PROPERTY(QQuickPath *path READ getPath WRITE setPath NOTIFY pathChanged FINAL)
	Q_PROPERTY(qreal fadeOutThreshold MEMBER fadeOutThreshold FINAL)
	Q_PROPERTY(Victron::VenusOS::Enums::WidgetConnector_AnimationMode animationMode MEMBER animationMode FINAL)
	// Milliseconds an electron takes to travel the whole path, and to fade out at
	// the end of it. Both are needed to calculate the electron's opacity.
	Q_PROPERTY(qreal duration MEMBER duration NOTIFY durationChanged FINAL)
	Q_PROPERTY(qreal fadeDuration MEMBER fadeDuration NOTIFY fadeDurationChanged FINAL)

public:
	// The opacity values an electron is faded between.
	//
	// The scene graph renderer classifies an item by its opacity, and it forces a
	// full rebuild of every batch in the window whenever that classification
	// changes: below 0.001 the item's subtree is blocked and its geometry leaves
	// the render lists, and above 0.999 the item becomes eligible to be treated as
	// opaque. A full rebuild re-uploads the vertex data of the entire scene, not
	// just of the electrons, which on a GX device cost ~4ms.
	//
	// Fading between two values that sit strictly inside that range means an
	// electron never changes classification, so fading in and out no longer causes
	// any full rebuild. Neither endpoint is visually distinguishable from the true
	// 0.0 and 1.0 that they replace: the faded out electron contributes less than
	// half of one 8-bit alpha step, and the faded in one is within half a step of
	// fully opaque.
	static constexpr qreal FadedOutOpacity = 0.002;
	static constexpr qreal FadedInOpacity = 0.996;

	explicit WidgetConnectorPathUpdater(QObject *parent = nullptr);
	~WidgetConnectorPathUpdater() override;

	QQuickPath *getPath() const;
	void setPath(QQuickPath *newPath);

	Q_INVOKABLE void add(QQuickItem *electron);
	Q_INVOKABLE void remove(QQuickItem *electron);

	Q_INVOKABLE void update();
	Q_INVOKABLE qreal angleForArrow(qreal progress, bool startToEnd);
	Q_INVOKABLE void invalidateLut();

signals:
	void progressChanged();
	void pathChanged();
	void durationChanged();
	void fadeDurationChanged();

private:
	struct PathPoint {
		QPointF position;
		qreal angle = 0;
	};

	static constexpr int LUT_SIZE = 512;

	void rebuildLut();
	PathPoint sampleLut(qreal progress) const;
	qreal opacityAt(qreal normalizedProgress) const;

	qreal progress = 0;
	QPointer<QQuickPath> path;
	qreal fadeOutThreshold = 1.0;
	qreal duration = 0;
	qreal fadeDuration = 0;
	Victron::VenusOS::Enums::WidgetConnector_AnimationMode animationMode =
		Victron::VenusOS::Enums::WidgetConnector_AnimationMode_NotAnimated;
	QList<QPointer<QQuickItem>> electrons;

	QVector<PathPoint> m_lut;
	bool m_lutValid = false;
};

}
}

#endif // VICTRON_VENUSOS_GUI_V2_WIDGETCONNECTORPATHUPDATER_H
