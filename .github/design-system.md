# Design system

**All UI must work with both color schemes (Dark and Light) and with a custom branding plugin.** This guide says where the Theme colors come from and how a custom branding plugin changes them, which colors to use, how to add a color key, and how to color images. For how the Theme values are defined and generated, see [Theme system](architecture.md#theme-system). For how a custom branding plugin is found and loaded, see [Custom branding](architecture.md#custom-branding). For how to write one, see [Custom branding plugins](branding-plugins.md).

## Where the colors come from

There are three kinds of Theme color:
- **Palette colors**, in `ColorDesign.json`, such as `color_blue` and `color_gray1`. They are fixed: no branding changes them.
- **Branding colors**: the ten colors that a `Branding` object sets. They are the role colors `color_brand`, `color_info`, `color_success`, `color_warning` and `color_critical`, and `color_background_primary`, `color_background_secondary`, `color_page_background`, `color_font_primary` and `color_font_secondary`. The `Branding` property for `color_page_background` is named `color_background_page`.
- **Computed colors**: every other key in `Dark.json` and `Light.json`. Each one names, or is computed with a function from, branding colors, other computed colors or palette colors.

Victron's own branding colors are set in `VictronBranding.qml`. `Dark.json` also lists most of them, but those values are not used, and `Light.json` must not list them.

A custom branding plugin overrides colors with its own `Branding.qml`. It can set any of the ten branding colors, and `light_mode_background_factor`. A color it does not set keeps Victron's value, with a few exceptions for the backgrounds (see [Custom branding](architecture.md#custom-branding)). It cannot set any other color: not a computed color such as `color_button` or `color_focus_highlight`, and not a palette color.

The branding colors are the Dark scheme's colors. The Light scheme keeps the brand and status colors, and computes its backgrounds and text colors from the Dark ones (see [Colors](branding-plugins.md#colors)).

Whenever the custom branding or the color scheme changes, `Theme` computes every computed color again and emits `themeValuesChanged`. A computed color follows the custom branding if it is built from branding colors, directly or through other computed colors. One that is built only from palette colors does not. So:
- To make a part follow the custom branding, give it a branding color or a color computed from one. See [Choosing a color](#choosing-a-color) and [Adding a color key](#adding-a-color-key).
- To let a plugin change a part that it cannot change yet, prefer computing that part's color from the existing branding colors. A new `Branding` property changes the `Victron.Branding` API that plugins depend on (see [Changing Victron.Branding](branding-plugins.md#changing-victronbranding-gui-v2-contributors)).
- Check a change with a custom branding plugin, in both schemes. `examples/BrandingExample` changes the brand, info, success and warning colors and the background. To compare the result with Victron's colors, see [Capturing with a custom branding plugin](visual-regression-tests.md#capturing-with-a-custom-branding-plugin).

## Choosing a color

Draw controls, text, backgrounds, notifications and status with the role colors, not with the palette colors from `ColorDesign.json` (`color_blue`, `color_red`, `color_orange`, `color_green`, `color_white`, `color_black`, the fixed grays and so on). A custom branding can change the role colors, and every color computed from them follows. A palette color never changes, so a part drawn with one keeps Victron's colors under a custom branding, and can be hard to read on a branded background. Use:
- `color_brand` for controls, such as buttons, switches and sliders.
- `color_info` for informative notifications, and for quantities that are not a success, a warning or an alarm.
- `color_success` for success and feed-in.
- `color_warning` for warnings, and `color_critical` for alarms and errors.
- Their dark and dim variants, such as `color_darkBrand`, `color_darkInfo`, `color_dimSuccess` and `color_darkCritical`, for a fill that has the same meaning but stands out less.
- `color_font_*` and `color_background_*` for text and backgrounds, and `color_gray4` and `color_gray5` for other grays.

`color_gray4` and `color_gray5` are not palette colors, despite their names: each scheme computes them from its font and background colors with `font_over_background()`, so they follow custom branding. The palette's fixed grays at those two steps are `color_darkWhite` and `color_dimWhite`.

A gauge that picks a status color by level uses `Gauges.statusColor()` from `Victron.Gauges`. It reads the Theme colors in JavaScript, not in C++, so the binding updates when the theme changes.

Text or an icon drawn on a role color must not use a fixed color such as `color_white`, because a custom branding can make that role color light. Use a key that is computed with `text_color_on()`, such as `color_button_down_text` (see [Adding a color key](#adding-a-color-key)).

Use a palette color only in these cases:
- **Data colors.** A color that identifies the data itself, not its state, must not change with a custom branding: tank fluids, the temperature and humidity gauge scales, the droop graph, and the light colors in the color picker. A key for a data color must name a palette color, not a role color or another scheme key, so that it never follows custom branding (see the alias rules in [Theme system](architecture.md#theme-system)).
- **On a fixed color.** Text, icons and handles drawn on a data color use a fixed color too, so that they stay readable on it, such as `color_levelsPage_tank_title` on a tank header and the white dots on the temperature slider. The QR code dialog has a white background, because a QR code must be dark on light to be scanned reliably.
- **Translucent effects.** Translucent white or black that lightens or darkens whatever is under it, such as the press effect on `MomentaryButton` (`color_dimWhite2`).
- **Victron's logo.** With no custom branding plugin, `SplashView` draws Victron's logo in its design colors (see [Custom branding](architecture.md#custom-branding)).
- **Theme files and tests.** `VictronBranding.qml` sets Victron's branding colors to palette values. `Dark.json` and `Light.json` use palette colors for the cases above, and as inputs to some computed colors. Tests can compare with palette colors.

## Adding a color key

Add a new color key to both `Dark.json` and `Light.json`: the build fails if a key is in only one of them. Set it to a role color or another scheme key, or compute it from one with a function, so that it follows custom branding. Only the cases listed above name a palette color.

The functions are listed and described in `tools/themeparser.py`. These are often needed:
- `dim(c)`: `c` at 70% alpha, blended onto `color_background_primary`.
- `text_color_on(c, ...)`: the color for text on the fills `c, ...`. It is white if white has at least 3:1 contrast on every fill, otherwise a dark font color darkened toward black until it does.
- `fill_for_text(c, text)` and `readable_text_on(text, c, ...)`: for when no one text color can be read on every fill the text is drawn on. `fill_for_text()` darkens or lightens one fill until a chosen text color can be read on it. `readable_text_on()` instead moves the text color until it can be read on those fills.

## Images

Images must not have brand or status colors baked in. Tint single-color art with a Theme color: `CP.ColorImage` or `IconImage` for an image, and for a `BorderImage` the `image://tinted/<rrggbb>/<resource path>` image provider (`src/tintedimageprovider.cpp`), as `GlobalKeyNavigationHighlight` does with `color_focus_highlight`.
