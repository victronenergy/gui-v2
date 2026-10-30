# Branding plugins

A branding plugin lets an OEM change the GUI's colors, fonts, and start-up logos, without changing gui-v2. It is a gui-v2 plugin whose integration is one file, `Branding.qml`, which declares a `Branding` object from the `Victron.Branding` module.

This document is for OEM developers, and for AI agents that write or check a branding plugin for an OEM. It is complete on its own: you do not need to read gui-v2's internals. Two example plugins show the rules in practice:

- `examples/BrandingMinimalExample`: the smallest branding plugin, one color.
- `examples/BrandingExample`: backgrounds, a warning color, a slightly darker success green, the Light scheme's background factor, both logos, and the start-up gauge animation. Its README says what the result looks like on a device.

## What branding changes, and what it does not

Branding changes:

- the brand color (buttons, switches, sliders, the selected navigation bar tab, and other controls);
- the info, success, warning, and critical colors;
- the backgrounds and the text colors;
- the font, and the font for quantities;
- the icon and the wordmark on the start-up screen.

Branding does not change:

- the colors that show data, such as tank fluid colors and temperature gauges;
- the faint Victron blue in the tails of the moving dots ("electrons") on the Overview page;
- the screenshots on the welcome screens;
- sizes, layout, or text;
- the HTML page that loads the remote console in a web browser. In the remote console, the branding is applied when the plugin data arrives, so the start-up screen can show Victron's look until then.

## Quick start

1. Make a directory named after your plugin, for example `OemName`. The compiler names the plugin after the directory.
2. Write `OemName/Branding.qml`, following the rules below. Start from one of the examples.
3. Compile it, from that directory:

   ```
   python3 <gui-v2>/tools/gui-v2-plugin-compiler.py --branding Branding.qml
   ```

   On a GX device with the Large image, the compiler is `/opt/victronenergy/gui-v2/gui-v2-plugin-compiler.py`.
4. Fix every problem the compiler reports, and compile again, until it succeeds. It writes `OemName.json`.
5. Install it on a GX device by adding `--install root@<gx-host>` to the compile command, or by hand: copy `OemName.json` to `/data/apps/available/OemName/gui-v2/`, then `ln -s /data/apps/available/OemName /data/apps/enabled/OemName`.
6. Look at the device. The colors change straight away. The start-up logos and gauge animation show only when the GUI starts: restart it with `svc -d /service/start-gui && svc -u /service/start-gui`. Switch Settings -> General -> Display & Appearance -> GX display appearance between Dark and Light, and check both.

To remove the branding, remove the link: `rm /data/apps/enabled/OemName`.

A plugin can have a branding integration and other integrations, such as a settings page. Compile it with `--branding Branding.qml` and the other options together.

## Rules for Branding.qml

The GUI reads each value once, when the plugin loads, and then destroys the object. A value may be an expression. It runs once, at that moment. It does not follow other values when they change. An expression can use only what the allowed imports provide, such as `Qt.rgba()` or `Qt.resolvedUrl()`. It cannot use `Victron.VenusOS`.

Do not start other objects, load scripts, or do I/O from this file. The compiler rejects a file that contains any of these names:

`XMLHttpRequest`, `WebSocket`, `LocalStorage`, `createQmlObject`, `createObject`, `createComponent`, `WorkerScript`, `openUrlExternally`, `setContextProperty`, `Qt.include`, `Qt.quit`, `Qt.exit`.

Text in a comment does not count. A name inside a string does count. `//` hides the rest of its line, and `/*` hides through the next `*/`, even inside a string. This is a text search for a few obvious cases, not a complete check and not a QML parser. If the file does something else when it loads, that is not supported. The GUI may misbehave, and that is not a bug in gui-v2.

The compiler enforces the import rule and that name search. It does not check property values. It reports each problem as `file:line:column: message`.

1. **Imports.** `import Victron.Branding` is required. `import QtQml` and `import QtQuick` are allowed but not needed. Nothing else is allowed, not even `Victron.VenusOS`. No `as` qualifier, no import of a file or directory, and no `pragma`.
2. **The root object is `Branding`.** The GUI ignores the branding integration if the file does not declare one. Set the properties in the [property reference](#property-reference).
3. **Write each property on its own line**, as `name: value`, with nothing before the name except spaces or tabs. The examples indent with tabs; that counts. The compiler reads those lines to write `requiredBrandingVersion` (see [Versioning](#versioning)). A property set in any other way is not counted. If that property is newer than the version the compiler wrote, an older GUI fails to load the file, instead of logging that the plugin needs a newer `Victron.Branding`.
4. **Values the GUI accepts.** The compiler does not check these. The GUI does, when it loads the plugin.
   - Colors must be opaque. Write `"#RGB"`, `"#RRGGBB"`, or an SVG color name such as `"orange"`. The GUI ignores, and logs, a color that is not opaque, including `"transparent"`. QML's 8-digit form is `#AARRGGBB`, with the alpha first; CSS's `#RRGGBBAA` is not the same color.
   - File paths are relative to `Branding.qml`. Write `"logo.svg"`, not a `qrc:` or `file:` URL, not a leading `/`, and not `..`. Logos are `.svg` or `.png`. Font files are `.ttf` or `.otf`. Gauge animations are `.gif`. With `--branding`, the compiler packs every such file in the plugin directory and its subdirectories. It does not read the paths out of the file, so a file that is not in that directory is not packed.
   - `font_family` and `quantity_font_family` must name a family that `font_files` in this same file registers. If not, the GUI ignores this plugin's branding and logs why. The plugin's other integrations still load.
   - `light_mode_background_factor` must be more than 0 and at most 2. The GUI ignores a value outside that range, and logs it.
5. **Do not touch gui-v2's own files.** Do not edit gui-v2's theme JSON files, and do not copy files over gui-v2's images. Branding is only what `Branding.qml` sets.

The GUI ignores, and logs, a `Branding.qml` that does not load. It also logs a warning if `Branding.qml` imports any other module.

## Colors

- **One set of colors, for the Dark scheme.** The `color_` properties are the Dark scheme's colors. The GUI computes the Light scheme from them. There are no Light-only properties.
- **The brand, info, success, warning, and critical colors are the same in both schemes.** Choose colors that work on both the Dark and the Light background.
- **The Light backgrounds** are the Dark backgrounds with their lightness inverted, keeping their hue. `light_mode_background_factor` adjusts this: 1.0 is the plain inversion, a lower value makes the Light backgrounds grayer (`BrandingExample` uses 0.45 for mid gray), and a higher value spreads them apart.
- **Set the backgrounds together.** The background factor, `color_background_secondary`, and `color_background_page` are chosen to suit one `color_background_primary`. They are read only from the plugin whose `color_background_primary` is used (or, for the two colors, from a later plugin; see [Several branding plugins](#several-branding-plugins)). If that plugin does not set them, the factor is 1.0 and the two colors are computed from `color_background_primary`, not taken from Victron.
- **Text.** The Light scheme's text colors are computed from the Dark ones for contrast. `color_font_primary` on `color_background_primary` should have a contrast ratio of at least 4.5:1, or the GUI logs a warning. `color_font_secondary` is made darker or lighter, in each scheme, until it has at least 3:1 on the backgrounds.
- **Text on colored fills**, such as a label on a brand-colored button, is chosen automatically: white if white has at least 3:1 contrast on every fill the text is drawn on, otherwise a dark text color. If that dark color is still under 3:1, it is darkened toward black until it is not. A toast is drawn on both its dimmed background and its status strip, and an animated accept button on both its resting fill and its sliding fill, so a light status color can force dark text.
- **Overview battery gauge.** The readings are drawn on both the filled part and the unfilled part. If those two are too close in brightness for one text color, the fill is made darker or lighter until the readings can be read on both. A white brand does not leave that fill white.
- **The selected Off side of a switch** uses the label chosen for the full brand color. If that label cannot be read on the dimmed brand fill, the fill is made darker or lighter until it can.
- **Keep success, warning, and critical distinct from the brand, and from each other.** Nothing checks this. If your brand color is orange or red, change `color_warning` or `color_critical` so that a warning does not look like a brand-colored button. `color_info` may be the brand color. `BrandingExample` sets `color_info` to its orange brand, and uses an amber warning so a warning does not look like a brand-colored button.
- **The key navigation focus ring** (shown when using keys or buttons, not touch) is drawn in the success color in the Dark scheme, and in the warning color in the Light scheme.
- **Check the result in both schemes.** Nothing checks that a brand or status color stands out from the background. For example, a mid orange brand on a mid gray Light background is hard to see as a fill. The `BrandingExample` README lists the weak spots that this example has on purpose.

## Logos

- The start-up screen draws the icon and the wordmark on top of each other, both stretched to the same box. Victron's two images share a 285x54 canvas, with the icon at the left and the wordmark to its right, and transparency elsewhere. Draw yours on a 285x54 canvas, in the same places. Other sizes are stretched.
- Set both `splash_logo_icon` and `splash_logo_text`. If you set only the icon, Victron's wordmark is still shown next to it.
- By default, each logo is drawn in one color, the scheme's main text color: white in Dark, dark gray in Light. Set `splash_logo_icon_preserve_colors` or `splash_logo_text_preserve_colors` to `true` to draw that logo in its own colors. One file serves both schemes, so a logo in its own colors must read on both the Dark and the Light background (`BrandingExample`'s icon has a dark outline for this).
- In SVG files, draw text as paths, not as SVG text: the device may not have the font.

## Gauge animation

- `splash_gauge_animation` replaces the start-up gauge animation in both schemes. Set `splash_gauge_animation_light` as well to use a different file in the Light scheme only. If neither is set, Victron's animation is used. If only the light file is set, the Dark scheme keeps Victron's animation.
- One file is used on both the 5" and 7" screens, at the file's own size. It is not stretched. Victron's animations are 368×368 (5") and 464×464 (7").
- A plugin animation is played to its last frame. Victron's own animation still pauses at a fixed frame.
- If the file does not load, the start-up screen continues without waiting for it. The plugin does not replace the splash screen itself, only that animation.

## Fonts

- List the font files in `font_files`, and name the family in `font_family`, the font for all text except quantities, and `quantity_font_family`, the font for numbers with their units.
- The family must be one that a font file in this same file registers. Do not name a family that another plugin's file provides, or a font that is only installed on the device. If you do, the GUI ignores this plugin's branding and logs why. The plugin's other integrations still load.
- The font must have the letters of every language your product ships. For a language it does not have the letters for, the GUI uses its built-in font (Roboto) instead, and logs it. Languages that have their own font on the device, such as Chinese, Japanese, Arabic, and Thai, always keep it.
- The quantity font is used for every language, and needs digits of equal width (tabular digits), or values jitter as they change.

For example:

```qml
import Victron.Branding

Branding {
	font_files: [ "OemSans-Regular.ttf", "OemSans-Medium.ttf" ]
	font_family: "OemSans"
	quantity_font_family: "OemSans"
}
```

## Several branding plugins

More than one installed plugin can have a branding integration. The GUI sorts them by plugin name, and for each property uses the value from the last plugin that sets it. A property that no plugin sets keeps Victron's value. The exceptions are the background factor, `color_background_secondary` and `color_background_page`, which follow `color_background_primary` as described in [Colors](#colors). A font family is not shared that way: the plugin that names it must also list the font file. Another plugin's file does not count.

## Checking your work

This is the loop to follow, by hand or as an agent:

1. Run the compiler with `--branding Branding.qml`. It checks the imports, and rejects a file that contains one of the names in [Rules for Branding.qml](#rules-for-brandingqml). It does not check property values. Each problem is `file:line:column: message`. For example:

   ```
   Branding.qml:2:1: importing Victron.VenusOS is not allowed. A Branding file may import only Victron.Branding, QtQml, QtQuick.
   ```

2. Fix every reported problem, and run the compiler again, until it passes.
3. The compiler then runs `qmllint` on the file, if it can find `qmllint` and the `Victron.Branding` module. On a GX device it cannot, and says that it skipped it. Fix anything `qmllint` reports.
4. Install the plugin with `--install root@<gx-host>`, and look at the device in both the Dark and the Light scheme: the start-up screen, the Overview page, a settings page with switches and buttons, and the notifications.
5. Check the GUI's log for warnings that name your plugin.
6. To compare your plugin with the Victron colors on a desktop build, capture the same pages with and without it, as described in [Capturing with a branding plugin](visual-regression-tests.md#capturing-with-a-branding-plugin).

## Versioning

`Victron.Branding` has its own version, `major.minor`, separate from gui-v2's version and from the other plugin modules.

- **Minor versions add properties.** The property reference says which version added each property ("Added in").
- **The required version.** The compiler writes `requiredBrandingVersion` into the plugin's JSON file: the lowest `Victron.Branding` version that has every property it can see. It sees a property only when that property is written on its own line, as `name: value`, with nothing before the name except spaces or tabs. A plugin that sets only properties from 1.0 needs 1.0, even if the compiler was built for a newer version, so it still runs on older GX devices. A property set in any other way is not counted. If that property is newer than the version written here, an older GUI fails to load the file, instead of logging the version it needs.
- **What the GUI does with it.** If the GUI's `Victron.Branding` has a different major version, or an older minor version, than `requiredBrandingVersion`, the GUI ignores the plugin's branding integration and logs why, for example `Ignoring the branding integration in plugin OemName - it needs Victron.Branding 1.2, but this GUI only has 1.1`. The plugin's other integrations still load. A plugin without `requiredBrandingVersion` is not checked.
- **Deprecation.** A property that is to be removed is first marked as deprecated in the property reference, and from then on the GUI logs a warning, once, when a plugin sets it. It is removed only in the next major version. No property is deprecated yet.
- **Major versions** remove or change properties. When a new major version is announced, plugin authors must port their plugins to the new API.

## Changing Victron.Branding (gui-v2 contributors)

- The `Branding` type is `src/branding/branding.h`. The module depends only on Qt: it must not include, import, or link any other Victron module.
- The module version is set in `cmake/ModuleBranding.cmake`.
- To add a property: declare it in `branding.h`, on one line, with `REVISION(major, minor)` set to the new version, and add its entry to the property reference in `src/branding/branding.cpp` (what it sets, then `If not set:`); raise the minor version in `cmake/ModuleBranding.cmake`; then run `python3 tools/brandingproperties.py`. That regenerates `tools/branding-properties.json`, which the compiler uses, and the property reference below. The `tst_brandingproperties` test fails if either is out of date.
- `tools/branding-properties.json` is also the checked-in record of the `Victron.Branding` API: plugins can only set properties, so the property names, types and versions are the whole API. `tools/brandingproperties.py` refuses to remove a property from it, or to change a property's type or version, unless the major version has gone up. It also refuses a new property whose `REVISION` is not the current module version. Only for a property that no released GUI has, `--allow-breaking-changes` lets you remove or change it.
- Once a gui-v2 release tag (`vX.Y.Z`) contains that file, the same script reads the latest such tag merged into HEAD. A property that tag does not have must belong to a newer module version than the one in the tag: raise the minor version and set `REVISION` to it. Until the first release that includes `Victron.Branding`, there is no released list to compare with, so properties added before that release stay at 1.0. The check needs those tags; a shallow clone fails it instead of skipping it. `--allow-breaking-changes` does not bypass it.
- Removing or changing a property needs a new major version. See [Versioning](#versioning).

## Property reference

The properties of `Branding`. "If not set" says what is used when no installed branding plugin sets the property. "Victron's value" is Victron's own color in the Dark scheme.

<!-- BEGIN property reference. tools/brandingproperties.py writes this part from src/branding/branding.cpp: edit the property reference there, not this text. -->

### `color_brand`

The brand color: buttons, switches, sliders, radio buttons, the selected navigation bar tab, and the Overview widget borders. The battery gauge fill, and the selected Off side of a switch, are based on it and may be darkened or lightened so their text stays readable. It is not used for informative notifications. The Light scheme uses the same color.

- Type: color
- Added in: 1.0
- If not set: Victron's color.
- Victron's value: `#387DC5`

### `color_success`

Good states, such as feed-in power, and the key navigation focus ring in the Dark scheme. The Light scheme uses the same color.

- Type: color
- Added in: 1.0
- If not set: Victron's color.
- Victron's value: `#72B84C`

### `color_warning`

Warnings, modified settings, the demo mode indicator, and the key navigation focus ring in the Light scheme. The Light scheme uses the same color.

- Type: color
- Added in: 1.0
- If not set: Victron's color.
- Victron's value: `#F0962E`

### `color_critical`

Errors and alarms. The Light scheme uses the same color.

- Type: color
- Added in: 1.0
- If not set: Victron's color.
- Victron's value: `#F35C58`

### `color_info`

Informative notifications, and quantities that are not a success, a warning or an alarm, such as load below the warning line and power being imported. It may be the brand color. Keep it distinct from color_success, color_warning and color_critical. The Light scheme uses the same color.

- Type: color
- Added in: 1.0
- If not set: Victron's color.
- Victron's value: `#387DC5`

### `color_background_primary`

The main background in the Dark scheme. The Light scheme's background is computed from it, using light_mode_background_factor. The Branding file whose color_background_primary is used also supplies the background factor, and limits where color_background_secondary and color_background_page are read from, so set them in the same file.

- Type: color
- Added in: 1.0
- If not set: Victron's color.
- Victron's value: `#000000`

### `color_background_secondary`

The background of cards and list items in the Dark scheme. The Light scheme's is computed from it. Read only from the Branding file whose color_background_primary is used, or a later one.

- Type: color
- Added in: 1.0
- If not set: computed from color_background_primary, mixed 8% toward color_font_primary. Victron's color is used only when no Branding file sets color_background_primary.
- Victron's value: `#141414`

### `color_background_page`

The page background behind the cards, in the Dark scheme only: the Light scheme's page is always its background mixed 12% toward its text color. Read only from the Branding file whose color_background_primary is used, or a later one.

- Type: color
- Added in: 1.0
- If not set: color_background_primary.

### `color_font_primary`

The main text and icons in the Dark scheme. The Light scheme's text color is computed from it. The loader warns when it has less than 4.5:1 contrast on color_background_primary in either scheme.

- Type: color
- Added in: 1.0
- If not set: Victron's color.
- Victron's value: `#FFFFFF`

### `color_font_secondary`

Secondary text, such as list item values and the unselected navigation bar tabs, in the Dark scheme. In each scheme, if it has less than 3:1 contrast on the page or on the card background, it is moved toward the scheme's main text color until it has.

- Type: color
- Added in: 1.0
- If not set: Victron's color.
- Victron's value: `#969591`

### `light_mode_background_factor`

How the Light scheme's backgrounds are computed from the Dark scheme's: 1.0 inverts their lightness, a lower value moves them toward mid gray, and a higher value spreads them apart. More than 0 and at most 2. Read only from the Branding file whose color_background_primary is used, so set the two together.

- Type: number
- Added in: 1.0
- If not set: 1.0. Victron's own backgrounds use 1.12, so a plugin that sets no color_background_primary keeps that.

### `font_files`

Font files (.ttf or .otf) to register, relative to Branding.qml. font_family and quantity_font_family in this file must name a family that one of these files registers.

- Type: list of strings
- Added in: 1.0
- If not set: no font files are registered.

### `font_family`

The family name of the font for all text except quantities. It must be a family that font_files in this same file registers. A family from another plugin, or a font that is only installed on the device, is not used: the GUI ignores this plugin's branding. It is used only for languages it has the letters for; the others, and languages that have their own font (such as Chinese), use the built-in font.

- Type: string
- Added in: 1.0
- If not set: the built-in font, Roboto, or the language's own font.

### `quantity_font_family`

The family name of the font for quantities: numbers with their units. It must be a family that font_files in this same file registers. A family from another plugin, or a font that is only installed on the device, is not used: the GUI ignores this plugin's branding. It needs digits of equal width, or changing values jitter. It is used for every language.

- Type: string
- Added in: 1.0
- If not set: Roboto.

### `splash_logo_icon`

The icon on the start-up screen: an .svg or .png file, relative to Branding.qml. It is drawn over splash_logo_text, both stretched to the same box, so draw it on a 285x54 canvas, at the left.

- Type: url (a file path)
- Added in: 1.0
- If not set: Victron's icon.

### `splash_logo_text`

The wordmark on the start-up screen: an .svg or .png file, relative to Branding.qml. Draw it on a 285x54 canvas, to the right of the icon. Draw text as paths, not as SVG text.

- Type: url (a file path)
- Added in: 1.0
- If not set: Victron's wordmark.

### `splash_logo_icon_preserve_colors`

true: draw splash_logo_icon in its own colors, which must then read on both the Dark and the Light background. false: draw it in one color, the scheme's main text color.

- Type: bool
- Added in: 1.0
- If not set: false.

### `splash_logo_text_preserve_colors`

true: draw splash_logo_text in its own colors, which must then read on both the Dark and the Light background. false: draw it in one color, the scheme's main text color.

- Type: bool
- Added in: 1.0
- If not set: false.

### `splash_gauge_animation`

The gauge animation on the start-up screen: a .gif file, relative to Branding.qml. It is drawn at its own size on both the 5" and 7" screens, and played to its last frame. It is used in both schemes, unless splash_gauge_animation_light is set.

- Type: url (a file path)
- Added in: 1.0
- If not set: Victron's animation. The Light scheme still uses splash_gauge_animation_light if that is set.

### `splash_gauge_animation_light`

The gauge animation on the start-up screen in the Light scheme, instead of splash_gauge_animation: a .gif file, relative to Branding.qml. It is drawn at its own size on both the 5" and 7" screens, and played to its last frame.

- Type: url (a file path)
- Added in: 1.0
- If not set: splash_gauge_animation, or Victron's animation if that is not set either.

<!-- END property reference -->
