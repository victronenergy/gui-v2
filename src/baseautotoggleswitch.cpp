#include "baseautotoggleswitch.h"

BaseAutoToggleSwitch::BaseAutoToggleSwitch(QQuickItem *parent)
	: QQuickControl(parent)
{
	setFlag(ItemIsFocusScope);
	setFocusPolicy(Qt::StrongFocus);
}

bool BaseAutoToggleSwitch::onChecked() const
{
	return m_onChecked;
}

void BaseAutoToggleSwitch::setOnChecked(bool checked)
{
	if (m_onChecked != checked) {
		m_onChecked = checked;
		Q_EMIT onCheckedChanged();
	}
}

bool BaseAutoToggleSwitch::autoChecked() const
{
	return m_autoChecked;
}

void BaseAutoToggleSwitch::setAutoChecked(bool checked)
{
	if (m_autoChecked != checked) {
		m_autoChecked = checked;
		Q_EMIT autoCheckedChanged();
	}
}

int BaseAutoToggleSwitch::buttonCount() const
{
	return 3;
}
