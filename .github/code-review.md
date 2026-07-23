# Code Review Guide

Structured checklist for reviewing changes to gui-v2. Items are ordered by priority within each category.

## Table of contents

- [1. Review methodology](#1-review-methodology)
  - [1.a. Per-function discipline](#1a-per-function-discipline)
  - [1.b. Cross-file verification](#1b-cross-file-verification)
  - [1.c. Temporal reasoning](#1c-temporal-reasoning)
  - [1.d. Feature interaction analysis](#1d-feature-interaction-analysis)
- [2. Correctness (highest priority)](#2-correctness-highest-priority)
  - [2.a. Invariant consistency](#2a-invariant-consistency)
  - [2.b. Data flow and path correctness](#2b-data-flow-and-path-correctness)
  - [2.c. Boundary validation](#2c-boundary-validation)
  - [2.d. Thread safety](#2d-thread-safety)
  - [2.e. Event delivery and ordering](#2e-event-delivery-and-ordering)
  - [2.f. Backend disconnection and state transitions](#2f-backend-disconnection-and-state-transitions)
  - [2.g. Lifecycle and resource management](#2g-lifecycle-and-resource-management)
  - [2.h. Enable/disable and reconfiguration cycles](#2h-enabledisable-and-reconfiguration-cycles)
  - [2.i. Numeric edge cases](#2i-numeric-edge-cases)
  - [2.j. Collection and container edge cases](#2j-collection-and-container-edge-cases)
  - [2.k. QML-specific correctness](#2k-qml-specific-correctness)
  - [2.l. State machine and enum correctness](#2l-state-machine-and-enum-correctness)
  - [2.m. Translation and i18n correctness](#2m-translation-and-i18n-correctness)
  - [2.n. Key navigation completeness](#2n-key-navigation-completeness)
  - [2.o. Portrait and landscape coverage](#2o-portrait-and-landscape-coverage)
  - [2.p. Access level gating consistency](#2p-access-level-gating-consistency)
  - [2.q. Mock data synchronization](#2q-mock-data-synchronization)
  - [2.r. Platform-specific correctness](#2r-platform-specific-correctness)
  - [2.s. API design and encapsulation](#2s-api-design-and-encapsulation)
- [3. Performance (medium priority)](#3-performance-medium-priority)
  - [3.a. GUI thread stalls](#3a-gui-thread-stalls)
  - [3.b. GUI thread execution pressure](#3b-gui-thread-execution-pressure)
  - [3.c. Rendering performance](#3c-rendering-performance)
  - [3.d. Memory pressure](#3d-memory-pressure)
  - [3.e. Optimization fidelity](#3e-optimization-fidelity)
- [4. Maintainability (lower priority)](#4-maintainability-lower-priority)
  - [4.a. Code clarity](#4a-code-clarity)
  - [4.b. Code style](#4b-code-style)
  - [4.c. Documentation](#4c-documentation)
  - [4.d. Test coverage](#4d-test-coverage)
  - [4.e. Observability and debuggability](#4e-observability-and-debuggability)
  - [4.f. Build system and tooling](#4f-build-system-and-tooling)
  - [4.g. Security](#4g-security)

---

## 1. Review methodology

The checklist below describes WHAT to look for. This section describes HOW to apply it systematically. Do not skim — read every changed line and trace its implications.

### 1.a. Per-function discipline

For each function or property setter that is new or modified:

1.a.i. **Read line by line.** Do not skip "obvious" code. Bugs hide in the lines you assume are correct.

1.a.ii. **Enumerate all callers.** Find every call site (including signal connections and QML bindings). For each caller, verify the arguments are correct in type, order, range, and meaning. Ask: "What is the worst value this caller could pass, and does this function handle it?"

1.a.iii. **Identify the downstream effect.** What does this function ultimately cause? (e.g., "posts config to worker", "writes a value to cache", "starts a timer"). Then trace ALL other code paths that lead to the same downstream effect and verify they share the same preconditions and guards.

1.a.iv. **Check the else/error/early-return paths.** If the function has an early return or else branch, verify it cleans up or invalidates everything that the success path would have set. Partial cleanup is a bug.

1.a.v. **Simulate with edge-case inputs.** Mentally execute the function with: empty strings, empty collections, NaN, zero, negative numbers, null/undefined, maximum values, and the value it had on the previous call (no-change case).

### 1.b. Cross-file verification

1.b.i. **Cross-reference constructed paths against data sources.** For every UID/path string built in code, find the JSON config file, D-Bus definition, or backend documentation that defines that path and verify character-by-character that they match. Do not assume a path is correct because it "looks right."

1.b.ii. **Verify consistency between sibling implementations.** If multiple files implement the same pattern (e.g., several QML mock files each using `Global.system.serviceUid`), check ALL of them — not just the one being changed. Inconsistency between siblings usually means at least one is wrong.

### 1.c. Temporal reasoning

1.c.i. **Trace the full lifecycle.** For any object or subsystem: what happens at creation → first use → reconfiguration → deactivation → reactivation → destruction? Verify each transition is handled and leaves the system in a valid state.

1.c.ii. **Consider ordering between async operations.** When code posts multiple queued invocations or emits multiple signals, reason about what happens if other events interleave between them. Verify correctness doesn't depend on the assumption that queued calls execute atomically as a group.

1.c.iii. **Ask "what if this is called twice?"** For setup/teardown operations, registrations, timer starts, and config posts — what happens if the same operation is triggered redundantly? It should be idempotent or properly guarded.

### 1.d. Feature interaction analysis

1.d.i. **Enumerate sibling features on the same page/component.** When a change modifies behaviour on a page (e.g., animation rendering), explicitly list other features active on that page (throttling, CPU governors, lazy loading, theme changes, dynamic model updates) and reason about interaction. Changes that are correct in isolation can break when combined with sibling features.

1.d.ii. **Trace shared resource contention.** If the change introduces caches, timers, or background work, identify what else uses the same resources (memory on embedded, CPU budget, scene graph batches). Verify the new usage doesn't push aggregate consumption past acceptable limits under realistic combinations.

1.d.iii. **Verify visual regression test coverage.** When a change alters the rendering pipeline (reparenting, layer changes, opacity handling, scene graph structure), check whether existing visual regression tests cover the affected area. Rendering changes that produce mathematically equivalent coordinates can still introduce visible differences (subpixel positioning, antialiasing, batch boundaries). If coverage is missing, note it.

---

## 2. Correctness (highest priority)

### 2.a. Invariant consistency

For every function or property setter:

2.a.i. **Sibling consistency**: If multiple functions lead to the same downstream effect (e.g., posting config to a worker), verify that ALL of them share the same precondition guards. If one gates on `m_active`, all must gate on `m_active`. If one checks for empty strings, all must check for empty strings.

2.a.ii. **State flag accuracy**: Track boolean state flags (`m_registered`, `m_active`, `m_complete`, etc.) through every code path. Verify they are set/cleared at the correct point — not before the action they represent, and not left stale after failure.

2.a.iii. **Bidirectional map consistency**: If two maps are kept in sync (e.g., `m_timerIdToAnimator` / `m_animatorToTimer`), verify that every insert, remove, and clear operation affects both maps in all code paths including error/early-return paths.

2.a.iv. **Re-entry safety**: If a function can be called while already in effect (e.g., re-registering an animator that's already registered), verify the old state is fully cleaned up before establishing new state.

2.a.v. **Conditional action completeness**: If a condition gates multiple related writes (e.g., "if has data, write power AND current AND phase count"), verify the else-branch clears ALL of the same fields — not a subset.

### 2.b. Data flow and path correctness

2.b.i. **UID/path string construction**: For every constructed path string, verify it matches the actual data model. Cross-reference against JSON config files, D-Bus introspection data, or backend documentation. Common errors: missing path segments (`/Ac/1/P` vs `/Ac/In/1/P`), wrong separators, wrong index bases (0-based vs 1-based).

2.b.ii. **Variable vs literal in string construction**: In template literals and `QString::arg()` calls, verify that loop variables and parameters are actually used — not accidentally left as literal text (e.g., `` `${prefix}/path` `` vs `` `${prefix}${path}` ``).

2.b.iii. **Argument ordering and naming**: When a function takes multiple string/numeric arguments of the same type, verify callers pass them in the correct order. Watch for swapped arguments that happen to compile (e.g., two `QString` parameters swapped).

2.b.iv. **Cross-boundary data consistency**: When QML posts data to C++, or GUI thread posts to worker thread, verify the values at the call site match what the receiver expects. Check types, ranges, and whether "empty" means `""`, `null`, `undefined`, `QVariant()`, or `-1`.

2.b.v. **Service UID prefix handling**: `Global.system.serviceUid` includes the backend prefix (`mock/`, `dbus/`, `mqtt/`). `VeQItemMockProducer::normalizedUid()` strips `mock/`. Verify that paths aren't double-prefixed or missing the prefix depending on which API consumes them.

### 2.c. Boundary validation

2.c.i. **Validate inputs at component boundaries**: Functions that receive data from another component, thread, or QML layer must not assume inputs are well-formed. Validate that required strings are non-empty, required collections are non-empty, and numeric values are in expected ranges. An empty `targetPrefix` should not silently produce paths like `"/L1/Power"`.

2.c.ii. **Fail safe on invalid input**: When input validation fails, the function should either return early (doing nothing), clear/invalidate any previously-written output, or emit an error signal. It must NOT proceed with garbage data and write nonsense to shared state.

2.c.iii. **Validate at the earliest boundary**: If a value passes through multiple layers (QML → C++ property setter → queued invocation → worker function), validate at the first C++ entry point — not deep inside the worker where the damage is already in the queue.

2.c.iv. **Document preconditions**: If a function requires non-empty strings, positive numbers, or non-null objects, document it. But still validate defensively — documentation alone doesn't prevent bugs.

### 2.d. Thread safety

2.d.i. **Cross-thread data access**: Any data shared between threads must be protected. In this codebase, the primary pattern is message-passing via `QMetaObject::invokeMethod(Qt::QueuedConnection)` and signal/slot auto-connections. Verify no direct member access across thread boundaries.

2.d.ii. **Signal emission from wrong thread**: If an object has thread affinity to thread A, its signals must be emitted from thread A. Emitting from thread B with connected slots on thread A is safe (queued), but emitting from thread B with connected slots on thread B (direct connection) while thread A may access shared state is not.

2.d.iii. **Shared container modification**: `QHash`, `QMap`, `QList`, `QVector` are not thread-safe. If a container is read from one thread and written from another (even via queued connections), verify there is no concurrent access window.

2.d.iv. **Atomic operations**: `std::atomic` is thread-safe for single reads/writes but compound operations (read-modify-write) may still race. Verify atomics are used correctly (e.g., `fetch_add` vs separate read + write).

### 2.e. Event delivery and ordering

2.e.i. **Queued invocation ordering**: Multiple `QMetaObject::invokeMethod(Qt::QueuedConnection)` calls to the same target are delivered in order. But calls to DIFFERENT targets (e.g., worker first, then applier) may interleave with other events. Verify correctness doesn't depend on cross-object delivery order.

2.e.ii. **Signal emission during construction**: `Component.onCompleted` in QML and constructor code in C++ may trigger signals before all related objects are fully initialized. Verify signal handlers don't access uninitialized siblings or properties.

2.e.iii. **Deferred deletion**: `QObject::deleteLater()` and QML garbage collection mean an object may still receive queued signals/events after logical destruction. Verify handlers guard against stale state.

2.e.iv. **Timer coalescing**: Zero-interval timers (`startTimer(0)`) fire once per event loop iteration but may coalesce multiple triggers. Verify that batch-flush patterns handle being called once even if multiple sources triggered.

2.e.v. **Model reset ordering**: When a model emits `modelReset`, all delegates are destroyed and recreated. Any state stored in delegates (connections, timers, cached values) is lost. Verify that delegate-held state is either reconstructed correctly or stored externally.

### 2.f. Backend disconnection and state transitions

2.f.i. **Connection state regression**: `BackendConnection` can transition from `Ready` back to `Connecting` (network loss, VRM disconnect). Verify code handles the sequence Ready → Connecting → Ready without stale data or duplicate registrations.

2.f.ii. **Service disappearance**: Services can disappear at any time (device unplugged, D-Bus service crash). `VeQuickItem.valid` becomes false, `value` becomes undefined/invalid. Verify code handles `!valid` / `undefined` / `NaN` gracefully in all consumers.

2.f.iii. **Partial service data**: A service may appear with only some paths populated. Verify code doesn't assume all paths exist simultaneously (e.g., `/Ac/L1/Power` may exist without `/Ac/L2/Power`).

2.f.iv. **Stale values after disconnect**: When a service disappears, cached/computed values derived from it must be cleared. Verify derived-value producers (calculators, aggregators) invalidate their outputs when inputs disappear.

2.f.v. **Reconnection idempotence**: If the backend reconnects, all `VeQuickItem` UIDs re-resolve. Verify that code which registers callbacks or watchers on service appearance doesn't double-register on reconnect.

### 2.g. Lifecycle and resource management

2.g.i. **Parent-child ownership**: In C++, verify `QObject` parent-child relationships don't create double-free scenarios. In QML, verify that objects assigned to properties or stored in JS arrays don't outlive their expected scope.

2.g.ii. **Instantiator delegate lifecycle**: `Instantiator` delegates are created/destroyed as the model changes. Any external registration (worker registration, signal connections to singletons) made in `Component.onCompleted` must be undone in `Component.onDestruction`.

2.g.iii. **Loader content lifecycle**: `Loader.item` can be `null` when `active` is false or `source`/`sourceComponent` is empty. Verify all accesses guard against null.

2.g.iv. **Singleton initialization order**: QML singletons are created on first access. If singleton A's construction accesses singleton B, and B's construction accesses A, there's a circular dependency. Verify no such cycles exist.

2.g.v. **Self-disabling resources**: When a timer, worker loop, or periodic callback detects that its work is pointless (degenerate configuration, empty input set, invalid range), it should stop itself rather than continuing to fire and no-op. A timer that repeatedly does nothing is both a performance waste and a correctness smell — it indicates the system is in a state the designer didn't anticipate.

2.g.vi. **Resource cleanup on all exit paths**: If a function acquires a resource (starts a timer, registers a callback, allocates memory), verify that ALL exit paths — including early returns, error branches, and exceptions — release or account for that resource.

### 2.h. Enable/disable and reconfiguration cycles

2.h.i. **Disable must clear all side effects**: When a component is deactivated (`active = false`, timer stopped, config cleared), ALL outputs and registrations produced while active must be cleaned up. Stale values left in caches, models, or backend paths after deactivation are bugs.

2.h.ii. **Re-enable must fully reconstruct**: After disable → re-enable, the component must behave identically to fresh activation. Verify no state leaks from the previous activation (stale cached values, old timer IDs, leftover registrations).

2.h.iii. **Reconfiguration = invalidate old + apply new**: When a component's configuration changes while active (e.g., target prefix changes, service list changes), the old outputs must be invalidated BEFORE the new configuration is applied. Otherwise stale values from the old config remain visible alongside new values.

2.h.iv. **Reconfiguration while inactive**: If a property changes while the component is inactive, verify the change is noted but NOT acted upon (no config posted, no values written). The new config should only take effect on the next activation.

2.h.v. **Idempotent activation**: Calling `setActive(true)` when already active, or `setActive(false)` when already inactive, must be a no-op. Verify enable/disable paths are guarded by state checks and don't double-register or double-clear.

### 2.i. Numeric edge cases

2.i.i. **NaN propagation**: `qIsNaN()` / `isNaN()` checks must happen before any arithmetic or comparison. NaN compared with `<=`, `>=`, `<`, `>` always returns false. NaN in `qMin`/`qMax` propagates. Verify NaN doesn't silently produce wrong results.

2.i.ii. **NaN to int conversion**: `static_cast<int>(NaN)` is undefined behavior in C++. Always guard with `std::isnan()` before casting floating-point to integer.

2.i.iii. **Integer overflow/underflow**: Array indices, timer intervals, and counters derived from floating-point or external data may overflow `int`. Verify bounds or use appropriate types.

2.i.iv. **Division by zero**: Any division where the divisor comes from external data (VeQuickItem values, user input, computed results) must guard against zero.

2.i.v. **Floating-point equality**: `QVariant` comparison (`==`, `!=`) on floating-point values uses exact equality. Verify this is intentional (it usually is for cache-comparison, but can miss NaN since `NaN != NaN`).

2.i.vi. **Truncation surprises**: Casting `qreal` (double) to `int` truncates toward zero. A value of 0.9 becomes 0, not 1. If the intent is rounding up, use `std::ceil()`. Validate the floating-point value BEFORE casting — not after, when information is already lost.

### 2.j. Collection and container edge cases

2.j.i. **Empty collection access**: `first()`, `last()`, `at(0)` on empty `QList`/`QVector`/`QStringList` is undefined behavior. Verify emptiness checks before indexed access.

2.j.ii. **Iterator invalidation**: Inserting/removing from a `QHash`/`QMap` while iterating invalidates iterators. Verify loops that modify containers use safe patterns (iterate a copy, or collect keys first).

2.j.iii. **Index validity after mutation**: If an index into a container is stored (e.g., in a hash map for deduplication), verify the index remains valid after any operation that could resize or reorder the container.

2.j.iv. **Model index validity**: `QModelIndex` from one model operation may be invalid after the model is mutated. Verify indices aren't cached across model changes.

### 2.k. QML-specific correctness

2.k.i. **`parent` in nested QML objects**: Inside a `property var` declaration or a child of `QtObject`, `parent` refers to the visual parent — not the `QtObject`. Use explicit `id` references instead of `parent` when calling functions on a `QtObject`.

2.k.ii. **Binding loops**: A property binding that writes to itself (directly or transitively) causes a binding loop warning and undefined behavior. Verify new bindings don't create cycles.

2.k.iii. **Undefined vs null vs NaN**: In QML, `undefined` and `null` are distinct from `NaN`. `VeQuickItem.value` is `undefined` when not valid. Verify comparisons and arithmetic handle all three correctly (e.g., `isNaN(undefined)` is true in JS but `undefined === NaN` is false).

2.k.iv. **Dynamic `uid` changes**: Changing a `VeQuickItem.uid` at runtime triggers unsubscribe from old + subscribe to new. Verify no code assumes the value is immediately available after a uid change (it may be undefined until the new subscription resolves).

2.k.v. **Duplicate VeQuickItems**: Multiple `VeQuickItem` instances bound to the same uid create redundant subscriptions and backend traffic. Prefer reusing a single instance (via `id` reference or shared component) where possible.

2.k.vi. **Type coercion in comparisons**: JavaScript `==` performs type coercion. Prefer `===` unless coercion is intentional. Watch for `0 == ""` (true), `null == undefined` (true), `NaN == NaN` (false).

### 2.l. State machine and enum correctness

2.l.i. **Switch exhaustiveness**: When switching on an enum, verify all values are handled. Missing cases can silently fall through to default/no-op, hiding bugs.

2.l.ii. **Enum value assumptions**: Don't assume enum values are contiguous or start at 0. Use the actual enum constants, not arithmetic on raw integers.

2.l.iii. **State transition validity**: For state machines, verify that transitions only occur from valid source states. Verify that entering a state always sets up the expected invariants for that state.

### 2.m. Translation and i18n correctness

See [i18n/l10n](.github/i18n-l10n.md) for the full translation workflow. These items focus on what reviewers should catch.

2.m.i. **Translation markers on all user-visible strings**: Every string displayed to the user must use `qsTrId("id")` with a `//% "Source text"` comment. Bare string literals in `text:` properties, dialog titles, toast messages, and button labels are bugs. Exception: single characters like `"/"` or `":"` used as formatting separators.

2.m.ii. **No string concatenation for translatable text**: Never build user-visible strings with `+` operator (e.g., `CommonWords.ip_address + ' ' + (index + 1)`). Concatenated fragments cannot be reordered by translators and lose grammatical context. Use `.arg()` with a single `qsTrId()` string containing `%1`, `%2` placeholders instead.

2.m.iii. **CommonWords reuse**: If a string already exists in `components/CommonWords.qml`, use it rather than creating a duplicate `qsTrId()`. Check `CommonWords.qml` before adding new translation IDs for common terms (e.g., "Battery", "Grid", "OK", "Error").

2.m.iv. **Translation context comments**: For ambiguous strings (short words, technical terms, strings with placeholders), include a `//: context comment` above the `//% "Source text"` line. Translators see this comment in POEditor and need it to produce correct translations.

2.m.v. **Dynamic language change safety**: Translatable strings must be in declarative binding expressions, not imperative code. A `qsTrId()` call inside a `function` or `Component.onCompleted` handler won't update when the user changes language at runtime. Verify translations use property bindings (`text: qsTrId(...)`) so they re-evaluate automatically.

### 2.n. Key navigation completeness

See [Key Navigation](.github/key-navigation.md) for the full navigation system. These items focus on what reviewers should catch.

2.n.i. **Focus policy on interactive elements**: Every clickable, tappable, or otherwise interactive item must set `focusPolicy: Qt.TabFocus`. Without this, keyboard/button users cannot reach the element. Check new buttons, switches, list items, and custom controls.

2.n.ii. **Highlight opt-in**: Interactive items must set `KeyNavigationHighlight.active: activeFocus` so the global highlight rectangle appears when the item has focus. Without this, focused items are visually indistinguishable from unfocused ones.

2.n.iii. **Key handler guards**: Key event handlers (`Keys.onPressed`, `Keys.onReturnPressed`, etc.) should be guarded by `Keys.enabled: Global.keyNavigationEnabled` or an explicit `if (Global.keyNavigationEnabled)` check, to avoid processing key events when key navigation is inactive.

2.n.iv. **Inter-section navigation links**: When adding new major UI sections or rearranging existing ones, verify that `KeyNavigation.up` / `KeyNavigation.down` properties correctly chain focus between sections (StatusBar ↔ SwipeView/PageStack ↔ NavBar). Missing links create keyboard navigation dead-ends.

2.n.v. **List navigation integration**: Lists must use `BaseListView`, `SettingsColumn`, or `SettingsFlow` (or integrate `KeyNavigationListHelper`) to get Up/Down key navigation between items. Raw `ListView` does not provide correct key navigation behaviour in this codebase.

### 2.o. Portrait and landscape coverage

See [Layout Modes](.github/layout-modes.md) for the full layout system. These items focus on what reviewers should catch.

2.o.i. **Both orientations implemented**: Every page and major component must work in both landscape and portrait mode. For pages using the Loader pattern, verify both `_Landscape` and `_Portrait` component variants exist. A missing variant causes a blank page in that orientation.

2.o.ii. **All three screen sizes handled**: `Theme.screenSize` has three values: `FiveInch`, `SevenInch`, and `Portrait`. Conditionals that only test `=== Theme.Portrait` vs else (or vice versa) must produce correct results for all three. Verify that the FiveInch and SevenInch cases are both acceptable in the else branch.

2.o.iii. **Theme geometry usage**: Use `Theme.geometry_*` properties for all layout dimensions. These automatically adapt to the current screen size. Never hardcode pixel values that would only look correct in one orientation.

2.o.iv. **Landscape-only features in portrait**: Features that don't make sense in portrait (e.g., wide side panels) should hide with `visible: Theme.screenSize !== Theme.Portrait` or provide a portrait-appropriate alternative. They must not overflow, overlap, or break layout.

### 2.p. Access level gating consistency

See [Device Settings](.github/device-settings.md) for the access level system.

2.p.i. **Consistent gating across UI paths**: If a setting requires a specific access level, verify ALL UI paths that reach it apply the same check. A setting gated by `writeAccessLevel: VenusOS.User_AccessType_SuperUser` on one page but ungated on a different page is a bug.

2.p.ii. **writeAccessLevel propagation**: Settings delegates (e.g., `ListSwitch`, `ListSpinBox`) inherit `writeAccessLevel` from the page or parent. Verify that new settings pages pass the correct `writeAccessLevel` to their children, and that custom controls check `userHasWriteAccess` before allowing writes.

2.p.iii. **Visibility vs interactivity**: Some settings should be visible but read-only at lower access levels, while others should be hidden entirely. Verify the correct strategy is used: `writeAccessLevel` controls editability, while `allowed` or `preferredVisible` controls visibility. Using the wrong mechanism can leak information about unavailable features or silently prevent configuration.

### 2.q. Mock data synchronization

2.q.i. **Code paths match mock data**: When code constructs a D-Bus/VeQuickItem path, verify the path exists in the corresponding mock JSON file under `data/mock/conf/services/`. A path that works against real hardware but is missing from mock data will not be testable in mock mode or UI tests.

2.q.ii. **Mock data matches code paths**: When mock JSON files are modified (paths added, removed, renamed, or restructured), verify that all QML and C++ code constructing those paths is updated to match. Stale mock paths silently produce `undefined` values.

2.q.iii. **Mock value ranges**: Mock data should include representative edge-case values (zero, negative, maximum, NaN/null where applicable) so that UI tests exercise boundary conditions. If a new feature handles a range of values, verify the mock data covers that range — not just a single happy-path value.

### 2.r. Platform-specific correctness

2.r.i. **Conditional compilation completeness**: Every `#if defined(VENUS_WEBASSEMBLY_BUILD)` or `#ifdef Q_OS_LINUX` block should have a corresponding `#else` branch, or a comment explaining why the alternative is intentionally empty. Missing else branches silently skip initialization or cleanup on other platforms.

2.r.ii. **WASM-specific component loading**: Components that only exist for WASM (e.g., `WasmVirtualKeyboardHandler`) must be conditionally loaded. Verify they are not instantiated on non-WASM builds (where they may not exist or may behave incorrectly).

2.r.iii. **Feature degradation on WASM**: WASM cannot perform system-level I/O (file access, process spawning, D-Bus calls). Features using these capabilities must degrade gracefully on WASM — hide the UI element, show a "not available" message, or use an alternative implementation. They must not crash or show broken UI.

2.r.iv. **Platform-specific timer and threading behaviour**: Timer precision and thread scheduling differ across platforms (embedded Linux, desktop, WASM). Verify that timing-sensitive code does not depend on platform-specific behaviour (e.g., exact timer resolution, thread priority, or event loop timing).

### 2.s. API design and encapsulation

2.s.i. **Internal implementation leaked to callers**: If a public or `Q_INVOKABLE` method exposes an internal optimisation strategy (e.g., `invalidateCache()`, `rebuildLut()`), callers become coupled to the implementation. Verify whether the invalidation could instead be handled internally (e.g., by connecting to a `changed()` signal on the underlying data). If external invalidation is necessary, verify the method name describes the *intent* (e.g., `pathGeometryChanged()`) rather than the mechanism.

2.s.ii. **Property contract changes**: When a Q_PROPERTY changes from `MEMBER` to explicit `READ`/`WRITE`/`NOTIFY`, the notification semantics change (MEMBER auto-notifies on every write including same-value; explicit setter can guard). Verify no existing QML bindings depend on the old notification behaviour (e.g., relying on signal emission even when the value hasn't changed).

2.s.iii. **Method constness changes**: When a method changes from `const` to non-`const` (or vice versa), verify no callers hold the object through a const pointer/reference. In QML-facing code this is rare, but C++ unit tests or helper functions may be affected.

2.s.iv. **Ownership and lifetime ambiguity**: When a component accepts an externally-provided object via property (e.g., `property Item electronsParent`), the ownership boundary should be clear. Verify the component does not destroy, reparent, or retain the provided object beyond its own lifetime. Document who owns what.

---

## 3. Performance (medium priority)

### 3.a. GUI thread stalls

These cause visible frame drops or UI freezes. Highest performance priority.

3.a.i. **Blocking synchronous calls**: Never call blocking I/O (file reads, network requests, `QProcess::waitForFinished`, `QThread::wait`) on the GUI thread. Use async patterns or worker threads.

3.a.ii. **Mutex contention**: If a mutex is held by a worker thread during a long operation, and the GUI thread also acquires it (even briefly for a read), the GUI thread blocks. Prefer message-passing over shared-mutex architectures.

3.a.iii. **Synchronous DNS/network**: `QNetworkAccessManager` is async, but some codepaths (QML `XMLHttpRequest` with sync flag, manual socket operations) can block. Verify no synchronous network I/O occurs on the GUI thread.

3.a.iv. **Large JSON/XML parsing**: Parsing large JSON documents (`QJsonDocument::fromJson`) on the GUI thread can stall frames. For files >10KB, consider parsing on a worker thread.

3.a.v. **Sleep/busy-wait**: Never use `QThread::sleep`, `QThread::msleep`, busy-wait loops, or spin-locks on the GUI thread.

### 3.b. GUI thread execution pressure

These don't block but consume excessive CPU time on the GUI thread, causing frame budget overruns.

3.b.i. **Binding cascade avalanche**: A single value change that triggers dozens of downstream binding re-evaluations can consume the entire frame budget. Watch for wide fan-out from frequently-changing properties (e.g., a timer-driven value that feeds 50+ bindings).

3.b.ii. **O(n²) or worse in hot paths**: Operations triggered per-frame or per-value-change must be O(1) or O(log n). Linear scans of large collections in signal handlers, `onValueChanged`, or animation callbacks add up quickly.

3.b.iii. **JavaScript in binding expressions**: Complex JS in bindings (loops, object allocation, string concatenation) runs on every re-evaluation. Prefer C++ helpers or precomputed properties for hot-path bindings.

3.b.iv. **Frequent signal emission without change**: Emitting a signal when the value hasn't actually changed forces all connected slots/bindings to re-evaluate unnecessarily. Always guard signal emission with an equality check.

3.b.v. **Instantiator/Repeater with large models**: Creating hundreds of QML delegates simultaneously stalls the GUI thread. Use lazy loading, pagination, or `ListView` (which recycles delegates) instead of `Instantiator`/`Repeater` for large dynamic collections.

3.b.vi. **Timer granularity**: Timers firing faster than the frame rate (< 16ms) burn CPU without visible benefit. Verify timer intervals are appropriate for their purpose.

3.b.vii. **Redundant model updates**: Emitting `dataChanged` or resetting a model when no data actually changed forces views to re-render. Gate model signals on actual data differences.

### 3.c. Rendering performance

3.c.i. **Shape and Canvas usage**: `Shape`/`ShapePath` and `Canvas` items require CPU-side path tessellation on every geometry or property change. Prefer `Image`/`BorderImage` for static shapes. For dynamic shapes, minimize property changes.

3.c.ii. **Opacity and layer composition**: Setting `opacity` on an item with children forces layer composition (render to offscreen surface, then composite). Prefer `visible: false` to hide items instead of `opacity: 0`. If fading is needed, apply opacity only to leaf items.

3.c.iii. **Clip and masking**: `clip: true` on an `Item` enables scissor clipping, which is cheap. But `layer.enabled: true` (used for rounded clipping) forces texture rendering. Minimize layer usage.

3.c.iv. **Large texture uploads**: Loading large images or creating large offscreen textures stalls the render thread. Use `sourceSize` to constrain image decode size. Use `asynchronous: true` on `Image` for large files.

3.c.v. **Shader effects**: `ShaderEffect` and `ShaderEffectSource` force layer composition. Verify they're not applied to frequently-changing content or large item trees.

3.c.vi. **Animation frame cost**: Animations that change `x`/`y`/`width`/`height`/`scale`/`rotation` on items with many children force layout recalculation. Prefer animating `transform` properties or using `Translate`/`Scale`/`Rotation` transform types which don't trigger re-layout.

3.c.vii. **Font rendering**: Frequent changes to `Text.text` with different content lengths forces glyph cache updates and text layout recalculation. For rapidly updating numeric displays, consider fixed-width fonts or preformatted strings.

### 3.d. Memory pressure

3.d.i. **Unbounded cache/queue growth**: Any cache, queue, or history buffer that grows without bound (no eviction, no size cap) will eventually exhaust memory on resource-constrained GX devices (256MB–512MB RAM). Verify all collections have a maximum size or cleanup policy.

3.d.ii. **Retained object graphs**: QML objects referenced from JavaScript arrays, closures, or `property var` declarations prevent garbage collection. Verify dynamic objects are explicitly released when no longer needed.

3.d.iii. **Image cache exhaustion**: Qt's image cache is bounded but large decoded textures can still accumulate. Verify that pages/views which are not visible release or unload their image sources.

3.d.iv. **Model data duplication**: If a model stores the same data that's already in `VeQItem` tree nodes, that's doubled memory usage. Prefer referencing the tree directly where possible.

3.d.v. **Connection accumulation**: Each `connect()` call in C++ or `Connections {}` in QML that isn't eventually disconnected (via parent destruction or explicit disconnect) creates a retained closure. Verify connections in dynamic delegates are cleaned up on delegate destruction.

### 3.e. Optimization fidelity

These apply when a change introduces a performance optimisation that trades off exactness for speed.

3.e.i. **Approximation error bounds**: When an optimisation replaces exact computation with approximation (lookup tables, linear interpolation, reduced precision), quantify the maximum error. For visual output, verify the error is sub-pixel for the expected input ranges. For data output, verify the error is within acceptable tolerance for downstream consumers.

3.e.ii. **Performance claim validation**: Changes described as performance improvements should be accompanied by measured data (before/after timings, profiler output, or benchmark results). If the change adds a benchmark tool, verify the tool was used to measure the actual improvement. Unvalidated performance claims risk introducing complexity without proven benefit.

3.e.iii. **Steady-state vs transient cost**: Optimisations often shift cost from steady-state to transient events (e.g., cache rebuild on geometry change). Verify the transient cost is acceptable — if the cache is rebuilt every frame during a common interaction (transitions, scrolling), the optimisation may be counterproductive during those periods. Document which scenarios benefit and which fall back to unoptimised cost.

3.e.iv. **Cache invalidation completeness**: For any cache or precomputed data structure, enumerate ALL inputs that affect its validity. Verify that changes to EVERY input trigger invalidation. A cache that is correct 99% of the time but stale during a specific interaction (e.g., theme change, orientation switch, dynamic widget add/remove) is a bug. Add a comment near the cache listing its invalidation triggers.

3.e.v. **Hardcoded sizing and tunability**: Fixed-size caches and lookup tables (e.g., `LUT_SIZE = 512`) should be justified relative to the expected input range. Document why the chosen size is sufficient (e.g., "512 entries over a 400px path gives <1px maximum interpolation error"). Consider whether resource-constrained platforms need a different size.

---

## 4. Maintainability (lower priority)

### 4.a. Code clarity

4.a.i. **Function length**: Functions over 50 lines should be considered for extraction. Each function should do one thing at one level of abstraction.

4.a.ii. **Parameter count**: Functions with more than 4-5 parameters suggest the parameters should be grouped into a struct or that the function has too many responsibilities.

4.a.iii. **Magic numbers and strings**: Literal numbers and repeated string constants should be named constants or enums. Exception: 0, 1, -1, and obvious mathematical constants.

4.a.iv. **Naming precision**: Variable/function names should describe WHAT, not HOW. Prefer `maxPhaseIndex` over `idx`. Prefer `invalidateConsumptionValues` over `cleanup`.

4.a.v. **Dead code**: Unused functions, unreachable branches, commented-out code, and `#if 0` blocks add confusion. Remove them.

### 4.b. Code style

4.b.i. **Formatting**: Follow `victron.astyle` rules — 1TBS braces, tab indentation, 120 character line limit. Run astyle before committing C++ changes.

4.b.ii. **Include ordering**: System includes, then Qt includes, then project includes. Each group alphabetically sorted.

4.b.iii. **Const correctness**: Use `const` on local variables, parameters, and member functions wherever possible. Prefer `constexpr` for compile-time constants.

4.b.iv. **Auto usage**: Use `auto` when the type is obvious from the right-hand side (e.g., `auto it = map.find(key)`). Don't use `auto` when it obscures the type.

4.b.v. **License header**: Every new source file (`.cpp`, `.h`, `.qml`) must include the standard Victron copyright header at the top: `/*\n** Copyright (C) <year> Victron Energy B.V.\n** See LICENSE.txt for license information.\n*/`. Use the current year for new files. Do not omit the header or substitute a different license.

### 4.c. Documentation

4.c.i. **Public API documentation**: Public C++ methods exposed to QML should have brief doc comments explaining purpose, preconditions, and thread-safety requirements.

4.c.ii. **Non-obvious logic**: Complex algorithms, workarounds for Qt bugs, and platform-specific code should have comments explaining WHY, not WHAT.

4.c.iii. **Architecture decisions**: If a design choice isn't obvious (e.g., "why is this on a worker thread?"), document the reasoning near the code or in the relevant topic guide under `.github/`.

### 4.d. Test coverage

4.d.i. **New algorithmic code**: Non-trivial algorithms (interpolation, coordinate transforms, state machines, parsers) introduced or modified by a change should have corresponding unit tests. If the logic has edge cases (boundary values, wrap-around, empty inputs), verify they are tested.

4.d.ii. **Regression test adequacy**: When modifying behaviour that is covered by existing visual regression or integration tests, verify those tests still exercise the modified code path. A test that passes vacuously (because it no longer hits the changed path) is false confidence.

4.d.iii. **Testability of new components**: New C++ classes and QML components should be structured so they can be tested in isolation (dependency injection, mockable interfaces). If a component can only be exercised by running the full application, note the gap.

### 4.e. Observability and debuggability

4.e.i. **Diagnostic hooks for new subsystems**: When introducing internal caches, lookup tables, or optimisation layers, consider how a developer would diagnose incorrect behaviour at runtime. At minimum, a debug-level log on cache rebuild or invalidation helps trace timing-related bugs. Avoid making internal state entirely opaque with no way to inspect it.

4.e.ii. **Failure mode visibility**: When a function fails silently (early return, no-op on invalid input), verify this is appropriate. A `qmlDebug` message for a situation that indicates a bug (not just a transient state) should be `qmlWarning` so it appears in normal test output. Reserve `qmlDebug` for expected/informational messages.

### 4.f. Build system and tooling

4.f.i. **CMake/build file correctness**: When adding files to cmake source lists, verify: alphabetical ordering is maintained within the list, the file is in the correct target/module, and existing test/build targets still pass without modification.

4.f.ii. **Script portability and standards**: New scripts (Python, shell) should: specify minimum language version requirements, handle platform differences (path separators, process signals, encoding), and include error handling for common failure modes (missing dependencies, file not found, process crash). Scripts committed to the repository should have a license/copyright header consistent with other source files.

4.f.iii. **Script input validation**: Scripts that accept file paths, executable paths, or user-provided arguments should validate inputs before use. Paths should be checked for existence, numeric arguments should be range-checked, and arguments passed to subprocess calls should not introduce injection vulnerabilities if the script is ever used in automated pipelines.

### 4.g. Security

4.g.i. **Subprocess argument handling**: Scripts or code that constructs command lines from external input (user arguments, environment variables, file contents) must avoid shell injection. Prefer array-form subprocess invocation over shell string interpolation. Verify that user-controlled values cannot break out of their intended argument position.

4.g.ii. **Temporary file handling**: Temporary files containing application output, logs, or intermediate data should be created with restrictive permissions, in platform-appropriate temporary directories, and cleaned up in all exit paths (including exceptions and signals). Verify no sensitive data persists in temp files after the tool completes.
