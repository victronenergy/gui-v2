#ifndef COMPAREMODEL_H
#define COMPAREMODEL_H

#include <qqmlintegration.h>
#include <QAbstractListModel>
#include <QHash>
#include <QSize>
#include <QThreadPool>
#include <QElapsedTimer>

class CompareModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(qreal errorTolerance READ errorTolerance WRITE setErrorTolerance NOTIFY errorToleranceChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int passCount READ passCount NOTIFY passCountChanged)
    Q_PROPERTY(int failedCount READ failedCount NOTIFY failedCountChanged)
    Q_PROPERTY(int missingBaselineCount READ missingBaselineCount NOTIFY missingBaselineCountChanged)
    Q_PROPERTY(int missingCandidateCount READ missingCandidateCount NOTIFY missingCandidateCountChanged)
    Q_PROPERTY(int filterMode READ filterMode WRITE setFilterMode NOTIFY filterModeChanged)

public:
    enum Role {
        FileNameRole = Qt::DisplayRole,
        StatusRole,
        MeanSquaredErrorRole,
        ErrorMessageRole,
    };
    Q_ENUM(Role);

    enum ComparisonResult {
        ComparisonPending,
        ComparisonReady,
        NoBaselineImage,
        NoCandidateImage,
    };
    Q_ENUM(ComparisonResult);

    struct ImageResult
    {
         // The default is the max MSE, i.e. comparison fails for all pixels in all channels.
        static constexpr qreal DefaultMse = (255 * 255) * 4;

        QString errorMessage;
        qreal mse = DefaultMse;
        int status = ComparisonPending;
    };

    explicit CompareModel(QObject *parent = 0);
    ~CompareModel();

    qreal errorTolerance() const { return m_errorTolerance; }
    void setErrorTolerance(qreal errorTolerance);

    int count() const;

    int passCount() const { return m_passCount; }
    int failedCount() const { return m_failedCount; }
    int missingBaselineCount() const { return m_missingBaselineCount; }
    int missingCandidateCount() const { return m_missingCandidateCount; }
    int filterMode() const { return m_filterMode; }

    Q_INVOKABLE void setFilterMode(int mode);
    Q_INVOKABLE void refresh();
    Q_INVOKABLE QVariantMap get(int index) const;

    Q_INVOKABLE void onComparisonComplete(const QString &filename, const CompareModel::ImageResult &result);
    Q_INVOKABLE void onDiscoveryComplete(const QStringList &filenames);

protected:
    // QAbstractItemModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

Q_SIGNALS:
    void errorToleranceChanged();
    void countChanged();
    void passCountChanged();
    void failedCountChanged();
    void missingBaselineCountChanged();
    void missingCandidateCountChanged();
    void filterModeChanged();
    void firstResultAvailable();

private:
    void discoverImages();
    void startComparisons();
    void applyFilter();
    bool passesFilter(const QString &filename) const;

    QHash<QString, ImageResult> m_results;
    QList<QString> m_allData;
    QList<QString> m_data;
    QElapsedTimer m_comparisonTimer;
    QThreadPool *m_threadPool = nullptr;
    qreal m_errorTolerance = 255.0;
    int m_filterMode = 0;  // 0=all, 1=pass, 2=fail, 3=missing baseline, 4=missing candidate
    int m_passCount = 0;
    int m_failedCount = 0;
    int m_missingBaselineCount = 0;
    int m_missingCandidateCount = 0;
};

#endif // COMPAREMODEL_H
