/*
** Copyright (C) 2021 Victron Energy B.V.
*/

#ifndef LANGUAGE_H
#define LANGUAGE_H

#include <QLocale>
#include <QObject>
#include <QString>
#include <QHash>

class QTranslator;

class QQmlEngine;

namespace Victron {

namespace VenusOS {

class Language : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QLocale::Language current READ getCurrentLanguage WRITE setCurrentLanguage NOTIFY currentLanguageChanged FINAL)
public:
	explicit Language(QQmlEngine* engine);

	Q_ENUM(QLocale::Language)

	Q_INVOKABLE QString toString(QLocale::Language language) const;
	QLocale::Language getCurrentLanguage() const;
	void setCurrentLanguage(QLocale::Language language);

Q_SIGNALS:
	void currentLanguageChanged();

private:
	QLocale::Language m_currentLanguage = QLocale::English;
	QQmlEngine* m_qmlEngine = nullptr;
	QHash<QLocale::Language, QTranslator*> m_loadedTranslators;
};

} /* VenusOS */

} /* Victron */

#endif // LANGUAGE_H
