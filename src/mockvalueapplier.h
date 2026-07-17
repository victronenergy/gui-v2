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
	3. Drops a queued tick when a uid it read or wrote is written or removed,
	   including outputs that are not that uid. Applying them would overwrite
	   the write, or recreate a deleted service.
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

	// Drop a queued copy of uid, and every queued output of a tick that used it.
	// Returns outputs that were dropped.
	QSet<QString> supersede(const QString &uid);
	// Drop queued updates under prefix, and queued outputs of ticks that used it.
	// While applying, skip the rest of that prefix. Returns outputs that were dropped.
	QSet<QString> dropPrefix(const QString &prefix);
	// Drop queued ticks for this animator, and ticks that used their outputs.
	// A calculator tick is not an animator and is left unless it used those outputs.
	QSet<QString> dropAnimator(int animatorId);
	// Remove these queued values. Leave the rest of their tick to be applied.
	void discardQueuedValues(const QSet<QString> &uids);
	// Take these uids off queued tick records. A later cancel must not drop a
	// replacement that is not part of those ticks.
	void retireOutputOwnership(const QSet<QString> &uids);
	int queuedTickCountForTest() const;
	bool hasPending(const QString &uid) const;
	bool pendingValue(const QString &uid, QVariant *value) const;
	// True when this uid already has a value. Does not create the item.
	// An empty item created by a binding is not a value.
	bool hadValue(const QString &uid) const;
	// True while a value or notify is still waiting to be applied.
	bool hasPendingWork() const;
	// Apply whatever is queued, one value per call. Tests use this so the next
	// case does not wait behind the previous one. The GUI timer is unchanged.
	void drainPendingForTest();

public Q_SLOTS:
	void applyValues(const Victron::VenusOS::MockValueUpdateList &updates,
			const Victron::VenusOS::MockNotifyEventList &notifications = {},
			const Victron::VenusOS::MockTickRecordList &ticks = {});

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
	bool m_applyingValues = false;
	// True while notify callbacks run. A handler must not start another pass.
	bool m_dispatchingNotifications = false;
	QStringList m_skipPrefixes;

	bool shouldSkip(const QString &uid) const;
	void removeQueued(const QString &uid);
	void removeQueuedUnderPrefix(const QString &prefix);
	void rememberTicks(const Victron::VenusOS::MockTickRecordList &ticks);
	// Take replaced outputs off older records. A tick that read one keeps that
	// record's inputs and animator, so a later cancel still reaches it.
	void retireReplacedOutputs(MockTickRecord &incoming);
	// affected matches a uid. dropTick matches a whole tick, such as one animator.
	// Returns every output that was dropped.
	QSet<QString> dropQueuedTickOutputs(
			const std::function<bool(const QString &)> &affected,
			const std::function<bool(const MockTickRecord &)> &dropTick = {});
	void pruneAppliedTicks();
	bool notificationReady(const MockNotifyEvent &event) const;
	void enqueueNotification(const MockNotifyEvent &event);
	void dropNotifications(const std::function<bool(const QString &)> &affected);
	void dispatchNotification(const MockNotifyEvent &event);
	void dispatchReadyNotifications();

	// Notify records waiting until every dependsOn uid has left m_queue.
	QVector<MockNotifyEvent> m_pendingNotifications;
	// Ticks whose outputs are still in m_queue. A write or removal drops them.
	QVector<MockTickRecord> m_queuedTicks;
};

} // namespace VenusOS
} // namespace Victron

#endif // VICTRON_GUIV2_MOCKVALUEAPPLIER_H
