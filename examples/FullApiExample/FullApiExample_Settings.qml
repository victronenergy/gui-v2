import QtQuick
import Victron.GuiPlugins

/*
	Rows that change values: switches, text fields, numbers, options and buttons.

	The first group changes the plugin's own settings, under /Settings/FullApiExample/ in
	com.victronenergy.settings. On a GX device, the plugin's own service creates its settings: see
	the README. In mock mode, the settings do not exist until "Reset to defaults" is clicked.

	The second group has no data items: the page keeps the values itself.
*/
PluginPage {
	id: root

	// The Level setting is shown on the Custom rows page. Reset to defaults writes it too.
	readonly property PluginDataItem levelSetting: PluginDataItem {
		serviceType: "settings"
		path: "/Settings/FullApiExample/Level"
	}

	// Writes the default value of each of the example's settings. In mock mode, this creates them.
	function resetToDefaults() {
		enabledSwitch.dataItem.setValue(1)
		reportSwitch.dataItem.setValue(1)
		nameField.dataItem.setValue("")
		limitSpinBox.dataItem.setValue(16)
		modeGroup.dataItem.setValue(1)
		root.levelSetting.setValue(3)
	}

	PluginGradientListView {
		PluginPrimaryListLabel {
			text: "The example's settings do not exist yet. In mock mode, click Reset to defaults to create them. On a GX device, create them as the plugin's README describes."
			// Hidden once the settings exist.
			preferredVisible: !enabledSwitch.dataItem.valid
		}

		PluginSettingsListHeader {
			text: "Settings"
		}

		PluginListSwitch {
			id: enabledSwitch

			text: "Enabled"
			secondaryText: enabledSwitch.checked ? "Running" : "Stopped"
			dataItem.serviceType: "settings"
			dataItem.path: "/Settings/FullApiExample/Enabled"
			// The page writes the value itself, so that turning the example off also sets Mode to Off.
			updateDataOnClick: false

			onClicked: {
				// 'checked' is still the value from before the click. Keep it, as writing the
				// value may change 'checked' straight away.
				const turnOff = enabledSwitch.checked
				enabledSwitch.dataItem.setValue(turnOff ? 0 : 1)
				if (turnOff) {
					modeGroup.dataItem.setValue(0)
				}
			}
		}

		PluginListSwitch {
			id: reportSwitch

			text: "Weekly report"
			caption: "Writes 7 when on, and 1 when off: the number of days between reports."
			valueTrue: 7
			valueFalse: 1
			dataItem.serviceType: "settings"
			dataItem.path: "/Settings/FullApiExample/ReportDays"
			// Clickable only while the example is enabled.
			interactive: enabledSwitch.checked && reportSwitch.dataItem.valid
		}

		PluginListTextField {
			id: nameField

			text: "Name"
			placeholderText: "Enter a name"
			maximumLength: 20
			dataItem.serviceType: "settings"
			dataItem.path: "/Settings/FullApiExample/Name"
			writeAccessLevel: PluginAccessLevel.User
		}

		PluginListSpinBox {
			id: limitSpinBox

			text: "Current limit"
			suffix: " A"
			decimals: 1
			stepSize: 0.5
			// By default, from and to are the minimum and maximum of dataItem. The system gives them
			// for a setting created with a minimum and maximum, as in the README. Mock mode does not,
			// so min and max are NaN, and the row uses 0 and 32 instead.
			from: isNaN(limitSpinBox.dataItem.min) ? 0 : limitSpinBox.dataItem.min
			to: isNaN(limitSpinBox.dataItem.max) ? 32 : limitSpinBox.dataItem.max
			dataItem.serviceType: "settings"
			dataItem.path: "/Settings/FullApiExample/CurrentLimit"
		}

		PluginListRadioButtonGroup {
			id: modeGroup

			text: "Mode"
			caption: "On can be picked only while the example is enabled."
			optionModel: [
				{ display: PluginWords.off, value: 0 },
				{ display: PluginWords.auto, value: 1 },
				{ display: PluginWords.on, value: 2 }
			]
			dataItem.serviceType: "settings"
			dataItem.path: "/Settings/FullApiExample/Mode"
			writeAccessLevel: PluginAccessLevel.User
			// The page writes the value itself, so that it can refuse On while the example is disabled.
			updateDataOnClick: false

			onOptionClicked: (index) => {
				const value = modeGroup.optionModel[index].value
				if (value === 2 && !enabledSwitch.checked) {
					console.warn("FullApiExample: Mode cannot be On while the example is disabled")
					return
				}
				modeGroup.dataItem.setValue(value)
			}
		}

		PluginListButton {
			text: "All settings"
			caption: "In mock mode, this also creates the settings."
			secondaryText: "Reset to defaults"

			onClicked: root.resetToDefaults()
		}

		PluginSettingsListHeader {
			text: "Values kept by the page"
		}

		PluginPrimaryListLabel {
			text: "These rows have no data item. The page keeps their values, which are lost when the page closes."
		}

		PluginListSwitch {
			id: detailsSwitch

			text: "Show details"
			checkable: true
			// The starting value. A click replaces this binding.
			checked: true
		}

		PluginListTextField {
			id: noteField

			text: "Note"
			// The starting text. Editing replaces this binding.
			secondaryText: "Hello"
			writeAccessLevel: PluginAccessLevel.User
		}

		PluginListSpinBox {
			id: countSpinBox

			text: "Count"
			// The starting number. Picking a number replaces this binding.
			value: 3
			from: 0
			to: 10
		}

		PluginListRadioButtonGroup {
			id: sizeGroup

			text: "Size"
			optionModel: [
				{ display: "Small", value: "small" },
				{ display: "Large", value: "large" }
			]
			// Shown while currentIndex is -1, before an option is picked.
			defaultSecondaryText: "Not chosen"
			writeAccessLevel: PluginAccessLevel.User

			onOptionClicked: (index) => {
				sizeGroup.currentIndex = index
			}
		}

		PluginListText {
			text: "Details"
			secondaryText: noteField.secondaryText + ", " + countSpinBox.value + ", "
				+ (sizeGroup.currentIndex >= 0 ? sizeGroup.optionModel[sizeGroup.currentIndex].display : "no size")
			preferredVisible: detailsSwitch.checked
		}

		PluginSettingsListHeader {
			text: "Clicking rows from code"
		}

		PluginListNavigation {
			text: "Mode options"
			caption: "Opens no page of its own: its onClicked calls click() on the Mode row, which opens the options."

			onClicked: modeGroup.click()
		}

		PluginListButton {
			text: "Current limit"
			caption: "Calls click() on the Current limit row, which opens its dialog."
			secondaryText: "Change"
			interactive: limitSpinBox.interactive

			onClicked: limitSpinBox.click()
		}
	}
}
