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
            const QStringList fileList = baselineDir.entryList(QStringList() << "*.*", QDir::Files);
            allFiles.append(fileList);
        } else {
            qDebug() << "Baseline directory not exist/is empty/not accessible";
        }

        // Scan candidate directory
        QDir candidateDir("image-captures");
        if (candidateDir.exists() && !candidateDir.isEmpty() && candidateDir.isReadable()) {
            const QStringList fileList = candidateDir.entryList(QStringList() << "*.*", QDir::Files);
            for (const QString &file : fileList) {
                if (!allFiles.contains(file)) {
                    allFiles.append(file);
                }
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
    ComparisonWorker(CompareModel *model, const QString &fileName, const CompareModel::ImageResult &preValidated)
        : m_model(model), m_fileName(fileName), m_preValidated(preValidated)
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

    CompareModel::ImageResult compare(const QString fileName) const
    {
        CompareModel::ImageResult result;
        result.fileName = fileName;

        // Check if we have pre-validated this image
        if (m_preValidated.fileName == fileName) {
            // If validation failed, return error result
            if (!m_preValidated.baselineExists || !m_preValidated.candidateExists || !m_preValidated.sizesMatch) {
                result.similarity = 0.0;
                result.meanError = 255.0;
                result.valid = false;
                result.identical = false;
                result.pending = false;
                return result;
            }
        }

        QString baselinePath = "image-captures-baseline/" + fileName;
        QString candidatePath = "image-captures/" + fileName;

        // Load images for comparison
        QImage a(baselinePath);
        QImage b(candidatePath);

        // Double-check images loaded successfully (in case validation was skipped)
        if (a.isNull() || b.isNull() || a.size() != b.size()) {
            result.valid = false;
            result.identical = false;
            result.pending = false;
            result.similarity = 0.0;
            result.meanError = 255.0;

            if (a.isNull() && !b.isNull()) {
                result.errorMessage = "Baseline image missing";
                result.baselineExists = false;
                result.candidateExists = true;
            } else if (!a.isNull() && b.isNull()) {
                result.errorMessage = "Candidate image missing";
                result.baselineExists = true;
                result.candidateExists = false;
            } else if (a.isNull() && b.isNull()) {
                result.errorMessage = "Both images missing";
                result.baselineExists = false;
                result.candidateExists = false;
            } else if (a.size() != b.size()) {
                result.errorMessage = QString("Size mismatch: %1x%2 vs %3x%4")
                                         .arg(a.width()).arg(a.height())
                                         .arg(b.width()).arg(b.height());
                result.baselineExists = true;
                result.candidateExists = true;
                result.sizesMatch = false;
                result.baselineSize = a.size();
                result.candidateSize = b.size();
            }
            return result;
        }

        const int width = a.width();
        const int height = a.height();

        quint64 totalDiff = 0;
        for (int y = 0; y < height; ++y) {
            for (int x = 0; x < width; ++x) {
                const QRgb rgb1 = a.pixel(x, y);
                const QRgb rgb2 = b.pixel(x, y);
                totalDiff += qAbs(qRed(rgb1) - qRed(rgb2))
                             + qAbs(qGreen(rgb1) - qGreen(rgb2))
                             + qAbs(qBlue(rgb1) - qBlue(rgb2))
                             + qAbs(qAlpha(rgb1) - qAlpha(rgb2));
            }
        }
        const double meanError = totalDiff / (width * height * 4.0);
        const double similarity = 1.0 - (meanError / 255.0);

        result.similarity = similarity;
        result.meanError = meanError;
        result.valid = true;
        result.identical = (totalDiff == 0);
        result.pending = false;
        result.errorMessage = QString();
        result.baselineExists = true;
        result.candidateExists = true;
        result.sizesMatch = true;
        result.baselineSize = a.size();
        result.candidateSize = b.size();

        return result;
    }

private:
    CompareModel::ImageResult m_preValidated;
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

    // Don't automatically run discovery/validation/comparison
    // Let the UI trigger it when ready
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
        { TitleRole, "title" },
        { TextRole, "text" },
        { SimilarityRole, "similarity" },
        { MeanErrorRole, "error" },
        { IdenticalRole, "identical"},
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

    switch(role) {
    case TitleRole:
        return m_data.at(row);
    case TextRole:
        return m_data.at(row);
    case SimilarityRole: {
        return getResultData(m_data.at(row)).similarity;
    }
    case MeanErrorRole: {
        return getResultData(m_data.at(row)).meanError;
    }
    case IdenticalRole: {
        return getResultData(m_data.at(row)).identical;
    }
    case ErrorMessageRole: {
        return getResultData(m_data.at(row)).errorMessage;
    }
    }
    return QVariant();
}

bool CompareModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (index.isValid()) {
        int row = index.row();
        if(row < 0 || row >= m_data.count()) {
            return false;
        }

        switch(role) {
        case TitleRole:
            m_data[row] = value.toString();
            break;
        case TextRole:
            m_data[row] = value.toString();
            break;
        default:
            return false;
        }

        emit dataChanged(index, index, {role});

        return true;
    }
    return false;
}

void CompareModel::discoverImages()
{
    qDebug() << "Starting async image discovery...";
    
    // Queue the discovery task
    DiscoveryWorker *worker = new DiscoveryWorker(this);
    m_threadPool->start(worker);
}

void CompareModel::validateImages()
{
    qDebug() << "Starting image validation...";
    int validCount = 0;
    int missingBaseline = 0;
    int missingCandidate = 0;
    int sizeMismatch = 0;

    for (const QString &fileName : m_allData) {
        validateImage(fileName);
        const ImageResult &result = m_results.value(fileName);

        if (!result.baselineExists) {
            missingBaseline++;
        }
        if (!result.candidateExists) {
            missingCandidate++;
        }
        if (result.baselineExists && result.candidateExists && !result.sizesMatch) {
            sizeMismatch++;
        }
        if (result.baselineExists && result.candidateExists && result.sizesMatch) {
            validCount++;
        }
    }

    qDebug() << "Image validation complete:"
             << validCount << "valid pairs,"
             << missingBaseline << "missing baseline,"
             << missingCandidate << "missing candidate,"
             << sizeMismatch << "size mismatches";
}

void CompareModel::startComparisons()
{
    qDebug() << "Starting image comparisons...";
    int skipped = 0;
    int started = 0;

    // Start async comparisons for all files that passed validation
    for (const QString &fileName : m_allData) {
        // Check if we have validation results
        if (m_results.contains(fileName)) {
            const ImageResult &result = m_results.value(fileName);

            // Only compare if both images exist and sizes match
            if (result.baselineExists && result.candidateExists && result.sizesMatch) {
                startAsyncComparison(fileName);
                started++;
            } else {
                // Validation error already stored in result
                skipped++;
            }
        } else {
            // No validation result, start comparison anyway (will validate inside compare())
            startAsyncComparison(fileName);
            started++;
        }
    }

    qDebug() << "Comparison started for" << started << "images, skipped" << skipped << "invalid images";
}

void CompareModel::refresh()
{
    discoverImages();
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

    validateImages();
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

    ImageResult result = getResultData(fileName);

    // Filter modes 3 and 4 need to check error messages even if result is invalid
    if (m_filterMode == 3) {
        // Missing Baseline - show images where baseline is missing
        return result.errorMessage == "Baseline image missing";
    } else if (m_filterMode == 4) {
        // Missing Candidate - show images where candidate is missing
        return result.errorMessage == "Candidate image missing";
    }

    if (!result.valid) {
        return false;
    }

    // Use meanError for more precise comparison (0.255 corresponds to 99.9% similarity)
    const double errorThreshold = 0.255;

    if (m_filterMode == 1) {
        return result.meanError <= errorThreshold;  // Pass only
    } else if (m_filterMode == 2) {
        return result.meanError > errorThreshold;  // Fail only
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

int CompareModel::count()
{
    return m_data.count();
}

int CompareModel::exactMatchCount()
{
    int exact = 0;
    for (const QString &fileName : m_allData) {
        if (getResultData(fileName).identical) {
            exact++;
        }
    }
    return exact;
}

int CompareModel::passCount()
{
    int pass = 0;
    const double errorThreshold = 0.255;  // Corresponds to 99.9% similarity
    for (const QString &fileName : m_allData) {
        ImageResult result = getResultData(fileName);
        if (result.valid && result.meanError <= errorThreshold) {
            pass++;
        }
    }
    return pass;
}

int CompareModel::failedCount()
{
    int fail = 0;
    const double errorThreshold = 0.255;  // Corresponds to 99.9% similarity
    for (const QString &fileName : m_allData) {
        ImageResult result = getResultData(fileName);
        if (result.valid && result.meanError > errorThreshold) {
            fail++;
        }
    }
    return fail;
}

int CompareModel::missingBaselineCount()
{
    int missing = 0;
    for (const QString &fileName : m_allData) {
        ImageResult result = getResultData(fileName);
        if (result.errorMessage == "Baseline image missing") {
            missing++;
        }
    }
    return missing;
}

int CompareModel::missingCandidateCount()
{
    int missing = 0;
    for (const QString &fileName : m_allData) {
        ImageResult result = getResultData(fileName);
        if (result.errorMessage == "Candidate image missing") {
            missing++;
        }
    }
    return missing;
}

void CompareModel::validateImage(const QString &fileName)
{
    QString baselinePath = "image-captures-baseline/" + fileName;
    QString candidatePath = "image-captures/" + fileName;

    ImageResult result;
    result.fileName = fileName;
    result.baselineExists = QFile::exists(baselinePath);
    result.candidateExists = QFile::exists(candidatePath);
    result.sizesMatch = false;

    if (!result.baselineExists && result.candidateExists) {
        result.errorMessage = "Baseline image missing";
        m_results.insert(fileName, result);
        return;
    }

    if (result.baselineExists && !result.candidateExists) {
        result.errorMessage = "Candidate image missing";
        m_results.insert(fileName, result);
        return;
    }

    if (!result.baselineExists && !result.candidateExists) {
        result.errorMessage = "Both images missing";
        m_results.insert(fileName, result);
        return;
    }

    // Both exist, check sizes
    QImage baselineImg(baselinePath);
    QImage candidateImg(candidatePath);

    result.baselineSize = baselineImg.size();
    result.candidateSize = candidateImg.size();

    if (baselineImg.size() != candidateImg.size()) {
        result.errorMessage = QString("Size mismatch: %1x%2 vs %3x%4")
                                  .arg(baselineImg.width()).arg(baselineImg.height())
                                  .arg(candidateImg.width()).arg(candidateImg.height());
        result.sizesMatch = false;
        m_results.insert(fileName, result);
        return;
    }

    result.sizesMatch = true;
    result.errorMessage = QString();
    m_results.insert(fileName, result);
}

CompareModel::ImageResult CompareModel::getResultData(const QString fileName) const
{
    if (!m_results.contains(fileName)) {
        // Return a pending result - comparison is in progress or queued
        ImageResult result;
        result.pending = true;
        result.errorMessage = "Comparing...";
        return result;
    }
    return m_results.value(fileName);
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
    emit passCountChanged();
    emit failedCountChanged();
    emit exactMatchCountChanged();
    emit missingBaselineCountChanged();
    emit missingCandidateCountChanged();
}

void CompareModel::startAsyncComparison(const QString &fileName)
{
    // Mark as pending (preserve existing validation data if present)
    ImageResult pendingResult;
    pendingResult.fileName = fileName;
    if (m_results.contains(fileName)) {
        pendingResult = m_results.value(fileName);
    }
    pendingResult.pending = true;
    pendingResult.errorMessage = "Pending...";
    m_results.insert(fileName, pendingResult);

    // Queue the comparison task
    ComparisonWorker *worker = new ComparisonWorker(this, fileName, m_results.value(fileName));
    m_threadPool->start(worker);
}
