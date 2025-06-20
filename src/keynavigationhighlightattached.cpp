#include "keynavigationhighlightattached.h"

KeyNavigationHighlightAttached::KeyNavigationHighlightAttached(QObject *parent) :
	QObject{parent}
{

}

KeyNavigationHighlightAttached *KeyNavigationHighlightAttached::qmlAttachedProperties(QObject *object)
{
	return new KeyNavigationHighlightAttached(object);
}

bool KeyNavigationHighlightAttached::active() const
{
	return m_active;
}

void KeyNavigationHighlightAttached::setActive(bool active)
{
	if (m_active == active) {
		return;
	}
	m_active = active;
	emit activeChanged();
}

QQuickItem *KeyNavigationHighlightAttached::fill() const
{
	return m_fill;
}

void KeyNavigationHighlightAttached::setFill(QQuickItem *fill)
{
	if (m_fill == fill)
		return;
	m_fill = fill;
	emit fillChanged();
}


int KeyNavigationHighlightAttached::leftMargin() const
{
	return m_hasLeftMargin ? m_leftMargin : m_margins;
}

void KeyNavigationHighlightAttached::setLeftMargin(int leftMargin)
{
	m_hasLeftMargin = true;

	if (m_leftMargin == leftMargin) {
		return;
	}
	m_leftMargin = leftMargin;
	emit leftMarginChanged();
}

void KeyNavigationHighlightAttached::resetLeftMargin()
{
	m_hasLeftMargin = false;
	emit leftMarginChanged();
}

int KeyNavigationHighlightAttached::rightMargin() const
{
	return m_hasRightMargin ? m_rightMargin : m_margins;
}

void KeyNavigationHighlightAttached::setRightMargin(int rightMargin)
{
	m_hasRightMargin = true;

	if (m_rightMargin == rightMargin) {
		return;
	}
	m_rightMargin = rightMargin;
	emit rightMarginChanged();
}

void KeyNavigationHighlightAttached::resetRightMargin()
{
	m_hasRightMargin = false;
	emit rightMarginChanged();
}

int KeyNavigationHighlightAttached::topMargin() const
{
	return m_hasTopMargin ? m_topMargin : m_margins;
}

void KeyNavigationHighlightAttached::setTopMargin(int topMargin)
{
	m_hasTopMargin = true;

	if (m_topMargin == topMargin) {
		return;
	}
	m_topMargin = topMargin;
	emit topMarginChanged();
}

void KeyNavigationHighlightAttached::resetTopMargin()
{
	m_hasTopMargin = false;
	emit topMarginChanged();
}

int KeyNavigationHighlightAttached::bottomMargin() const
{
	return m_hasBottomMargin ? m_bottomMargin : m_margins;
}

void KeyNavigationHighlightAttached::setBottomMargin(int bottomMargin)
{
	m_hasBottomMargin = true;

	if (m_bottomMargin == bottomMargin) {
		return;
	}
	m_bottomMargin = bottomMargin;
	emit bottomMarginChanged();
}

void KeyNavigationHighlightAttached::resetBottomMargin()
{
	m_hasBottomMargin = false;
	emit bottomMarginChanged();
}

int KeyNavigationHighlightAttached::margins() const
{
	return m_margins;
}

void KeyNavigationHighlightAttached::setMargins(int margins)
{
	if (m_margins == margins) {
		return;
	}
	m_margins = margins;
	emit marginsChanged();

	if(!m_hasLeftMargin) {
		emit leftMarginChanged();
	}
	if(!m_hasRightMargin) {
		emit rightMarginChanged();
	}
	if(!m_hasTopMargin) {
		emit topMarginChanged();
	}
	if(!m_hasBottomMargin) {
		emit bottomMarginChanged();
	}
}
