#include "keynavigationhighlight.h"

KeyNavigationHighlight::KeyNavigationHighlight(QObject *parent) :
	QObject{parent}
{

}

KeyNavigationHighlight *KeyNavigationHighlight::qmlAttachedProperties(QObject *object)
{
	return new KeyNavigationHighlight(object);
}

bool KeyNavigationHighlight::active() const
{
	return m_active;
}

void KeyNavigationHighlight::setActive(bool active)
{
	if (m_active == active) {
		return;
	}
	m_active = active;
	emit activeChanged();
}

QQuickItem *KeyNavigationHighlight::fill() const
{
	return m_fill;
}

void KeyNavigationHighlight::setFill(QQuickItem *fill)
{
	if (m_fill == fill)
		return;
	m_fill = fill;
	emit fillChanged();
}


int KeyNavigationHighlight::leftMargin() const
{
	return m_hasLeftMargin ? m_leftMargin : m_margins;
}

void KeyNavigationHighlight::setLeftMargin(int leftMargin)
{
	m_hasLeftMargin = true;

	if (m_leftMargin == leftMargin) {
		return;
	}
	m_leftMargin = leftMargin;
	emit leftMarginChanged();
}

void KeyNavigationHighlight::resetLeftMargin()
{
	m_hasLeftMargin = false;
	emit leftMarginChanged();
}

int KeyNavigationHighlight::rightMargin() const
{
	return m_hasRightMargin ? m_rightMargin : m_margins;
}

void KeyNavigationHighlight::setRightMargin(int rightMargin)
{
	m_hasRightMargin = true;

	if (m_rightMargin == rightMargin) {
		return;
	}
	m_rightMargin = rightMargin;
	emit rightMarginChanged();
}

void KeyNavigationHighlight::resetRightMargin()
{
	m_hasRightMargin = false;
	emit rightMarginChanged();
}

int KeyNavigationHighlight::topMargin() const
{
	return m_hasTopMargin ? m_topMargin : m_margins;
}

void KeyNavigationHighlight::setTopMargin(int topMargin)
{
	m_hasTopMargin = true;

	if (m_topMargin == topMargin) {
		return;
	}
	m_topMargin = topMargin;
	emit topMarginChanged();
}

void KeyNavigationHighlight::resetTopMargin()
{
	m_hasTopMargin = false;
	emit topMarginChanged();
}

int KeyNavigationHighlight::bottomMargin() const
{
	return m_hasBottomMargin ? m_bottomMargin : m_margins;
}

void KeyNavigationHighlight::setBottomMargin(int bottomMargin)
{
	m_hasBottomMargin = true;

	if (m_bottomMargin == bottomMargin) {
		return;
	}
	m_bottomMargin = bottomMargin;
	emit bottomMarginChanged();
}

void KeyNavigationHighlight::resetBottomMargin()
{
	m_hasBottomMargin = false;
	emit bottomMarginChanged();
}

int KeyNavigationHighlight::margins() const
{
	return m_margins;
}

void KeyNavigationHighlight::setMargins(int margins)
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
