# Key navigation

**All UI features must support keyboard navigation.** Key navigation is a first-class requirement — it allows operation of the UI via physical buttons on GX devices (Ekrano GX) and via keyboard on desktop/WASM.

## How key navigation works

1. **Global toggle**: `Global.keyNavigationEnabled` controls whether key navigation is active. It is enabled when a navigation key is pressed and disabled after an idle timeout.

2. **Focus highlight**: A single `GlobalKeyNavigationHighlight` (BorderImage) auto-reparents itself to the current `Window.activeFocusItem`. It only appears when `Global.keyNavigationEnabled` is true and the item has opted in via `KeyNavigationHighlight.active`.

3. **Focus eligibility**: `Utils.acceptsKeyNavigation(item)` checks `item.focusPolicy & Qt.TabFocus && item.enabled`. Items that should be navigable must set `focusPolicy: Qt.TabFocus`.

4. **List navigation**: `BaseListView` (extends ListView) integrates `KeyNavigationListHelper` which provides Up/Down (or Left/Right for horizontal) navigation between list items. The built-in ListView key navigation is disabled; all navigation flows through the helper.

5. **Inter-section navigation**: `KeyNavigation.up` / `KeyNavigation.down` properties connect navigation between major sections (StatusBar ↔ SwipeView/PageStack ↔ NavBar).

## Key navigation components

| Component | Role |
|-----------|------|
| `GlobalKeyNavigationHighlight` | Singleton highlight rectangle that follows active focus |
| `KeyNavigationHighlight` (attached) | Opt-in attached object for items to attract the highlight |
| `KeyNavigationHighlightHelper` (C++) | Tracks activeFocusItem, computes margins/fill target |
| `KeyNavigationListHelper` | Manages sequential focus traversal in lists |
| `KeyEventFilter` (C++) | Window-level event filter that intercepts keys during idle/inactive states |

## Writing key-navigable components

```qml
// A focusable item (minimum requirements):
Item {
    focusPolicy: Qt.TabFocus
    KeyNavigationHighlight.active: activeFocus
    Keys.enabled: Global.keyNavigationEnabled
}

// A list that supports key navigation (use BaseListView):
BaseListView {
    model: myModel
    delegate: ListItem {
        // ListItem already sets focusPolicy, KeyNavigationHighlight, etc.
    }
}

// For non-list containers, try to use a SettingsColumn or SettingsFlow
// within which your layout will be laid out, as these handle key navigation
// nicely.  Otherwise, if you truly have a case which is not supported by
// the current containers, (e.g. a custom grid with unique spanning cells),
// you can define and expose a custom __keyNavHelper as a last resort:
FocusScope {
    readonly property KeyNavigationListHelper __keyNavHelper: keyNavHelper
    KeyNavigationListHelper {
        id: keyNavHelper
        itemCount: repeater.count
        itemAtIndex: (i) => repeater.itemAt(i)
    }
}
```

## Navigation flow between major sections

```
StatusBar
    ↕ KeyNavigation.down/up
Cards (if open) / PageStack (if open) / SwipeView
    ↕ KeyNavigation.down/up
NavBar
```

The Overview page implements custom widget-to-widget navigation that follows connector lines (energy flow paths) rather than simple grid order.

## Key navigation rules for new code

- Every interactive element must be reachable via keyboard navigation
- Set `focusPolicy: Qt.TabFocus` on navigable items
- Use `KeyNavigationHighlight.active: activeFocus` to show the focus indicator
- Guard key handlers with `Keys.enabled: Global.keyNavigationEnabled`
- For lists, use `BaseListView`, `SettingsColumn`, or `SettingsFlow` which provide navigation automatically
- For custom containers, implement a `__keyNavHelper` property
- Ensure `KeyNavigation.up`/`down` connects your component to adjacent navigable areas
- The Overview page's `OverviewWidget` has `acceptsKeyNavigation()` — use this pattern for widgets with conditional visibility

## Key bindings in MainView

| Key | Action |
|-----|--------|
| Arrow keys | Navigate between focusable items |
| Enter/Return | Activate current item; return to last stack page from main page |
| Escape | Dismiss toast notification, close cards pane, or cycle to next main page |
| Back/Left | Pop page from PageStack |

The idle timeout (`Theme.animation_page_idleResize_timeout`) disables key navigation highlight and enters idle mode. Any key press re-enables navigation.

## Attached property reference

`KeyNavigationHighlight` is an attached object (C++ class in `src/keynavigationhighlight.h`):

```qml
Item {
    // Required: opt in to showing the highlight
    KeyNavigationHighlight.active: activeFocus

    // Optional: custom margins around the highlight border image
    KeyNavigationHighlight.margins: -4          // expand highlight by 4px all around
    KeyNavigationHighlight.leftMargin: 10       // individual margin overrides
    KeyNavigationHighlight.topMargin: 5

    // Optional: show highlight on a different item than the focused one
    KeyNavigationHighlight.fill: alternativeItem
}
```

Only items with `KeyNavigationHighlight.active: true` will attract the global highlight. If `fill` is specified, the highlight reparents to that item instead of the attachee.
