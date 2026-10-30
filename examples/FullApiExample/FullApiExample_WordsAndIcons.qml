import QtQuick
import Victron.GuiPlugins

/*
	The common words and icons of Victron.GuiPlugins.

	The words are already translated into the user's language: change the language in the display
	settings to see them change. The icons are drawn in the GUI's colors, so they can be seen in
	both light and dark mode.
*/
PluginPage {
	id: root

	PluginGradientListView {
		PluginSettingsListHeader {
			text: "Answers and actions"
		}

		PluginPrimaryListLabel {
			text: [
				PluginWords.yes, PluginWords.no, PluginWords.reset, PluginWords.remove
			].join(", ")
		}

		PluginSettingsListHeader {
			text: "Setting values"
		}

		PluginPrimaryListLabel {
			text: [
				PluginWords.on, PluginWords.off, PluginWords.auto, PluginWords.enabled, PluginWords.disabled
			].join(", ")
		}

		PluginSettingsListHeader {
			text: "States"
		}

		PluginPrimaryListLabel {
			text: [
				PluginWords.error, PluginWords.unknown_status
			].join(", ")
		}

		PluginSettingsListHeader {
			text: "Labels"
		}

		PluginPrimaryListLabel {
			text: [
				PluginWords.status, PluginWords.state, PluginWords.mode, PluginWords.type,
				PluginWords.settings, PluginWords.setup, PluginWords.alarms, PluginWords.history,
				PluginWords.total
			].join(", ")
		}

		PluginSettingsListHeader {
			text: "Quantities"
		}

		PluginPrimaryListLabel {
			text: [
				PluginWords.temperature, PluginWords.voltage, PluginWords.current_amps,
				PluginWords.power_watts
			].join(", ")
		}

		PluginSettingsListHeader {
			text: "Devices"
		}

		PluginPrimaryListLabel {
			text: [
				PluginWords.battery, PluginWords.manufacturer, PluginWords.model_name,
				PluginWords.serial_number, PluginWords.firmware_version, PluginWords.custom_name
			].join(", ")
		}

		PluginSettingsListHeader {
			text: "Icons"
		}

		PluginListItem {
			// Without text, the icons fill the width of the row, and wrap onto more lines if needed.
			caption: "Every icon in PluginIcons, in the default tint"

			Flow {
				width: parent.width
				spacing: 8

				PluginIconImage { source: PluginIcons.alarm }
				PluginIconImage { source: PluginIcons.warning }
				PluginIconImage { source: PluginIcons.info }
				PluginIconImage { source: PluginIcons.checkmark }
				PluginIconImage { source: PluginIcons.close }
				PluginIconImage { source: PluginIcons.plus }
				PluginIconImage { source: PluginIcons.minus }
				PluginIconImage { source: PluginIcons.trash }
				PluginIconImage { source: PluginIcons.refresh }
				PluginIconImage { source: PluginIcons.open_link }
				PluginIconImage { source: PluginIcons.battery }
				PluginIconImage { source: PluginIcons.temperature }
				PluginIconImage { source: PluginIcons.humidity }
				PluginIconImage { source: PluginIcons.devices }
			}
		}

		PluginListItem {
			text: "Tints"
			caption: "Text, SecondaryText, Warning, Critical, Success and Disabled"

			Row {
				spacing: 8

				PluginIconImage {
					source: PluginIcons.info
					// Text is the default tint.
					tint: PluginIconImage.Text
				}

				PluginIconImage {
					source: PluginIcons.info
					tint: PluginIconImage.SecondaryText
				}

				PluginIconImage {
					source: PluginIcons.warning
					tint: PluginIconImage.Warning
				}

				PluginIconImage {
					source: PluginIcons.alarm
					tint: PluginIconImage.Critical
				}

				PluginIconImage {
					source: PluginIcons.checkmark
					tint: PluginIconImage.Success
				}

				PluginIconImage {
					source: PluginIcons.close
					tint: PluginIconImage.Disabled
				}
			}
		}

		PluginListItem {
			text: "Disabled, and sized"
			caption: "A disabled icon uses the Disabled color, whatever its tint. Set width and height for a size other than the usual one."

			Row {
				spacing: 8

				PluginIconImage {
					anchors.verticalCenter: parent.verticalCenter
					source: PluginIcons.warning
					tint: PluginIconImage.Warning
					enabled: false
				}

				PluginIconImage {
					width: 48
					height: 48
					source: PluginIcons.battery
				}
			}
		}
	}
}