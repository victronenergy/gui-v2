#include "keynavigationhighlighthelper.h"

KeyNavigationHighlightHelper::KeyNavigationHighlightHelper(QObject *parent) :
	QObject{parent}
{

}

QQuickItem *KeyNavigationHighlightHelper::activeFocusItem() const
{
	return m_activeFocusItem;
}

void KeyNavigationHighlightHelper::setActiveFocusItem(QQuickItem *activeFocusItem)
{
	if (m_activeFocusItem == activeFocusItem) {
		return;
	}

	m_activeFocusItem = activeFocusItem;
	emit activeFocusItemChanged();

	// disconnect from the previous attached object's signals (if there was one)
	if(m_attached) {
		disconnect(m_attached, &KeyNavigationHighlight::activeChanged, this, &KeyNavigationHighlightHelper::updateActive);
		disconnect(m_attached, &KeyNavigationHighlight::fillChanged, this, &KeyNavigationHighlightHelper::updateFill);
		disconnect(m_attached, &KeyNavigationHighlight::marginsChanged, this, &KeyNavigationHighlightHelper::updateMargins);
		disconnect(m_attached, &KeyNavigationHighlight::leftMarginChanged, this, &KeyNavigationHighlightHelper::updateLeftMargin);
		disconnect(m_attached, &KeyNavigationHighlight::rightMarginChanged, this, &KeyNavigationHighlightHelper::updateRightMargin);
		disconnect(m_attached, &KeyNavigationHighlight::topMarginChanged, this, &KeyNavigationHighlightHelper::updateTopMargin);
		disconnect(m_attached, &KeyNavigationHighlight::bottomMarginChanged, this, &KeyNavigationHighlightHelper::updateBottomMargin);
	}

	// find the new attached object (if there is one)
	m_attached = qobject_cast<KeyNavigationHighlight*>(qmlAttachedPropertiesObject<KeyNavigationHighlight>(activeFocusItem, false));

	// find a new one and connect to its signals
	if(m_attached) {
		connect(m_attached, &KeyNavigationHighlight::activeChanged, this, &KeyNavigationHighlightHelper::updateActive);
		connect(m_attached, &KeyNavigationHighlight::fillChanged, this, &KeyNavigationHighlightHelper::updateFill);
		connect(m_attached, &KeyNavigationHighlight::marginsChanged, this, &KeyNavigationHighlightHelper::updateMargins);
		connect(m_attached, &KeyNavigationHighlight::leftMarginChanged, this, &KeyNavigationHighlightHelper::updateLeftMargin);
		connect(m_attached, &KeyNavigationHighlight::rightMarginChanged, this, &KeyNavigationHighlightHelper::updateRightMargin);
		connect(m_attached, &KeyNavigationHighlight::topMarginChanged, this, &KeyNavigationHighlightHelper::updateTopMargin);
		connect(m_attached, &KeyNavigationHighlight::bottomMarginChanged, this, &KeyNavigationHighlightHelper::updateBottomMargin);
	}

	// call the updatedate functions immediately.
	updateActive();
	updateFill();
	updateMargins();
	updateLeftMargin();
	updateRightMargin();
	updateTopMargin();
	updateBottomMargin();
}

bool KeyNavigationHighlightHelper::active() const
{
	return m_active;
}

void KeyNavigationHighlightHelper::updateActive()
{
	bool active = m_attached ? m_attached->active() : false;

	if (m_active == active) {
		return;
	}
	m_active = active;
	emit activeChanged();
}

QQuickItem *KeyNavigationHighlightHelper::fill() const
{
	return m_fill;
}

void KeyNavigationHighlightHelper::updateFill()
{
	// we choose the fill if we can get one, else we use the activeFocusItem but only
	// if the activeFocusItem has an attached property.
	QQuickItem *fill = m_attached ? (m_attached->fill() ? m_attached->fill() : m_activeFocusItem) : nullptr;

	if (m_fill == fill) {
		return;
	}
	m_fill = fill;
	emit fillChanged();
}

qint32 KeyNavigationHighlightHelper::margins() const
{
	return m_margins;
}

void KeyNavigationHighlightHelper::updateMargins()
{
	qint32 margins = m_attached ? m_attached->margins() : 0;

	if (m_margins == margins) {
		return;
	}
	m_margins = margins;
	emit marginsChanged();
}

qint32 KeyNavigationHighlightHelper::leftMargin() const
{
	return m_leftMargin;
}

void KeyNavigationHighlightHelper::updateLeftMargin()
{
	qint32 leftMargin = m_attached ? m_attached->leftMargin() : 0;

	if (m_leftMargin == leftMargin) {
		return;
	}
	m_leftMargin = leftMargin;
	emit leftMarginChanged();
}

qint32 KeyNavigationHighlightHelper::rightMargin() const
{
	return m_rightMargin;
}

void KeyNavigationHighlightHelper::updateRightMargin()
{
	qint32 rightMargin = m_attached ? m_attached->rightMargin() : 0;

	if (m_rightMargin == rightMargin) {
		return;
	}
	m_rightMargin = rightMargin;
	emit rightMarginChanged();
}

qint32 KeyNavigationHighlightHelper::topMargin() const
{
	return m_topMargin;
}

void KeyNavigationHighlightHelper::updateTopMargin()
{
	qint32 topMargin = m_attached ? m_attached->topMargin() : 0;

	if (m_topMargin == topMargin) {
		return;
	}
	m_topMargin = topMargin;
	emit topMarginChanged();
}

qint32 KeyNavigationHighlightHelper::bottomMargin() const
{
	return m_bottomMargin;
}

void KeyNavigationHighlightHelper::updateBottomMargin()
{
	qint32 bottomMargin = m_attached ? m_attached->bottomMargin() : 0;

	if (m_bottomMargin == bottomMargin) {
		return;
	}
	m_bottomMargin = bottomMargin;
	emit bottomMarginChanged();
}

qint32 KeyNavigationHighlightHelper::verticalBorders() const
{
	return m_verticalBorders;
}

void KeyNavigationHighlightHelper::setVerticalBorders(qint32 verticalBorders)
{
	if (m_verticalBorders == verticalBorders) {
		return;
	}
	m_verticalBorders = verticalBorders;
	emit verticalBordersChanged();
}

qint32 KeyNavigationHighlightHelper::horizontalBorders() const
{
	return m_horizontalBorders;
}

void KeyNavigationHighlightHelper::setHorizontalBorders(qint32 horizontalBorders)
{
	if (m_horizontalBorders == horizontalBorders) {
		return;
	}
	m_horizontalBorders = horizontalBorders;
	emit horizontalBordersChanged();
}
