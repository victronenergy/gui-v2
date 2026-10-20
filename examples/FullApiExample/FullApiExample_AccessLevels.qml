import QtQuick
import Victron.GuiPlugins

/*
	Rows that are shown, or can be changed, only from an access level.

	Change the access level in Settings -> General -> Access & Security -> Access level, then come
	back to this page.
*/
PluginPage {
	id: root

	PluginGradientListView {
		PluginPrimaryListLabel {
			// effectiveVisible is false while the access level hides the row.
			text: serviceRow.effectiveVisible
				? "Every row is shown at this access level."
				: "Some rows are hidden at this access level."
		}

		PluginSettingsListHeader {
			text: "Shown from"
		}

		PluginListText {
			text: "User"
			secondaryText: "Shown"
			showAccessLevel: PluginAccessLevel.User
		}

		PluginListText {
			text: "Installer"
			secondaryText: "Shown"
			showAccessLevel: PluginAccessLevel.Installer
		}

		PluginListText {
			text: "Super user"
			secondaryText: "Shown"
			showAccessLevel: PluginAccessLevel.SuperUser
		}

		PluginListText {
			id: serviceRow

			text: "Service"
			secondaryText: "Shown"
			showAccessLevel: PluginAccessLevel.Service
		}

		PluginSettingsListHeader {
			text: "Changed from"
		}

		PluginPrimaryListLabel {
			text: "Below its writeAccessLevel, a row is shown, but a click shows a message instead of changing it."
		}

		PluginListSwitch {
			text: "User"
			checkable: true
			writeAccessLevel: PluginAccessLevel.User
		}

		PluginListSwitch {
			text: "Installer"
			checkable: true
			writeAccessLevel: PluginAccessLevel.Installer
		}

		PluginListSwitch {
			text: "Super user"
			checkable: true
			writeAccessLevel: PluginAccessLevel.SuperUser
		}

		PluginListSwitch {
			text: "Service"
			checkable: true
			writeAccessLevel: PluginAccessLevel.Service
		}
	}
}
