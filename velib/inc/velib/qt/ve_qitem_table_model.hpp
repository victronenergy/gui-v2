#ifndef _VELIB_QT_VE_QITEM_TABLE_MODEL_HPP_
#define _VELIB_QT_VE_QITEM_TABLE_MODEL_HPP_

#include <QAbstractItemModel>
#include <QHash>
#include <QModelIndex>
#include <QStringList>
#include <QVariant>

#include <velib/qt/ve_qitem.hpp>

#if QT_VERSION >= 0x050000
#include <QQmlParserStatus>
#define QDeclarativeParserStatus QQmlParserStatus
#else
#include <QDeclarativeParserStatus>
#endif

class VeQItemTableModel : public QAbstractItemModel, public QDeclarativeParserStatus
{
	Q_OBJECT
	Q_INTERFACES(QDeclarativeParserStatus)
	Q_ENUMS(VeQItemTableRoles)
	Q_ENUMS(Flags)
	Q_ENUMS(VeQItemColumn)
	Q_PROPERTY(QStringList uids READ uids WRITE setUids NOTIFY uidsChanged)
	Q_PROPERTY(VeQItemTableModel::Flags flags READ flags WRITE setFlags NOTIFY flagsChanged)
	Q_PROPERTY(int rowCount READ rowCount NOTIFY rowCountChanged)

public:
	enum VeQItemTableRoles {
		UniqueIdRole = Qt::UserRole + 1,
		IdRole,
		ValueRole,
		StateRole,
		TextRole,
		TextStateRole,
		ItemRole,
		// Below roles are for the VeQItemChildModel
		SortValueRole,
		BuddyRole,
	};

	enum VeQItemColumn {
		IdColumn,
		ValueColumn,
		StateColumn,
	};

	enum Flag {
		NoOptions				= 0,
		DontAddItem				= 0x01,
		AddChildren				= 0x02,
		AddAllChildren			= 0x04,
		AddNonLeaves			= 0x08,
		WithText				= 0x1000,
		WithSettingInfo			= 0x2000,
	};

	Q_DECLARE_FLAGS(Flags, Flag)

	VeQItemTableModel(Flags flags = AddAllChildren, QObject *parent = 0);

	void addItem(VeQItem *item);
	QVariant data(const QModelIndex &index, int role) const;
	Qt::ItemFlags flags(const QModelIndex &index) const;
	bool setData(const QModelIndex & index, const QVariant &value, int role = Qt::EditRole);
	QVariant headerData(int section, Qt::Orientation orientation,
						int role = Qt::DisplayRole) const;
	QModelIndex index(int row, int column,
					  const QModelIndex &parent = QModelIndex()) const;
	QModelIndex parent(const QModelIndex &index) const;
	int rowCount(const QModelIndex &parent = QModelIndex()) const;
	int columnCount(const QModelIndex &parent = QModelIndex()) const;
	QHash<int, QByteArray> roleNames() const;
	Q_INVOKABLE QVariant getValue(int row, int column);

	void updateModel();

	VeQItemTableModel::Flags flags() { return mFlags; }
	void setFlags(VeQItemTableModel::Flags flags);

	QStringList uids() { return mUids; }
	void setUids(const QStringList &uids);

	void classBegin() {}
	void componentComplete();

protected:
	QList<QString> mColumns;
	QVector<VeQItem *> mVector;

	void clear();
	void remove(int n);

	void endInsertRows();
	void endRemoveRows();

	/*
	 * If additional data is attached in a derived class, it should be added
	 * between the beginInsertRows and endInsertRows, other wise it will be
	 * out of sync and weird things will happen. This function is exactly
	 * in between these signals.
	 */
	virtual void doInsertItem(VeQItem *item, int row);
	virtual void doRemove(int n);

	void setupValueChanges(VeQItem *item, Flags options = NoOptions, int row = -1);

signals:
	void flagsChanged();
	void uidsChanged();
	void rowCountChanged();

private slots:
	void onChildAdded(VeQItem *item);
	void onRecursiveChildAdded(VeQItem *item);
	void onItemAboutToBeRemoved(VeQItem *item);
	void onValueChanged(VeQItem *item);
	void onStateChanged(VeQItem *item);
	void onTextChanged(VeQItem *item);
	void onTextStateChanged(VeQItem *item);
	void onDynamicPropertyChanged(VeQItem *item, const char *name);
	void addExistingChildren(VeQItem *item, void *ctx);

private:
	void cellChanged(VeQItem *item, QString column);
	void appendItem(VeQItem *item, int row = -1);
	void setFlagsNoSignal(Flags flags);

	QHash<QString, VeQItem *> mHash;
	Flags mFlags;
	bool mCompleted;
	QStringList mUids;
};

Q_DECLARE_OPERATORS_FOR_FLAGS(VeQItemTableModel::Flags)

#undef QDeclarativeParserStatus

#endif
