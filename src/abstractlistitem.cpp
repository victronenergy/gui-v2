#include "abstractlistitem.h"

AbstractListItem::AbstractListItem(QQuickItem *parent)
	: QQuickControl(parent)
{
	setFlag(ItemIsFocusScope);
}

bool AbstractListItem::preferredVisible() const
{
	return m_preferredVisible;
}

void AbstractListItem::setPreferredVisible(bool preferredVisible)
{
	if (m_preferredVisible != preferredVisible) {
		m_preferredVisible = preferredVisible;
		Q_EMIT preferredVisibleChanged();
	}
}

bool AbstractListItem::effectiveVisible() const
{
	return m_effectiveVisible;
}

void AbstractListItem::setEffectiveVisible(bool effectiveVisible)
{
	if (m_effectiveVisible != effectiveVisible) {
		m_effectiveVisible = effectiveVisible;
		Q_EMIT effectiveVisibleChanged();
	}
}
