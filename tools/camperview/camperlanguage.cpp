/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "camperlanguage.h"

#include <QCoreApplication>
#include <QQmlEngine>
#include <QTranslator>

namespace {

// Whether the illustration's only font, Roboto, has the letters of the language. In WebAssembly
// there are no system fonts to fall back on, so other scripts would show as empty boxes.
bool canRender(QLocale::Language language)
{
#if defined(VENUS_WEBASSEMBLY_BUILD)
	switch (QLocale(language).script()) {
	case QLocale::LatinScript:
	case QLocale::CyrillicScript:
	case QLocale::GreekScript:
		return true;
	default:
		return false;
	}
#else
	Q_UNUSED(language);
	return true;
#endif
}

}

namespace Victron {
namespace VenusOS {

CamperLanguage::CamperLanguage(QQmlEngine *engine, QObject *parent)
	: QObject(parent)
	, m_engine(engine)
{
	if (QTranslator *english = loadTranslator(QLocale::English)) {
		QCoreApplication::installTranslator(english);
	}
}

QString CamperLanguage::code() const
{
	return m_code;
}

void CamperLanguage::setCode(const QString &code)
{
	if (m_code == code) {
		return;
	}
	m_code = code;
	emit codeChanged();

	if (m_translator) {
		QCoreApplication::removeTranslator(m_translator);
		delete m_translator;
		m_translator = nullptr;
	}

	// An unknown or empty code, English, or a script the font lacks, all leave English.
	const QLocale::Language language = QLocale::codeToLanguage(code);
	if (language != QLocale::AnyLanguage && language != QLocale::English) {
		if (!canRender(language)) {
			qInfo().noquote() << "Showing English, as the font cannot show language" << code;
		} else if ((m_translator = loadTranslator(language))) {
			QCoreApplication::installTranslator(m_translator);
		} else {
			qWarning().noquote() << "No translations for language" << code;
		}
	}
	m_engine->retranslate();
}

QTranslator *CamperLanguage::loadTranslator(QLocale::Language language)
{
	QTranslator *translator = new QTranslator(this);
	if (translator->load(QLocale(language), QStringLiteral("camperview"), QStringLiteral("_"), QStringLiteral(":/i18n"))) {
		return translator;
	}
	delete translator;
	return nullptr;
}

}
}
