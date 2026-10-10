/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_NATIVEQUANTITYLABEL_H
#define VICTRON_GUIV2_NATIVEQUANTITYLABEL_H

#include <QQuickItem>
#include <QtQuick/private/qquickpositioners_p.h>
#include <QtQuickTemplates2/private/qquicklabel_p.h>

/*
	QuantityLabel's Row and two Labels, constructed in C++ rather than declared in QML.

	This is not a cheaper widget. The same Qt types are still created, and
	QuantityLabel.qml still evaluates its theme, font, and QuantityInfo bindings.

	The cost that goes away is the QML engine's work to instantiate everything
	written in the QML file. For each nested object it creates the object, then
	installs a live binding for every expression on it (the five-way anchors, font
	size/weight/family, baseline alignment, implicit size, aliases into the
	children, and so on). Declaring the Row and Labels in QML paid that for three
	extra objects. Here they are created with new, and that inner wiring is
	ordinary C++ setters and signal connections.

	The QML-facing API and geometry must match the old Item/Row/Label tree.
*/
class NativeQuantityLabel : public QQuickItem
{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(QQuickRow *_digitRow READ digitRow CONSTANT FINAL)
	Q_PROPERTY(QQuickLabel *_valueLabel READ valueLabel CONSTANT FINAL)
	Q_PROPERTY(QQuickLabel *_unitLabel READ unitLabel CONSTANT FINAL)
	Q_PROPERTY(QFont font READ font WRITE setFont NOTIFY fontChanged FINAL)
	Q_PROPERTY(QString valueText READ valueText WRITE setValueText NOTIFY valueTextChanged FINAL)
	Q_PROPERTY(QString unitText READ unitText WRITE setUnitText NOTIFY unitTextChanged FINAL)
	Q_PROPERTY(QColor valueColor READ valueColor WRITE setValueColor NOTIFY valueColorChanged FINAL)
	Q_PROPERTY(QColor unitColor READ unitColor WRITE setUnitColor NOTIFY unitColorChanged FINAL)
	Q_PROPERTY(qreal leftPadding READ leftPadding WRITE setLeftPadding RESET resetLeftPadding
			NOTIFY leftPaddingChanged FINAL)
	Q_PROPERTY(qreal rightPadding READ rightPadding WRITE setRightPadding RESET resetRightPadding
			NOTIFY rightPaddingChanged FINAL)
	Q_PROPERTY(int alignment MEMBER m_alignment NOTIFY alignmentChanged FINAL)
	Q_PROPERTY(QString valueFontFamily MEMBER m_valueFontFamily NOTIFY valueFontFamilyChanged FINAL)
	Q_PROPERTY(int baselineRoundingPixelSize MEMBER m_baselineRoundingPixelSize
			NOTIFY baselineRoundingPixelSizeChanged FINAL)

public:
	explicit NativeQuantityLabel(QQuickItem *parent = nullptr);

	QQuickRow *digitRow() const { return m_row; }
	QQuickLabel *valueLabel() const { return m_valueLabel; }
	QQuickLabel *unitLabel() const { return m_unitLabel; }
	QFont font() const { return m_unitLabel->font(); }
	void setFont(const QFont &font) { m_unitLabel->setFont(font); }
	QString valueText() const { return m_valueLabel->text(); }
	void setValueText(const QString &text) { m_valueLabel->setText(text); }
	QString unitText() const { return m_unitLabel->text(); }
	void setUnitText(const QString &text) { m_unitLabel->setText(text); }
	QColor valueColor() const { return m_valueLabel->color(); }
	void setValueColor(const QColor &color) { m_valueLabel->setColor(color); }
	QColor unitColor() const { return m_unitLabel->color(); }
	void setUnitColor(const QColor &color) { m_unitLabel->setColor(color); }
	qreal leftPadding() const { return m_row->leftPadding(); }
	void setLeftPadding(qreal padding) { m_row->setLeftPadding(padding); }
	void resetLeftPadding() { m_row->resetLeftPadding(); }
	qreal rightPadding() const { return m_row->rightPadding(); }
	void setRightPadding(qreal padding) { m_row->setRightPadding(padding); }
	void resetRightPadding() { m_row->resetRightPadding(); }

Q_SIGNALS:
	void alignmentChanged();
	void fontChanged();
	void valueTextChanged();
	void unitTextChanged();
	void valueColorChanged();
	void unitColorChanged();
	void leftPaddingChanged();
	void rightPaddingChanged();
	void valueFontFamilyChanged();
	void baselineRoundingPixelSizeChanged();

protected:
	void componentComplete() override;

private:
	void updateAlignment();
	void updateValueFont();

	QQuickRow *m_row;
	QQuickLabel *m_valueLabel;
	QQuickLabel *m_unitLabel;
	int m_alignment = Qt::AlignHCenter | Qt::AlignVCenter;
	QString m_valueFontFamily;
	int m_baselineRoundingPixelSize = 0;
};

#endif
