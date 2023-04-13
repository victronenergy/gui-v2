#include "timezonemodel.h"

namespace {

// return a filtered subset of a given container.
template <typename Container, typename Predicate>
Container filtered_subset(const Container &container, Predicate predicate) {
	Container subset;
	std::copy_if(container.begin(), container.end(), std::back_inserter(subset), predicate);
	return subset;
}

}

namespace Victron {

namespace VenusOS {

TimezoneModel::TimezoneModel(QObject *parent)
	: QAbstractListModel(parent)
{
}

void TimezoneModel::classBegin()
{
	m_completed = false;
}

void TimezoneModel::componentComplete()
{
	m_completed = true;
	populateModel();
}

void TimezoneModel::populateModel()
{
	const int oldCount = m_timezones.count();
	const QDateTime currDt(QDateTime::currentDateTime());
	const QByteArray prefix = m_prefix.toUtf8();

	// Some iana ids are backlinks to other ids.
	// Since the displayName and comment/caption for these will be identical,
	// they would show up as duplicates in our UI, so filter them out.
	QVector<QPair<QString, QString> > alreadySeen;

	// Filter out entries which don't match our prefix.
	const QList<QByteArray> tzids = ::filtered_subset(
			QTimeZone::availableTimeZoneIds(),
			[prefix](const QByteArray &id) {
				return prefix.isEmpty() || id.startsWith(prefix);
			});

	// We want to sort them by UTC offset.
	QVector<QPair<int, QTimeZone> > offsetToTimezone;
	for (const QByteArray &tzid : tzids) {
		const QTimeZone tz(tzid);
		const QPair<QString, QString> displayNameComment(tz.displayName(currDt), tz.comment());
		if (!alreadySeen.contains(displayNameComment)) {
			alreadySeen.append(displayNameComment);
			offsetToTimezone.append(QPair<int, QTimeZone>(tz.offsetFromUtc(currDt), tz));
		}
	}

	std::sort(offsetToTimezone.begin(), offsetToTimezone.end(),
		[](const QPair<int, QTimeZone> &first, const QPair<int, QTimeZone> &second) {
			return first.first < second.first;
		});

	beginResetModel();
	m_timezones.clear();
	for (const QPair<int, QTimeZone> &tz : qAsConst(offsetToTimezone)) {
		m_timezones.append(tz.second);
	}
	endResetModel();

	if (m_timezones.count() != oldCount) {
		emit countChanged();
	}
}

QString TimezoneModel::prefix() const
{
	return m_prefix;
}

void TimezoneModel::setPrefix(const QString &prefix)
{
	if (m_prefix != prefix) {
		m_prefix = prefix;
		emit prefixChanged();
	}

	if (m_completed) {
		populateModel();
	}
}

QVariant TimezoneModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();
	if (row < 0 || row >= m_timezones.count()) {
		return QVariant();
	}

	const QTimeZone tz = m_timezones[row];
	const QString ianaId = QString::fromUtf8(tz.id());
	const QDateTime currDt(QDateTime::currentDateTime());
	//const QDateTime tzDateTime(currDt.date(), currDt.time(), tz);

	switch (role) {
	case TimezoneModel::DisplayNameRole:
		//return QVariant::fromValue<QString>(QStringLiteral("(%1) %2").arg(tzDateTime.timeZoneAbbreviation(), tz.displayName(currDt)));
		return QVariant::fromValue<QString>(QStringLiteral("(%1) %2").arg(tz.abbreviation(currDt), tz.displayName(currDt)));
	case TimezoneModel::CityRole:
		return QVariant::fromValue<QString>(ianaId.contains('/') ? ianaId.mid(ianaId.indexOf('/') + 1) : ianaId);
	case TimezoneModel::CaptionRole:
		return QVariant::fromValue<QString>(tz.comment());
	default:
		return QVariant();
	}
}

int TimezoneModel::rowCount(const QModelIndex &parent) const
{
	return m_timezones.count();
}

QHash<int, QByteArray> TimezoneModel::roleNames() const
{
	static QHash<int, QByteArray> roles {
		{ TimezoneModel::DisplayNameRole, "display" },
		{ TimezoneModel::CityRole, "city" },
		{ TimezoneModel::CaptionRole, "caption" }
	};

	return roles;
}

} // VenusOS

} // Victron

