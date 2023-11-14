/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef LANGUAGE_H
#define LANGUAGE_H

#include <QLocale>
#include <QObject>
#include <QString>
#include <QHash>
#include <QAbstractListModel>

class QTranslator;

class QQmlEngine;

namespace Victron {

namespace VenusOS {

class LanguageModel : public QAbstractListModel
{
	Q_OBJECT
	Q_PROPERTY(int currentLanguage READ currentLanguage WRITE setCurrentLanguage NOTIFY currentLanguageChanged)
	Q_PROPERTY(int currentIndex READ currentIndex NOTIFY currentIndexChanged)
	Q_PROPERTY(QString currentDisplayText READ currentDisplayText NOTIFY currentDisplayTextChanged)
	Q_PROPERTY(int count READ rowCount CONSTANT)

public:
	explicit LanguageModel(QObject *parent = nullptr);
	~LanguageModel() override;

	int currentLanguage() const;
	void setCurrentLanguage(int language);
	int currentIndex() const;
	QString currentDisplayText() const;

	Q_INVOKABLE int languageAt(int index) const;

	int rowCount(const QModelIndex &parent = QModelIndex()) const override;
	QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

signals:
	void currentLanguageChanged();
	void currentIndexChanged();
	void currentDisplayTextChanged();

private:
	struct LanguageData {
		QString name;
		QString code;
		QLocale::Language language;
	};
	QList<LanguageData> m_languages;
	int m_currentIndex = -1;
	QLocale::Language m_currentLanguage = QLocale::AnyLanguage;
};

class Language : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QLocale::Language current READ getCurrentLanguage WRITE setCurrentLanguage NOTIFY currentLanguageChanged FINAL)
public:
	explicit Language(QQmlEngine* engine);
	Language(const Victron::VenusOS::Language&) = delete;
	Language& operator=(const Victron::VenusOS::Language&) = delete;

	Q_ENUM(QLocale::Language)

	Q_INVOKABLE void retranslate(); // triggers world binding re-evaluation

	Q_INVOKABLE QString toString(QLocale::Language language) const;
	Q_INVOKABLE QString toCode(QLocale::Language language) const;
	Q_INVOKABLE void setCurrentLanguageCode(const QString &code);
	Q_INVOKABLE QLocale::Language fromCode(const QString &code);

	QLocale::Language getCurrentLanguage() const;
	void setCurrentLanguage(QLocale::Language language);

Q_SIGNALS:
	void currentLanguageChanged();

private:
	bool installTranslatorForLanguage(QLocale::Language language);
	QLocale::Language m_currentLanguage = QLocale::AnyLanguage;
	QQmlEngine* m_qmlEngine = nullptr;
	QHash<QLocale::Language, QTranslator*> m_loadedTranslators;
};

} /* VenusOS */

} /* Victron */

#endif // LANGUAGE_H
