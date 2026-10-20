import Victron.Branding

Branding {
	// Dark: mid orange on very dark grey. Light is derived.
	color_brand: "#F28C28"
	// Same orange as the brand. Victron blue looks out of place beside it.
	color_info: "#F28C28"
	color_background_primary: "#1A1A1A"

	// Light backgrounds: mid grey, not the plain inversion.
	light_mode_background_factor: 0.45

	// Amber, so that warnings do not look like the orange brand.
	color_warning: "#F2C200"
	// A little darker than Victron green (#72B84C), still bright.
	color_success: "#67B03F"

	splash_logo_icon: "logo.svg"
	splash_logo_icon_preserve_colors: true
	splash_logo_text: "wordmark.svg"

	// Victron's 5" gauge intro, with each blue shade recolored to this orange.
	// No light file: this animation is used in both schemes.
	splash_gauge_animation: "splash_gauge.gif"
}
