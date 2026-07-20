#include "comparemodel.h"
#include "imagecomparator.h"

#include <cmath>

CompareModel::CompareModel(QObject *parent)
    : QAbstractListModel(parent)
{
    ImageComparator *comparator = ImageComparator::instance();
    connect(comparator, &ImageComparator::discoveryComplete,
            this, &CompareModel::onDiscoveryComplete);
    connect(comparator, &ImageComparator::comparisonComplete,
            this, &CompareModel::onComparisonComplete);
}

QHash<int, QByteArray> CompareModel::roleNames() const
{
    static QHash<int, QByteArray> roles {
        { FileNameRole, "fileName" },
        { StatusRole, "status"},
        { PassedRole, "passed"},
        { IdenticalRole, "identical"},
        { MeanSquaredErrorRole, "mse" },
        { ErrorMessageRole, "errorMessage"},
    };
    return roles;
}

int CompareModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_data.count();
}

QVariant CompareModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= m_data.count()) {
        return QVariant();
    }

    auto result = m_results.constFind(m_data.at(row));

    switch(role) {
    case FileNameRole:
        return m_data.at(row);
    case StatusRole:
        return result == m_results.constEnd() ? ResultPending : result->status;
    case PassedRole:
        return result == m_results.constEnd() ? false : resultPassed(*result);
    case IdenticalRole:
        return result == m_results.constEnd() ? false : resultIsIdentical(*result);
    case MeanSquaredErrorRole:
        return result == m_results.constEnd() ? ImageComparator::ComparisonResult::DefaultMse : result->mse;
    case ErrorMessageRole:
        return result == m_results.constEnd() ? QString() : result->errorMessage;
    }
    return QVariant();
}

QVariantMap CompareModel::get(int index) const
{
    QVariantMap map;
    if (index < 0 || index >= m_data.length()) {
        return map;
    }

    auto result = m_results.constFind(m_data.at(index));
    if (result == m_results.constEnd()) {
        return map;
    }

    map.insert(QStringLiteral("fileName"), m_data.at(index));
    map.insert(QStringLiteral("status"), result->status);
    map.insert(QStringLiteral("passed"), resultPassed(*result));
    map.insert(QStringLiteral("identical"), resultIsIdentical(*result));
    map.insert(QStringLiteral("mse"), result->mse);
    map.insert(QStringLiteral("errorMessage"), result->errorMessage);
    return map;
}

void CompareModel::onDiscoveryComplete(const QStringList &fileNames)
{
    beginResetModel();
    m_allData.clear();
    m_data.clear();
    m_results.clear();

    m_allData = fileNames;
    applyFilter();

    endResetModel();
    emit countChanged();
    emit totalCountChanged();
}

void CompareModel::applyFilter()
{
    m_data.clear();
    for (const QString &fileName : m_allData) {
        if (passesFilter(fileName)) {
            m_data.append(fileName);
        }
    }
}

bool CompareModel::passesFilter(const QString &fileName) const
{
    if (m_filterMode == 0) {
        return true;  // Show all
    }

    auto result = m_results.constFind(fileName);
    if (result == m_results.constEnd()) {
        return false;
    }

    if (m_filterMode == 3) {
        return result->status == NoBaselineImage;
    } else if (m_filterMode == 4) {
        return result->status == NoCandidateImage;
    }

    if (result->status != ResultReady) {
        return false;
    }

    if (m_filterMode == 1) {
        return result->mse <= m_errorTolerance;  // Pass only
    } else if (m_filterMode == 2) {
        return result->mse > m_errorTolerance;  // Fail only
    }

    return true;
}

void CompareModel::load()
{
    const qreal requiredSimilarity = 1 - (m_errorTolerance / (255 * 255 * 4));
    qDebug() << qPrintable(QStringLiteral("Starting image comparisons with MSE errorTolerance=%1. Image comparison passes when image similarity is at least %2%.")
                .arg(m_errorTolerance)
                .arg(QString::number(requiredSimilarity * 100, 'f', 3)));
    ImageComparator::instance()->start();
}

void CompareModel::setFilterMode(int mode)
{
    if (m_filterMode != mode) {
        m_filterMode = mode;
        beginResetModel();
        applyFilter();
        endResetModel();
        emit filterModeChanged();
        emit countChanged();
    }
}

void CompareModel::setErrorTolerance(qreal errorTolerance)
{
    if (m_results.count() > 0) {
        qWarning() << "Error tolerance cannot be changed after comparator has started!";
        return;
    }

    if (errorTolerance != m_errorTolerance) {
        m_errorTolerance = errorTolerance;
        emit errorToleranceChanged();
    }
}

ImageComparator *CompareModel::comparator() const
{
    return ImageComparator::instance();
}

int CompareModel::count() const
{
    return m_data.count();
}

void CompareModel::onComparisonComplete(const QString &fileName, const ImageComparator::ComparisonResult &result)
{
    // Store the result
    m_results.insert(fileName, result);

    const int prevPassCount = m_passCount;
    const int prevFailCount = m_failCount;
    const int prevNoBaselineCount = m_noBaselineCount;
    const int prevNoCandidateCount = m_noCandidateCount;

    // Update counts
    switch (result.status) {
    case ImageComparator::ResultPending:
        break;
    case ImageComparator::ResultReady:
        if (result.mse <= m_errorTolerance) {
            m_passCount++;
        } else {
            m_failCount++;
        }
        break;
    case ImageComparator::NoBaselineImage:
        m_noBaselineCount++;
        break;
    case ImageComparator::NoCandidateImage:
        m_noCandidateCount++;
        break;
    }

    // Find the row index
    const int row = m_data.indexOf(fileName);
    if (row >= 0) {
        const QModelIndex idx = index(row);
        emit dataChanged(idx, idx);
    }

    if (prevPassCount != m_passCount) {
        emit passCountChanged();
    }
    if (prevFailCount != m_failCount) {
        emit failCountChanged();
    }
    if (prevNoBaselineCount != m_noBaselineCount) {
        emit noBaselineCountChanged();
    }
    if (prevNoCandidateCount != m_noCandidateCount) {
        emit noCandidateCountChanged();
    }

    if (row == 0) {
        emit firstResultAvailable();
    }
}

bool CompareModel::resultPassed(const ImageComparator::ComparisonResult &result) const
{
    return result.status == ResultReady && result.mse <= m_errorTolerance;
}

bool CompareModel::resultIsIdentical(const ImageComparator::ComparisonResult &result) const
{
    return result.status == ResultReady && result.mse <= m_errorTolerance && std::round(result.mse) == 0;
}
