#include "comparemodel.h"

#include <QImage>
#include <QRunnable>
#include <QPointer>
#include <QCoreApplication>
#include <QFile>
#include <QDir>

class DiscoveryWorker : public QRunnable
{
public:
    DiscoveryWorker(CompareModel *model)
        : m_model(model)
    {
        setAutoDelete(true);
    }

    void run() override
    {
        QStringList allFiles;
        
        // Scan baseline directory
        QDir baselineDir("image-captures-baseline");
        if (baselineDir.exists() && !baselineDir.isEmpty() && baselineDir.isReadable()) {
            allFiles = baselineDir.entryList(QStringList() << "*.*", QDir::Files, QDir::Name);
        } else {
            qDebug() << "Baseline directory not exist/is empty/not accessible";
        }

        // Scan candidate directory
        QDir candidateDir("image-captures");
        if (candidateDir.exists() && !candidateDir.isEmpty() && candidateDir.isReadable()) {
            const QStringList candidateFiles = candidateDir.entryList(QStringList() << "*.*", QDir::Files, QDir::Name);
            if (candidateFiles != allFiles) {
                // Add the candidate files into allFiles and sort the result.
                QSet allFilesSet(allFiles.constBegin(), allFiles.constEnd());
                allFilesSet.unite(QSet(candidateFiles.constBegin(), candidateFiles.constEnd()));
                allFiles = QList<QString>(allFilesSet.constBegin(), allFilesSet.constEnd());
                allFiles.sort();
            }
        } else {
            qDebug() << "Candidate directory not exist/is empty/not accessible";
        }

        // Send results back to UI thread
        QPointer<CompareModel> modelPtr(m_model);
        QMetaObject::invokeMethod(qApp, [modelPtr, allFiles]() {
            if (modelPtr) {
                modelPtr->onDiscoveryComplete(allFiles);
            }
        }, Qt::QueuedConnection);
    }

private:
    QPointer<CompareModel> m_model;
};

class ComparisonWorker : public QRunnable
{
public:
    ComparisonWorker(CompareModel *model, const QString &fileName)
        : m_model(model), m_fileName(fileName)
    {
        setAutoDelete(true);
    }

    void run() override
    {
        auto result = compare(m_fileName);

        QPointer<CompareModel> modelPtr(m_model);
        QMetaObject::invokeMethod(qApp, [modelPtr, fileName = m_fileName, result]() {
            if (modelPtr) {
                modelPtr->onComparisonComplete(fileName, result);
            }
        }, Qt::QueuedConnection);
    }

    int squaredDifference(const QRgb &rgb1, const QRgb &rgb2) const
    {
        const int aDiff = qAlpha(rgb1) - qAlpha(rgb2);
        const int rDiff = qRed(rgb1) - qRed(rgb2);
        const int gDiff = qGreen(rgb1) - qGreen(rgb2);
        const int bDiff = qBlue(rgb1) - qBlue(rgb2);
        return (aDiff * aDiff) + (rDiff * rDiff) + (gDiff * gDiff) + (bDiff * bDiff);
    }

    CompareModel::ImageResult compare(const QString fileName) const
    {
        const QString baselinePath = "image-captures-baseline/" + fileName;
        const QString candidatePath = "image-captures/" + fileName;

        // Load images for comparison
        QImage a(baselinePath);
        QImage b(candidatePath);
        if (a.format() != QImage::Format_ARGB32) {
            a = a.convertToFormat(QImage::Format_ARGB32);
        }
        if (b.format() != QImage::Format_ARGB32) {
            b = b.convertToFormat(QImage::Format_ARGB32);
        }

        CompareModel::ImageResult result;

        if (a.isNull() || b.isNull() || a.size() != b.size()) {
            if (a.isNull() && !b.isNull()) {
                result.status = CompareModel::NoBaselineImage;
                result.errorMessage = "Baseline image missing";
            } else if (!a.isNull() && b.isNull()) {
                result.status = CompareModel::NoCandidateImage;
                result.errorMessage = "Candidate image missing";
            } else if (a.isNull() && !b.isNull()) {
                result.status = CompareModel::ComparisonReady;
                result.errorMessage = "Both images missing";
            } else {
                result.status = CompareModel::ComparisonReady;
                result.errorMessage = QString("Size mismatch: %1x%2 vs %3x%4")
                                         .arg(a.width()).arg(a.height())
                                         .arg(b.width()).arg(b.height());
            }
            return result;
        }

        const int width = a.width();
        const int height = a.height();
        quint64 totalDiff = 0;

        for (int y = 0; y < height; ++y) {
            const uchar *scanLineA = a.constScanLine(y);
            const uchar *scanLineB = b.constScanLine(y);
            const QRgb *pixelA = reinterpret_cast<const QRgb*>(scanLineA);
            const QRgb *pixelB = reinterpret_cast<const QRgb*>(scanLineB);

            for (int x = 0; x < width; ++x) {
                const QRgb &rgb1 = pixelA[x];
                const QRgb &rgb2 = pixelB[x];
                totalDiff += squaredDifference(rgb1, rgb2);
            }
        }

        // Mean squared error = total difference / (image size * number of channels)
        result.mse = static_cast<double>(totalDiff) / (width * height * 4);
        result.status = CompareModel::ComparisonReady;
        return result;
    }

private:
    QPointer<CompareModel> m_model;
    QString m_fileName;
};


CompareModel::CompareModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_threadPool(new QThreadPool(this))
{
    // Register the custom type for use in queued connections
    qRegisterMetaType<CompareModel::ImageResult>("CompareModel::ImageResult");

    // Limit threads to avoid overwhelming the system
    m_threadPool->setMaxThreadCount(qMax(2, QThread::idealThreadCount() / 2));
}

CompareModel::~CompareModel()
{
    // Cancel all pending tasks and wait for active ones to complete
    if (m_threadPool) {
        m_threadPool->clear();  // Remove queued tasks
        m_threadPool->waitForDone(5000);  // Wait up to 5 seconds for active tasks
    }
}

QHash<int, QByteArray> CompareModel::roleNames() const
{
    static QHash<int, QByteArray> roles {
        { FileNameRole, "fileName" },
        { StatusRole, "status"},
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
    case StatusRole: {
        return result == m_results.constEnd() ? ComparisonPending : result->status;
    }
    case MeanSquaredErrorRole: {
        return result == m_results.constEnd() ? ImageResult::DefaultMse : result->mse;
    }
    case ErrorMessageRole: {
        return result == m_results.constEnd() ? QString() : result->errorMessage;
    }
    }
    return QVariant();
}

void CompareModel::discoverImages()
{
    qDebug() << "Starting async image discovery...";
    
    // Queue the discovery task
    DiscoveryWorker *worker = new DiscoveryWorker(this);
    m_threadPool->start(worker);
}

void CompareModel::startComparisons()
{
    const qreal requiredSimilarity = 1 - (m_errorTolerance / (255 * 255 * 4));
    qDebug() << qPrintable(QStringLiteral("Starting image comparisons with MSE errorTolerance=%1. Image comparison passes when image similarity is least %2%.")
                .arg(m_errorTolerance)
                .arg(QString::number(requiredSimilarity * 100, 'f', 3)));

    m_comparisonTimer.start();

    for (const QString &fileName : m_allData) {
        // Queue the comparison task
        ComparisonWorker *worker = new ComparisonWorker(this, fileName);
        m_threadPool->start(worker);
    }
}

void CompareModel::refresh()
{
    discoverImages();
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
    map.insert(QStringLiteral("mse"), result->mse);
    map.insert(QStringLiteral("errorMessage"), result->errorMessage);
    return map;
}

void CompareModel::onDiscoveryComplete(const QStringList &fileNames)
{
    qDebug() << "Image discovery complete. Found" << fileNames.count() << "images";
    
    beginResetModel();
    m_allData.clear();
    m_data.clear();
    m_results.clear();
    
    m_allData = fileNames;
    applyFilter();
    
    endResetModel();
    emit countChanged();

    startComparisons();
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

    // Filter modes 3 and 4 need to check error messages even if result is invalid
    if (m_filterMode == 3) {
        // Missing Baseline - show images where baseline is missing
        return result->status == NoBaselineImage;
    } else if (m_filterMode == 4) {
        // Missing Candidate - show images where candidate is missing
        return result->status == NoCandidateImage;
    }

    if (result->status != ComparisonReady) {
        return false;
    }

    if (m_filterMode == 1) {
        return result->mse <= m_errorTolerance;  // Pass only
    } else if (m_filterMode == 2) {
        return result->mse > m_errorTolerance;  // Fail only
    }

    return true;
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
    if (m_data.count() > 0) {
        qWarning() << "Error: cannot change error tolerance after model is populated!";
        return;
    }
    if (errorTolerance != m_errorTolerance) {
        m_errorTolerance = errorTolerance;
        emit errorToleranceChanged();
    }
}

int CompareModel::count() const
{
    return m_data.count();
}

void CompareModel::onComparisonComplete(const QString &fileName, const ImageResult &result)
{
    // Store the result
    m_results.insert(fileName, result);

    // Find the row index
    int row = m_data.indexOf(fileName);
    if (row >= 0) {
        // Emit dataChanged for this row
        QModelIndex idx = index(row);
        emit dataChanged(idx, idx);
    }

    // Update counts
    switch (result.status) {
    case ComparisonPending:
        break;
    case ComparisonReady:
        if (result.mse > m_errorTolerance) {
            m_failedCount++;
            emit failedCountChanged();
        } else {
            m_passCount++;
            emit passCountChanged();
        }
        break;
    case NoBaselineImage:
        m_missingBaselineCount++;
        emit missingBaselineCountChanged();
        break;
    case NoCandidateImage:
        m_missingCandidateCount++;
        emit missingCandidateCountChanged();
        break;
    }

    if (row == 0) {
        emit firstResultAvailable();
    }
    if (m_results.count() == m_allData.count()) {
        qDebug() << "Image comparisons completed in" << m_comparisonTimer.elapsed() << "ms";
    }
}
