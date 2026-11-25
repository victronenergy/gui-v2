/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_VENUSOS_GUI_V2_CAMPERLANGUAGE_H
#define VICTRON_VENUSOS_GUI_V2_CAMPERLANGUAGE_H

#include <QLocale>
#include <QObject>
#include <QString>
#include <qqmlintegration.h>

class QQmlEngine;
class QTranslator;

namespace Victron {
namespace VenusOS {

/*
	Shows the illustration in the device's language, from /Settings/Gui/Language.

	It loads the small camper catalogues (camperview_<locale>.qm), which hold only this app's ids,
	the same way gui-v2's Language loads venus-gui-v2_<locale>.qm. English is always installed
	underneath, as gui-v2 does, so that an untranslated id shows its English text.
*/
class CamperLanguage : public QObject
{
	Q_OBJECT
	QML_ELEMENT
	QML_UNCREATABLE("CamperLanguage is created by main.cpp")
	Q_PROPERTY(QString code READ code WRITE setCode NOTIFY codeChanged FINAL)

public:
	explicit CamperLanguage(QQmlEngine *engine, QObject *parent = nullptr);

	QString code() const;
	void setCode(const QString &code);

Q_SIGNALS:
	void codeChanged();

private:
	QTranslator *loadTranslator(QLocale::Language language);

	QQmlEngine *m_engine = nullptr;
	QTranslator *m_translator = nullptr;
	QString m_code;
};

}
}

#endif // VICTRON_VENUSOS_GUI_V2_CAMPERLANGUAGE_H
