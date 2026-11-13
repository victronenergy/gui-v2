import QtQuick
import Victron.GuiPlugins

// List items that show values: text, quantities with a unit, and temperatures.
PluginPage {
	id: root

	// A value that no list item shows directly: the Battery list item below uses it.
	readonly property PluginDataItem socItem: PluginDataItem {
		serviceType: "system"
		path: "/Dc/Battery/Soc"
	}

	PluginItemListView {
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
			text: "These items show fixed numbers, set with value instead of a data item, in each PluginUnit. The items choose the number of decimal places, unless decimals is set."
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
			text: "Hectopascal"
			value: 1013
			unit: PluginUnit.Hectopascal
		}

		PluginListQuantity {
			text: "Hertz"
			value: 50
			unit: PluginUnit.Hertz
		}

		PluginListQuantity {
			text: "Kilopascal"
			value: 101.3
			unit: PluginUnit.Kilopascal
		}

		PluginListQuantity {
			text: "Percentage"
			value: 87
			unit: PluginUnit.Percentage
		}

		PluginListQuantity {
			text: "PowerFactor"
			caption: "A number with no unit"
			value: 0.95
			unit: PluginUnit.PowerFactor
		}

		PluginListQuantity {
			text: "RevolutionsPerMinute"
			value: 1500
			unit: PluginUnit.RevolutionsPerMinute
		}

		PluginListQuantity {
			text: "Time_Day"
			value: 3
			unit: PluginUnit.Time_Day
		}

		PluginListQuantity {
			text: "Time_Hour"
			value: 5
			unit: PluginUnit.Time_Hour
		}

		PluginListQuantity {
			text: "Time_Minute"
			value: 45
			unit: PluginUnit.Time_Minute
		}

		PluginListQuantity {
			text: "Time_Second"
			value: 30
			unit: PluginUnit.Time_Second
		}

		PluginListQuantity {
			text: "VoltAmpere"
			value: 3000
			unit: PluginUnit.VoltAmpere
		}

		PluginListQuantity {
			text: "VoltAmpereReactive"
			value: 500
			unit: PluginUnit.VoltAmpereReactive
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
			text: "WattsPerSquareMetre"
			value: 850
			unit: PluginUnit.WattsPerSquareMetre
		}

		PluginListQuantity {
			text: "No number"
			caption: "A value that is not a number is shown as --"
			value: NaN
			unit: PluginUnit.Watt
		}
	}
}
