#ifndef COMPAREMODEL_H
#define COMPAREMODEL_H

#include <qqmlintegration.h>
#include <QAbstractListModel>
#include <QHash>
#include <QSize>
#include <QThreadPool>

class CompareModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int exactMatchCount READ exactMatchCount NOTIFY exactMatchCountChanged)
    Q_PROPERTY(int passCount READ passCount NOTIFY passCountChanged)
    Q_PROPERTY(int failedCount READ failedCount NOTIFY failedCountChanged)
    Q_PROPERTY(int missingBaselineCount READ missingBaselineCount NOTIFY missingBaselineCountChanged)
    Q_PROPERTY(int missingCandidateCount READ missingCandidateCount NOTIFY missingCandidateCountChanged)
    Q_PROPERTY(int filterMode READ filterMode WRITE setFilterMode NOTIFY filterModeChanged)

public:
    enum RoleNames {
        TitleRole = Qt::DisplayRole,
        TextRole = Qt::UserRole,
        SimilarityRole,
        MeanErrorRole,
        IdenticalRole,
        ErrorMessageRole,
    };

    struct ImageResult
    {
        // The file to be compared
        QString fileName;

        // Validation state
        bool baselineExists = false;
        bool candidateExists = false;
        bool sizesMatch = false;
        QSize baselineSize;
        QSize candidateSize;

        // Comparison results
        double similarity = 0.0;
        double meanError = 0.0;
        bool valid = false;
        bool identical = false;
        bool pending = false;
        QString errorMessage;
    };

    explicit CompareModel(QObject *parent = 0);
    ~CompareModel();

    int count();
    int exactMatchCount();
    int passCount();
    int failedCount();
    int missingBaselineCount();
    int missingCandidateCount();
    int filterMode() const { return m_filterMode; }

    Q_INVOKABLE void setFilterMode(int mode);
    Q_INVOKABLE void discoverImages();
    Q_INVOKABLE void validateImages();
    Q_INVOKABLE void startComparisons();
    Q_INVOKABLE void refresh();

    Q_INVOKABLE void onComparisonComplete(const QString &filename, const CompareModel::ImageResult &result);
    Q_INVOKABLE void onDiscoveryComplete(const QStringList &filenames);

protected:
    // QAbstractItemModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    QHash<int, QByteArray> roleNames() const override;

Q_SIGNALS:
    void countChanged();
    void exactMatchCountChanged();
    void passCountChanged();
    void failedCountChanged();
    void missingBaselineCountChanged();
    void missingCandidateCountChanged();
    void filterModeChanged();

private:
    void discoverImagesFromFileSystem();
    void applyFilter();
    void startAsyncComparison(const QString &filename);
    void validateImage(const QString &filename);

    ImageResult getResultData(QString filename) const;
    bool passesFilter(const QString &filename) const;

    QHash<QString, ImageResult> m_results;
    QList<QString> m_allData;
    QList<QString> m_data;
    QThreadPool *m_threadPool = nullptr;
    int m_filterMode = 0;  // 0=all, 1=pass, 2=fail, 3=missing baseline, 4=missing candidate
};

#endif // COMPAREMODEL_H
