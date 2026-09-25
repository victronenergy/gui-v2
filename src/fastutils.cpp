/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "fastutils.h"

#include <QFontMetricsF>
#include <QGuiApplication>
#include <QQmlEngine>
#include <QQmlIncubator>
#include <QQuickItem>
#include <QQuickWindow>

#include <private/qqmlengine_p.h>
#include <private/qqmlincubator_p.h>

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
	return qIsNaN(degrees) ? 0 : degrees * 0.017453292519943295;  // Math.PI/180
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
			theme->font_size_tiny(),
			theme->font_size_micro(),
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

namespace {

bool inSubtree(const QObject *obj, const QObject *root)
{
	if (!obj || !root) {
		return false;
	}
	for (const QObject *p = obj; p; p = p->parent()) {
		if (p == root) {
			return true;
		}
	}
	if (const auto *item = qobject_cast<const QQuickItem *>(obj)) {
		for (const QQuickItem *p = item->parentItem(); p; p = p->parentItem()) {
			if (p == root) {
				return true;
			}
		}
	}
	return false;
}

bool incubatorBelongsTo(const QQmlIncubatorPrivate *incubator, const QObject *root)
{
	if (inSubtree(incubator->result, root)) {
		return true;
	}
	for (QQmlRefPointer<QQmlContextData> ctx = incubator->rootContext; ctx; ctx = ctx->parent()) {
		if (inSubtree(ctx->contextObject(), root)) {
			return true;
		}
	}
	return false;
}

bool hasIncubationFor(QObject *root)
{
	QQmlEngine *engine = qmlEngine(root);
	if (!engine) {
		return false;
	}
	QQmlEnginePrivate *ep = QQmlEnginePrivate::get(engine);
	for (QQmlEnginePrivate::Incubator *inc : ep->incubatorList) {
		if (incubatorBelongsTo(static_cast<const QQmlIncubatorPrivate *>(inc), root)) {
			return true;
		}
	}
	return false;
}

QQmlIncubationController *incubationControllerFor(QObject *object)
{
	QQuickWindow *window = qobject_cast<QQuickWindow *>(object);
	if (!window) {
		if (auto *item = qobject_cast<QQuickItem *>(object)) {
			window = item->window();
		}
	}
	if (!window) {
		const QWindowList windows = QGuiApplication::allWindows();
		for (QWindow *w : windows) {
			window = qobject_cast<QQuickWindow *>(w);
			if (window) {
				break;
			}
		}
	}
	return window ? window->incubationController() : nullptr;
}

}

void FastUtils::drainIncubators(QObject *object) const
{
	if (!object) {
		return;
	}

	QQmlIncubationController *controller = incubationControllerFor(object);

	// Complete nested incubators for this object. incubateFor() is a GUI-thread
	// hitch (no event loop). Loop on this subtree, not incubatingObjectCount();
	// that is window-wide. Do not cap and detach anyway.
	while (hasIncubationFor(object)) {
		if (!controller || controller->incubatingObjectCount() == 0) {
			break;
		}
		controller->incubateFor(16);
	}
}

QObject *FastUtils::containingPage(QObject *object) const
{
	for (QObject *p = object; p; p = p->parent()) {
		if (p->property("__is_venus_gui_page__").toBool()) {
			return p;
		}
	}
	return nullptr;
}

FastUtils* FastUtils::create(QQmlEngine *, QJSEngine *)
{
	static FastUtils *instance = new FastUtils;
	return instance;
}


void ValueRange::setMinimumValue(qreal v)
{
	if (m_minimumValue != v) {
		m_minimumValue = v;
		updateValueAsRatio();
		Q_EMIT minimumValueChanged();
	}
}

void ValueRange::setMaximumValue(qreal v)
{
	if (m_maximumValue != v) {
		m_maximumValue = v;
		updateValueAsRatio();
		Q_EMIT maximumValueChanged();
	}
}

void ValueRange::setValue(qreal v)
{
	if (m_value != v) {
		m_value = v;
		updateValueAsRatio();
		Q_EMIT valueChanged();
	}
}

void ValueRange::updateValueAsRatio()
{
	// Scale the value from the min-max range to a [0.0 - 1.0] range.
	const qreal v = (qIsNaN(m_value) || qIsNaN(m_minimumValue) || qIsNaN(m_maximumValue))
		? 0.0
		: FastUtils::scale(m_value, m_minimumValue, m_maximumValue, 0, 1);

	if (m_valueAsRatio != v) {
		m_valueAsRatio = v;
		Q_EMIT valueAsRatioChanged();
	}
}

}
}
