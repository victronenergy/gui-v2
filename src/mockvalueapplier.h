/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#ifndef VICTRON_GUIV2_MOCKVALUEAPPLIER_H
#define VICTRON_GUIV2_MOCKVALUEAPPLIER_H

#include "mocktimerworker.h"

#include <QHash>
#include <QObject>
#include <QQueue>
#include <QTimer>

#include <functional>

namespace Victron {
namespace VenusOS {

class VeQItemMockProducer;

// Notification callbacks registered by individual animator instances
struct MockNotifyCallbacks {
	std::function<void(int index, qreal newValue)> onUpdate;
	std::function<void(qreal total)> onTotal;
};

/*
	MockValueApplier lives on the GUI thread. It:
	1. Receives batched value updates from MockTimerWorker and applies them
	   one at a time. Each setValue() runs QML bindings, and applying a whole
	   animator tick in one turn freezes the GUI.
	2. Emits notifyUpdate/notifyTotal only after setValue() has applied the
	   uids listed on that notify record. The worker must not emit those
	   QML signals itself.
	3. Holds a uid after a GUI write, and a removed path, until the worker
	   says it has dropped the in-flight batch. Applying that batch would
	   overwrite the write or recreate the deleted service.
*/
class MockValueApplier : public QObject
{
	Q_OBJECT

public:
	explicit MockValueApplier(QObject *parent = nullptr);

	// One value per drain. A mock setValue() runs QML bindings that take
	// several milliseconds on the overview, so a larger chunk freezes the GUI.
	static constexpr int MaxUpdatesPerTick = 1;

	// Register/unregister notification callbacks for a specific animator
	void registerNotify(int animatorId, const MockNotifyCallbacks &callbacks);
	void unregisterNotify(int animatorId);

	// Drop a queued copy of uid and hold it until acknowledgeExternalWrite().
	void supersede(const QString &uid);
	// Drop queued updates under prefix and hold them until acknowledgePrefix().
	void blockPrefix(const QString &prefix);
	// Drop queued updates under prefix. While applying, skip the rest of that prefix.
	void dropPrefix(const QString &prefix);
	bool hasPending(const QString &uid) const;
	bool pendingValue(const QString &uid, QVariant *value) const;
	// True while a value or notify is still waiting to be applied.
	bool hasPendingWork() const;
	// Apply whatever is queued, one value per call. Tests use this so the next
	// case does not wait behind the previous one. The GUI timer is unchanged.
	void drainPendingForTest();

public Q_SLOTS:
	void applyValues(const Victron::VenusOS::MockValueUpdateList &updates,
			const Victron::VenusOS::MockNotifyEventList &notifications = {},
			const Victron::VenusOS::MockTickRecordList &ticks = {});
	void acknowledgeExternalWrite(const QString &uid);
	void acknowledgePrefix(const QString &prefix);

private Q_SLOTS:
	void processQueue();

private:
	VeQItemMockProducer *m_producer = nullptr;
	QQueue<MockValueUpdate> m_queue;
	QTimer m_drainTimer;

	// Direct dispatch map: animatorId -> callbacks
	QHash<int, MockNotifyCallbacks> m_notifyMap;
	// True while setValue() is applying queued values. A remove during that
	// pass skips the rest of the prefix. Not set while notifying.
	// Counts, not flags: a write can arrive again before the worker answers.
	QHash<QString, int> m_externalBlocks;
	QHash<QString, int> m_prefixBlocks;
	bool m_applyingValues = false;
	// True while notify callbacks run. A handler must not start another pass.
	bool m_dispatchingNotifications = false;
	QStringList m_skipPrefixes;

	bool isBlocked(const QString &uid) const;
	bool shouldSkip(const QString &uid) const;
	void removeQueued(const QString &uid);
	void removeQueuedUnderPrefix(const QString &prefix);
	bool notificationReady(const MockNotifyEvent &event) const;
	void enqueueNotification(const MockNotifyEvent &event);
	void dropNotifications(const std::function<bool(const QString &)> &affected);
	void dispatchNotification(const MockNotifyEvent &event);
	void dispatchReadyNotifications();

	// Notify records waiting until every dependsOn uid has left m_queue.
	QVector<MockNotifyEvent> m_pendingNotifications;
};

} // namespace VenusOS
} // namespace Victron

#endif // VICTRON_GUIV2_MOCKVALUEAPPLIER_H
