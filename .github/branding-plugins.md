# Branding plugins

A branding plugin lets an OEM change the GUI's colors, fonts, and start-up logos, without changing gui-v2. It is a gui-v2 plugin whose integration is one file, `Branding.qml`, which declares a `Branding` object from the `Victron.Branding` module.

This document is for OEM developers, and for AI agents that write or check a branding plugin for an OEM. It is complete on its own: you do not need to read gui-v2's internals. Two example plugins show the rules in practice:

- `examples/BrandingMinimalExample`: the smallest branding plugin, one color.
- `examples/BrandingExample`: backgrounds, a warning color, the Light scheme's background factor, and both logos. Its README says what the result looks like on a device.

## What branding changes, and what it does not

Branding changes:

- the brand color (buttons, switches, sliders, the selected navigation bar tab, and other highlights);
- the success, warning, and critical colors;
- the backgrounds and the text colors;
- the font, and the font for quantities;
- the icon and the wordmark on the start-up screen.

Branding does not change:

- the colors that show data, such as tank fluid colors and temperature gauges;
- the faint Victron blue in the tails of the moving dots ("electrons") on the Overview page;
- the intro animations and the screenshots on the welcome screens;
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
6. Look at the device. The colors change straight away. The start-up logos show only when the GUI starts: restart it with `svc -d /service/start-gui && svc -u /service/start-gui`. Switch Settings -> General -> Display & Appearance -> GX display appearance between Dark and Light, and check both.

To remove the branding, remove the link: `rm /data/apps/enabled/OemName`.

A plugin can have a branding integration and other integrations, such as a settings page. Compile it with `--branding Branding.qml` and the other options together.

## Rules for Branding.qml

The compiler enforces rules 1 to 4, and stops with an error for each problem it finds. A Branding file is a list of values: it cannot run code, and it cannot follow other values when they change.

1. **Imports.** `import Victron.Branding` is required. `import QtQml` and `import QtQuick` are allowed but not needed. Nothing else is allowed, not even `Victron.VenusOS`. No `as` qualifier, and no `pragma`.
2. **Only literal values.** Each property is set to a value written out in full: a quoted string, `true` or `false`, a number (only for `light_mode_background_factor`), or a list of quoted strings (only for `font_files`). No `Qt.resolvedUrl()`, no `Qt.rgba()`, no `Theme`, no other property's name, no `+`, no `? :`, no function calls. Each property is set at most once.
3. **Only Branding's properties.** The root object is `Branding`. It has only the properties in the [property reference](#property-reference), no `id`, no children, no new properties, no signal handlers, and no `Component.onCompleted`.
4. **Values.**
   - Colors are `"#RGB"`, `"#RRGGBB"`, or an SVG color name such as `"orange"`, and must be opaque. `"transparent"` is not allowed. QML's 8-digit form is `#AARRGGBB`, with the alpha first; CSS's `#RRGGBBAA` is not the same color, so `"#003366CC"` is rejected.
   - File paths are relative to `Branding.qml`: no `qrc:`, `file:` or other scheme, no leading `/`, and no `..`. The file must exist, and the compiler packs it into the plugin. Logos are `.svg` or `.png`. Font files are `.ttf` or `.otf`.
   - `font_family` and `quantity_font_family` are not empty.
   - `light_mode_background_factor` is more than 0 and at most 2.
5. **Do not touch gui-v2's own files.** Do not edit gui-v2's theme JSON files, and do not copy files over gui-v2's images. Branding is only what `Branding.qml` sets.

The GUI checks some of these again when it loads the plugin, because a plugin may not have gone through the compiler. It ignores, and logs, a color that is not opaque, a background factor out of range, a font family that is not installed, and a `Branding.qml` that does not load. It also logs a warning if `Branding.qml` imports any other module.

## Colors

- **One set of colors, for the Dark scheme.** The `color_` properties are the Dark scheme's colors. The GUI computes the Light scheme from them. There are no Light-only properties.
- **The brand, success, warning, and critical colors are the same in both schemes.** Choose colors that work on both the Dark and the Light background.
- **The Light backgrounds** are the Dark backgrounds with their lightness inverted, keeping their hue. `light_mode_background_factor` adjusts this: 1.0 is the plain inversion, a lower value makes the Light backgrounds grayer (`BrandingExample` uses 0.45 for mid gray), and a higher value spreads them apart.
- **Set the backgrounds together.** The background factor, `color_background_secondary`, and `color_background_page` are chosen to suit one `color_background_primary`. They are read only from the plugin whose `color_background_primary` is used (or, for the two colors, from a later plugin; see [Several branding plugins](#several-branding-plugins)). If that plugin does not set them, the factor is 1.0 and the two colors are computed from `color_background_primary`, not taken from Victron. The compiler warns if a file sets the factor without `color_background_primary`.
- **Text.** The Light scheme's text colors are computed from the Dark ones for contrast. `color_font_primary` on `color_background_primary` should have a contrast ratio of at least 4.5:1, or the GUI logs a warning. `color_font_secondary` is made darker or lighter, in each scheme, until it has at least 3:1 on the backgrounds.
- **Text on colored fills**, such as a label on a brand-colored button, is chosen automatically: white if white has at least 3:1 contrast on the fill, otherwise a dark text color.
- **Keep warnings and errors distinct from the brand.** Nothing checks this. If your brand color is orange or red, change `color_warning` or `color_critical` so that a warning does not look like a brand-colored button. `BrandingExample` uses an amber warning color next to its orange brand.
- **The key navigation focus ring** (shown when using keys or buttons, not touch) is drawn in the success color in the Dark scheme, and in the warning color in the Light scheme.
- **Check the result in both schemes.** Nothing checks that a brand or status color stands out from the background. For example, a mid orange brand on a mid gray Light background is hard to see as a fill. The `BrandingExample` README lists the weak spots that this example has on purpose.

## Logos

- The start-up screen draws the icon and the wordmark on top of each other, both stretched to the same box. Victron's two images share a 285x54 canvas, with the icon at the left and the wordmark to its right, and transparency elsewhere. Draw yours on a 285x54 canvas, in the same places. Other sizes are stretched.
- Set both `splash_logo_icon` and `splash_logo_text`. If you set only the icon, Victron's wordmark is still shown next to it.
- By default, each logo is drawn in one color, the scheme's main text color: white in Dark, dark gray in Light. Set `splash_logo_icon_preserve_colors` or `splash_logo_text_preserve_colors` to `true` to draw that logo in its own colors. One file serves both schemes, so a logo in its own colors must read on both the Dark and the Light background (`BrandingExample`'s icon has a dark outline for this).
- In SVG files, draw text as paths, not as SVG text: the device may not have the font.

## Fonts

- List the font files in `font_files`, and name the family in `font_family`, the font for all text except quantities, and `quantity_font_family`, the font for numbers with their units.
- A font that is installed on the device can be named without listing a file.
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

More than one installed plugin can have a branding integration. The GUI sorts them by plugin name, and for each property uses the value from the last plugin that sets it. A property that no plugin sets keeps Victron's value. The exceptions are the background factor, `color_background_secondary` and `color_background_page`, which follow `color_background_primary` as described in [Colors](#colors).

## Checking your work

This is the loop to follow, by hand or as an agent:

1. Run the compiler with `--branding Branding.qml`. It runs the literal-only check, which reports every problem in the file, each as `file:line:column: property: what was found, and how to fix it`. For example:

   ```
   Branding.qml:5:20: splash_logo_icon: expected a string literal, found a call to Qt.resolvedUrl. Write "logo.svg"; the path is relative to Branding.qml.
   ```

2. Fix every reported problem, and run the compiler again, until it passes.
3. The compiler then runs `qmllint` on the file, if it can find `qmllint` and the `Victron.Branding` module. On a GX device it cannot, and says that it skipped it. Fix anything `qmllint` reports.
4. Install the plugin with `--install root@<gx-host>`, and look at the device in both the Dark and the Light scheme: the start-up screen, the Overview page, a settings page with switches and buttons, and the notifications.
5. Check the GUI's log for warnings that name your plugin.
6. To compare your plugin with the Victron colors on a desktop build, capture the same pages with and without it, as described in [Capturing with a branding plugin](visual-regression-tests.md#capturing-with-a-branding-plugin).

## Versioning

`Victron.Branding` has its own version, `major.minor`, separate from gui-v2's version and from the other plugin modules.

- **Minor versions add properties.** The property reference says which version added each property ("Added in").
- **The required version.** The compiler writes `requiredBrandingVersion` into the plugin's JSON file: the lowest `Victron.Branding` version that has every property your file sets. A plugin that sets only properties from 1.0 needs 1.0, even if the compiler was built for a newer version, so it still runs on older GX devices.
- **What the GUI does with it.** If the GUI's `Victron.Branding` has a different major version, or an older minor version, than `requiredBrandingVersion`, the GUI ignores the plugin's branding integration and logs why, for example `Ignoring the branding integration in plugin OemName - it needs Victron.Branding 1.2, but this GUI only has 1.1`. The plugin's other integrations still load. A plugin without `requiredBrandingVersion` is not checked.
- **Deprecation.** A property that is to be removed is first marked as deprecated in the property reference, and from then on the GUI logs a warning, once, when a plugin sets it. It is removed only in the next major version. No property is deprecated yet.
- **Major versions** remove or change properties. When a new major version is announced, plugin authors must port their plugins to the new API.

## Changing Victron.Branding (gui-v2 contributors)

- The `Branding` type is `src/branding/branding.h`. The module depends only on Qt: it must not include, import, or link any other Victron module.
- The module version is set in `cmake/ModuleBranding.cmake`.
- To add a property: declare it in `branding.h`, on one line, with `REVISION(major, minor)` set to the new version, and with a comment above it in the same form as the others (what it sets, then `If not set:`); raise the minor version in `cmake/ModuleBranding.cmake`; then run `python3 tools/brandingproperties.py`. That regenerates `tools/branding-properties.json`, which the compiler uses, and the property reference below. The `tst_brandingproperties` test fails if either is out of date.
- `tools/branding-properties.json` is also the checked-in record of the `Victron.Branding` API: plugins can only set properties, so the property names, types and versions are the whole API. `tools/brandingproperties.py` refuses to remove a property from it, or to change a property's type or version, unless the major version has gone up. It also refuses a new property whose `REVISION` is not the current module version. Only for a property that no released GUI has, `--allow-breaking-changes` lets you remove or change it.
- Removing or changing a property needs a new major version. See [Versioning](#versioning).

## Property reference

The properties of `Branding`. "If not set" says what is used when no installed branding plugin sets the property. "Victron's value" is Victron's own color in the Dark scheme.

<!-- BEGIN property reference. tools/brandingproperties.py writes this part from src/branding/branding.h: edit the comments there, not this text. -->

### `color_brand`

The brand color: buttons, switches, sliders, radio buttons, the selected navigation bar tab, the Overview widget borders, and informative notifications. The Light scheme uses the same color.

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

Font files (.ttf or .otf) to register, relative to Branding.qml. Name the font with font_family and quantity_font_family.

- Type: list of strings
- Added in: 1.0
- If not set: no font files are registered.

### `font_family`

The family name of the font for all text except quantities, from font_files or installed on the device. It is used only for languages it has the letters for; the others, and languages that have their own font (such as Chinese), use the built-in font.

- Type: string
- Added in: 1.0
- If not set: the built-in font, Roboto, or the language's own font.

### `quantity_font_family`

The family name of the font for quantities: numbers with their units. It needs digits of equal width, or changing values jitter. It is used for every language.

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

<!-- END property reference -->
