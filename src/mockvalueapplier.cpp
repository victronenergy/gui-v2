/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "mockvalueapplier.h"
#include "backendconnection.h"
#include "veqitemmockproducer.h"

using namespace Victron::VenusOS;

MockValueApplier::MockValueApplier(QObject *parent)
	: QObject(parent)
	, m_producer(qobject_cast<VeQItemMockProducer *>(BackendConnection::create()->producer()))
{
	if (!m_producer) {
		qWarning("MockValueApplier: VeQItemMockProducer not available!");
	}

	// Drain timer fires every ~16ms (one frame at 60fps) to spread value
	// application across frames rather than applying everything at once.
	m_drainTimer.setInterval(16);
	m_drainTimer.setSingleShot(false);
	connect(&m_drainTimer, &QTimer::timeout, this, &MockValueApplier::processQueue);
}

void MockValueApplier::registerNotify(int animatorId, const MockNotifyCallbacks &callbacks)
{
	m_notifyMap[animatorId] = callbacks;
}

void MockValueApplier::unregisterNotify(int animatorId)
{
	m_notifyMap.remove(animatorId);
}

void MockValueApplier::applyValues(const MockValueUpdateList &updates)
{
	if (!m_producer || updates.isEmpty()) {
		return;
	}

	// Deduplicate: keep only the latest value per uid.
	// Build a uid to index map of the current queue for O(1) lookups.
	QHash<QString, qsizetype> uidIndex;
	uidIndex.reserve(m_queue.size());
	for (qsizetype i = 0; i < m_queue.size(); ++i) {
		uidIndex[m_queue[i].first] = i;
	}

	for (const auto &[uid, value] : updates) {
		auto it = uidIndex.find(uid);
		if (it != uidIndex.end()) {
			m_queue[it.value()].second = value;
		} else {
			uidIndex[uid] = m_queue.size();
			m_queue.enqueue({uid, value});
		}
	}

	// Safety valve: if the queue is growing beyond a reasonable size,
	// drain everything immediately to prevent unbounded accumulation.
	if (m_queue.size() > MaxQueueSize) {
		while (!m_queue.isEmpty()) {
			const auto [uid, value] = m_queue.dequeue();
			m_producer->setValue(uid, value.isNull() ? QVariant() : value);
		}
		m_drainTimer.stop();
		return;
	}

	if (!m_drainTimer.isActive()) {
		// Apply the first batch immediately (no delay for the first frame)
		processQueue();
		if (!m_queue.isEmpty()) {
			m_drainTimer.start();
		}
	}
}

void MockValueApplier::dispatchNotifyUpdate(int animatorId, int index, qreal newValue)
{
	auto it = m_notifyMap.find(animatorId);
	if (it != m_notifyMap.end() && it->onUpdate) {
		it->onUpdate(index, newValue);
	}
}

void MockValueApplier::dispatchNotifyTotal(int animatorId, qreal total)
{
	auto it = m_notifyMap.find(animatorId);
	if (it != m_notifyMap.end() && it->onTotal) {
		it->onTotal(total);
	}
}

void MockValueApplier::processQueue()
{
	if (!m_producer || m_queue.isEmpty()) {
		m_drainTimer.stop();
		return;
	}

	const int count = qMin(static_cast<qsizetype>(MaxUpdatesPerTick), m_queue.size());
	for (int i = 0; i < count; ++i) {
		const auto [uid, value] = m_queue.dequeue();
		m_producer->setValue(uid, value.isNull() ? QVariant() : value);
	}

	if (m_queue.isEmpty()) {
		m_drainTimer.stop();
	}
}
