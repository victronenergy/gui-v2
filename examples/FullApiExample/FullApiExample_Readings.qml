import QtQuick
import Victron.GuiPlugins

// Rows that show values: text, quantities with a unit, and temperatures.
PluginPage {
	id: root

	// A value that no row shows directly: the Battery row below uses it.
	readonly property PluginDataItem socItem: PluginDataItem {
		serviceType: "system"
		path: "/Dc/Battery/Soc"
	}

	PluginGradientListView {
		PluginSettingsListHeader {
			text: "System"
		}

		PluginListText {
			text: "GX device"
			// secondaryText is the value of dataItem by default.
			dataItem.serviceType: "platform"
			dataItem.path: "/Device/Model"
		}

		PluginListQuantity {
			text: "Battery voltage"
			unit: PluginUnit.Volt_DC
			decimals: 2
			dataItem.serviceType: "system"
			dataItem.path: "/Dc/Battery/Voltage"
		}

		PluginListQuantity {
			text: "Battery current"
			unit: PluginUnit.Amp
			dataItem.serviceType: "system"
			dataItem.path: "/Dc/Battery/Current"
		}

		PluginListQuantity {
			text: "Battery power"
			unit: PluginUnit.Watt
			dataItem.serviceType: "system"
			dataItem.path: "/Dc/Battery/Power"
		}

		PluginListQuantity {
			text: "State of charge"
			unit: PluginUnit.Percentage
			dataItem.serviceType: "system"
			dataItem.path: "/Dc/Battery/Soc"
		}

		PluginListTemperature {
			text: "Battery temperature"
			caption: "In the temperature unit chosen in the display settings"
			decimals: 1
			dataItem.serviceType: "system"
			dataItem.path: "/Dc/Battery/Temperature"
			// Hidden when the system has no battery temperature.
			preferredVisible: dataItem.valid
		}

		PluginListText {
			text: "Battery"
			// Set secondaryText to show text of your own, instead of the value of dataItem.
			secondaryText: !root.socItem.valid ? "Unknown"
				: root.socItem.value >= 50 ? "Charged"
				: "Low"
		}

		PluginSettingsListHeader {
			text: "Units"
		}

		PluginPrimaryListLabel {
			text: "These rows show fixed numbers, set with value instead of a data item, in each PluginUnit. The rows choose the number of decimal places, unless decimals is set."
		}

		PluginListQuantity {
			text: "None"
			value: 42
			unit: PluginUnit.None
		}

		PluginListQuantity {
			text: "Amp"
			value: 12.5
			unit: PluginUnit.Amp
		}

		PluginListQuantity {
			text: "AmpHour"
			value: 200
			unit: PluginUnit.AmpHour
		}

		PluginListQuantity {
			text: "Energy_KiloWattHour"
			value: 1234.5
			unit: PluginUnit.Energy_KiloWattHour
		}

		PluginListQuantity {
			text: "Percentage"
			value: 87
			unit: PluginUnit.Percentage
		}

		PluginListQuantity {
			text: "RevolutionsPerMinute"
			value: 1500
			unit: PluginUnit.RevolutionsPerMinute
		}

		PluginListQuantity {
			text: "VoltAmpere"
			value: 3000
			unit: PluginUnit.VoltAmpere
		}

		PluginListQuantity {
			text: "Volt_AC"
			value: 230
			unit: PluginUnit.Volt_AC
		}

		PluginListQuantity {
			text: "Volt_DC"
			caption: "With decimals set to 3"
			value: 12.8
			unit: PluginUnit.Volt_DC
			decimals: 3
		}

		PluginListQuantity {
			text: "Watt"
			value: 1500
			unit: PluginUnit.Watt
		}

		PluginListQuantity {
			text: "No number"
			caption: "A value that is not a number is shown as --"
			value: NaN
			unit: PluginUnit.Watt
		}
	}
}
