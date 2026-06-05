#include "comparemodel.h"
#include <qimage.h>
#include <QPixmapCache>
#include <QRunnable>
#include <QPointer>
#include <QCoreApplication>
#include <QFile>

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
        QDir baseline("image-captures-baseline");
        if (baseline.exists() && !baseline.isEmpty() && baseline.isReadable()) {
            QStringList fileList = baseline.entryList(QStringList() << "*.*", QDir::Files);
            allFiles.append(fileList);
        } else {
            qDebug() << "Baseline directory not exist/is empty/not accessible";
        }

        // Scan current directory
        QDir current("image-captures");
        if (current.exists() && !current.isEmpty() && current.isReadable()) {
            QStringList fileList = current.entryList(QStringList() << "*.*", QDir::Files);
            for (const QString &file : fileList) {
                if (!allFiles.contains(file)) {
                    allFiles.append(file);
                }
            }
        } else {
            qDebug() << "Current directory not exist/is empty/not accessible";
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
    ComparisonWorker(CompareModel *model, const QString &filename)
        : m_model(model), m_filename(filename)
    {
        setAutoDelete(true);
    }

    void run() override
    {
        auto result = m_model->compare(m_filename);

        QPointer<CompareModel> modelPtr(m_model);
        QMetaObject::invokeMethod(qApp, [modelPtr, filename = m_filename, result]() {
            if (modelPtr) {
                modelPtr->onComparisonComplete(filename, result);
            }
        }, Qt::QueuedConnection);
    }

private:
    QPointer<CompareModel> m_model;
    QString m_filename;
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

int CompareModel::append(const QString file) {
    m_data.append(file);
    emit countChanged();
    return 1;
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
    int missingCurrent = 0;
    int sizeMismatch = 0;

    for (const QString &filename : m_allData) {
        validateImage(filename);
        const ImageResult &result = m_results.value(filename);

        if (!result.baselineExists) {
            missingBaseline++;
        }
        if (!result.currentExists) {
            missingCurrent++;
        }
        if (result.baselineExists && result.currentExists && !result.sizesMatch) {
            sizeMismatch++;
        }
        if (result.baselineExists && result.currentExists && result.sizesMatch) {
            validCount++;
        }
    }

    qDebug() << "Image validation complete:"
             << validCount << "valid pairs,"
             << missingBaseline << "missing baseline,"
             << missingCurrent << "missing current,"
             << sizeMismatch << "size mismatches";
}

void CompareModel::startComparisons()
{
    qDebug() << "Starting image comparisons...";
    int skipped = 0;
    int started = 0;

    // Start async comparisons for all files that passed validation
    for (const QString &filename : m_allData) {
        // Check if we have validation results
        if (m_results.contains(filename)) {
            const ImageResult &result = m_results.value(filename);

            // Only compare if both images exist and sizes match
            if (result.baselineExists && result.currentExists && result.sizesMatch) {
                startAsyncComparison(filename);
                started++;
            } else {
                // Validation error already stored in result
                skipped++;
            }
        } else {
            // No validation result, start comparison anyway (will validate inside compare())
            startAsyncComparison(filename);
            started++;
        }
    }

    qDebug() << "Comparison started for" << started << "images, skipped" << skipped << "invalid images";
}

void CompareModel::refresh()
{
    discoverImages();
    validateImages();
    startComparisons();
}

void CompareModel::onDiscoveryComplete(const QStringList &filenames)
{
    qDebug() << "Image discovery complete. Found" << filenames.count() << "images";
    
    beginResetModel();
    m_allData.clear();
    m_data.clear();
    m_results.clear();
    
    m_allData = filenames;
    applyFilter();
    
    endResetModel();
    emit countChanged();
}

void CompareModel::discoverImagesFromFileSystem()
{
    // This method is now deprecated in favor of async discovery
    // Kept for compatibility but redirects to async version
    qDebug() << "Warning: discoverImagesFromFileSystem() is deprecated. Use discoverImages() instead.";
    discoverImages();
}

void CompareModel::applyFilter()
{
    m_data.clear();
    for (const QString &filename : m_allData) {
        if (passesFilter(filename)) {
            m_data.append(filename);
        }
    }
}

bool CompareModel::passesFilter(const QString &filename) const
{
    if (m_filterMode == 0) {
        return true;  // Show all
    }

    ImageResult result = getResultData(filename);

    // Filter modes 3 and 4 need to check error messages even if result is invalid
    if (m_filterMode == 3) {
        // Missing Baseline - show images where baseline is missing
        return result.errorMessage == "Baseline image missing";
    } else if (m_filterMode == 4) {
        // Missing Current - show images where current is missing
        return result.errorMessage == "Current image missing";
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

int CompareModel::exactCount()
{
    int exact = 0;
    for (const QString &filename : m_allData) {
        if (getResultData(filename).identical) {
            exact++;
        }
    }
    return exact;
}

int CompareModel::passCount()
{
    int pass = 0;
    const double errorThreshold = 0.255;  // Corresponds to 99.9% similarity
    for (const QString &filename : m_allData) {
        ImageResult result = getResultData(filename);
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
    for (const QString &filename : m_allData) {
        ImageResult result = getResultData(filename);
        if (result.valid && result.meanError > errorThreshold) {
            fail++;
        }
    }
    return fail;
}

int CompareModel::missingBaselineCount()
{
    int missing = 0;
    for (const QString &filename : m_allData) {
        ImageResult result = getResultData(filename);
        if (result.errorMessage == "Baseline image missing") {
            missing++;
        }
    }
    return missing;
}

int CompareModel::missingCurrentCount()
{
    int missing = 0;
    for (const QString &filename : m_allData) {
        ImageResult result = getResultData(filename);
        if (result.errorMessage == "Current image missing") {
            missing++;
        }
    }
    return missing;
}

void CompareModel::validateImage(const QString &filename)
{
    QString baselinePath = "image-captures-baseline/" + filename;
    QString currentPath = "image-captures/" + filename;

    ImageResult result;
    result.baselineExists = QFile::exists(baselinePath);
    result.currentExists = QFile::exists(currentPath);
    result.sizesMatch = false;

    if (!result.baselineExists && result.currentExists) {
        result.errorMessage = "Baseline image missing";
        m_results.insert(filename, result);
        return;
    }

    if (result.baselineExists && !result.currentExists) {
        result.errorMessage = "Current image missing";
        m_results.insert(filename, result);
        return;
    }

    if (!result.baselineExists && !result.currentExists) {
        result.errorMessage = "Both images missing";
        m_results.insert(filename, result);
        return;
    }

    // Both exist, check sizes
    QImage baselineImg(baselinePath);
    QImage currentImg(currentPath);

    result.baselineSize = baselineImg.size();
    result.currentSize = currentImg.size();

    if (baselineImg.size() != currentImg.size()) {
        result.errorMessage = QString("Size mismatch: %1x%2 vs %3x%4")
                                  .arg(baselineImg.width()).arg(baselineImg.height())
                                  .arg(currentImg.width()).arg(currentImg.height());
        result.sizesMatch = false;
        m_results.insert(filename, result);
        return;
    }

    result.sizesMatch = true;
    result.errorMessage = QString();
    m_results.insert(filename, result);
}

CompareModel::ImageResult CompareModel::compare(const QString filename) const
{
    QString baselinePath = "image-captures-baseline/" + filename;
    QString currentPath = "image-captures/" + filename;

    ImageResult result;
    
    // Check if we have pre-validated this image
    if (m_results.contains(filename)) {
        result = m_results.value(filename);

        // If validation failed, return error result
        if (!result.baselineExists || !result.currentExists || !result.sizesMatch) {
            result.similarity = 0.0;
            result.meanError = 255.0;
            result.valid = false;
            result.identical = false;
            result.pending = false;
            return result;
        }
    }

    // Load images for comparison
    QImage a(baselinePath);
    QImage b(currentPath);

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
            result.currentExists = true;
        } else if (!a.isNull() && b.isNull()) {
            result.errorMessage = "Current image missing";
            result.baselineExists = true;
            result.currentExists = false;
        } else if (a.isNull() && b.isNull()) {
            result.errorMessage = "Both images missing";
            result.baselineExists = false;
            result.currentExists = false;
        } else if (a.size() != b.size()) {
            result.errorMessage = QString("Size mismatch: %1x%2 vs %3x%4")
                                     .arg(a.width()).arg(a.height())
                                     .arg(b.width()).arg(b.height());
            result.baselineExists = true;
            result.currentExists = true;
            result.sizesMatch = false;
            result.baselineSize = a.size();
            result.currentSize = b.size();
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
    result.currentExists = true;
    result.sizesMatch = true;
    result.baselineSize = a.size();
    result.currentSize = b.size();
    
    return result;
}

CompareModel::ImageResult CompareModel::getResultData(const QString filename) const
{
    if (!m_results.contains(filename)) {
        // Return a pending result - comparison is in progress or queued
        ImageResult result;
        result.pending = true;
        result.errorMessage = "Comparing...";
        return result;
    }
    return m_results.value(filename);
}

void CompareModel::onComparisonComplete(const QString &filename, const ImageResult &result)
{
    // Store the result
    m_results.insert(filename, result);

    // Find the row index
    int row = m_data.indexOf(filename);
    if (row >= 0) {
        // Emit dataChanged for this row
        QModelIndex idx = index(row);
        emit dataChanged(idx, idx);
    }

    // Update counts
    emit passCountChanged();
    emit failedCountChanged();
    emit exactCountChanged();
    emit missingBaselineCountChanged();
    emit missingCurrentCountChanged();
}

void CompareModel::startAsyncComparison(const QString &filename)
{
    // Mark as pending (preserve existing validation data if present)
    ImageResult pendingResult;
    if (m_results.contains(filename)) {
        pendingResult = m_results.value(filename);
    }
    pendingResult.pending = true;
    pendingResult.errorMessage = "Pending...";
    m_results.insert(filename, pendingResult);

    // Queue the comparison task
    ComparisonWorker *worker = new ComparisonWorker(this, filename);
    m_threadPool->start(worker);
}
