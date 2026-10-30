/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import Victron.Branding

// Victron's branding: the first entry Theme applies. The font file URL must be the default
// font URL in Language::fontUrlForLanguage(), so a language with its own font is detected by URL.
Branding {
	color_brand: "#387DC5" // color_blue
	color_info: "#387DC5" // color_blue
	color_success: "#72B84C" // color_green
	color_warning: "#F0962E" // color_orange
	color_critical: "#F35C58" // color_red
	color_background_primary: "#000000" // color_black
	color_background_secondary: "#141414" // color_gray1
	color_font_primary: "#FFFFFF" // color_white
	color_font_secondary: "#969591" // color_gray5
	light_mode_background_factor: 1.12

	font_files: [ "qrc:/fonts/Roboto-Regular.ttf" ]
	font_family: "Roboto"
	quantity_font_family: "Roboto"

	splash_logo_icon: "qrc:/images/splash-logo-icon.svg"
	splash_logo_text: "qrc:/images/splash-logo-text.svg"
	splash_logo_icon_preserve_colors: false
	splash_logo_text_preserve_colors: false
}
