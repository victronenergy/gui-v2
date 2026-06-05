#ifndef COMPAREMODEL_H
#define COMPAREMODEL_H

#include <QAbstractListModel>
#include <QtQml>
#include <qquickimageprovider.h>
#include <QThreadPool>
#include <QRunnable>

class CompareModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int exactCount READ exactCount NOTIFY exactCountChanged)
    Q_PROPERTY(int passCount READ passCount NOTIFY passCountChanged)
    Q_PROPERTY(int failedCount READ failedCount NOTIFY failedCountChanged)
    Q_PROPERTY(int missingBaselineCount READ missingBaselineCount NOTIFY missingBaselineCountChanged)
    Q_PROPERTY(int missingCurrentCount READ missingCurrentCount NOTIFY missingCurrentCountChanged)
    Q_PROPERTY(int filterMode READ filterMode WRITE setFilterMode NOTIFY filterModeChanged)

public:
    explicit CompareModel(QObject *parent = 0);
    ~CompareModel();

    struct ImageResult
    {
        // Validation state
        bool baselineExists = false;
        bool currentExists = false;
        bool sizesMatch = false;
        QSize baselineSize;
        QSize currentSize;

        // Comparison results
        double similarity = 0.0;
        double meanError = 0.0;
        bool valid = false;
        bool identical = false;
        bool pending = false;
        QString errorMessage;
    };

public:
    enum RoleNames {
        TitleRole = Qt::DisplayRole,
        TextRole = Qt::UserRole,
        SimilarityRole,
        MeanErrorRole,
        IdenticalRole,
        ErrorMessageRole,
    };

public: // QAbstractItemModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;

public: // QListView interface
    bool remove(const QModelIndex &index);
    int append(const QString file);

    QVariantMap get(const QModelIndex &index);

public:
    int count();
    int exactCount();
    int passCount();
    int failedCount();
    int missingBaselineCount();
    int missingCurrentCount();
    int filterMode() const { return m_filterMode; }
    Q_INVOKABLE void setFilterMode(int mode);
    Q_INVOKABLE void discoverImages();
    Q_INVOKABLE void validateImages();
    Q_INVOKABLE void startComparisons();
    Q_INVOKABLE void refresh();

public Q_SLOTS:
    // Make public so worker can call it
    CompareModel::ImageResult compare(QString filename) const;
    void onComparisonComplete(const QString &filename, const CompareModel::ImageResult &result);
    void onDiscoveryComplete(const QStringList &filenames);

Q_SIGNALS:
    void countChanged();
    void exactCountChanged();
    void passCountChanged();
    void failedCountChanged();
    void missingBaselineCountChanged();
    void missingCurrentCountChanged();
    void filterModeChanged();

protected:
    QHash<int, QByteArray> roleNames() const override;

    void initializeRoleData();
    void discoverImagesFromFileSystem();
    void applyFilter();
    void startAsyncComparison(const QString &filename);
    void validateImage(const QString &filename);

    ImageResult getResultData(QString filename) const;
    bool passesFilter(const QString &filename) const;


private:
    QList<QString> m_allData;
    QList<QString> m_data;
    mutable QHash<QString, ImageResult> m_results;
    int m_filterMode = 0;  // 0=all, 1=pass, 2=fail, 3=missing baseline, 4=missing current
    QThreadPool *m_threadPool;
};

#endif // COMPAREMODEL_H
