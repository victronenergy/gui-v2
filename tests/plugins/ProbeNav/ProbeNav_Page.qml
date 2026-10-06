import QtQuick
import Victron.VenusOS

Item {
	Timer {
		interval: 200
		repeat: true
		running: true
		onTriggered: {
			const n = Number(GuiPluginLoader.pluginSetting("ProbeNav", "ticks", 0))
			GuiPluginLoader.setPluginSetting("ProbeNav", "ticks", n + 1)
		}
	}
}
