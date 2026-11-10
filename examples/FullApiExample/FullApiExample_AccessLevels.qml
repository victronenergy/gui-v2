import QtQuick
import Victron.GuiPlugins

/*
	List items that are shown, or can be changed, only from an access level.

	The hints name the current Access level value from Settings, and which value to set to see
	the other list items.
*/
PluginPage {
	id: root

	PluginDataItem {
		id: accessLevelItem

		serviceType: "settings"
		path: "/Settings/System/AccessLevel"
	}

	// Settings may not be loaded yet. The value is the PluginAccessLevel number when it is valid.
	readonly property int accessLevel: accessLevelItem.valid ? accessLevelItem.value : -1

	readonly property string changeAccessLevel: " Change it in Settings -> General -> "
			+ "Access & Security -> Access level."

	readonly property string shownHint: {
		switch (root.accessLevel) {
		case PluginAccessLevel.User:
			return "Access level is User, so only the User item is shown. "
					+ "Set it to User & Installer or higher to show the others."
					+ root.changeAccessLevel
		case PluginAccessLevel.Installer:
			return "Access level is User & Installer, so the User and Installer items are shown. "
					+ "Set it to Superuser or Service to show more, or to User to hide the Installer item."
					+ root.changeAccessLevel
		case PluginAccessLevel.SuperUser:
			return "Access level is Superuser, so the Service item is hidden. "
					+ "Set it to Service to show it, or to User & Installer or User to hide more."
					+ root.changeAccessLevel
		case PluginAccessLevel.Service:
			return "Access level is Service, so every item is shown. "
					+ "Set it to Superuser or lower to hide items."
					+ root.changeAccessLevel
		}
		return "The access level is not known yet."
	}

	readonly property string changedHint: {
		switch (root.accessLevel) {
		case PluginAccessLevel.User:
			return "Access level is User, so only the User switch changes. "
					+ "A click on the others shows a message and does not change them. "
					+ "Set it to User & Installer or higher to change them."
					+ root.changeAccessLevel
		case PluginAccessLevel.Installer:
			return "Access level is User & Installer, so the User and Installer switches change. "
					+ "A click on Super user or Service shows a message and does not change them. "
					+ "Set it to Superuser or Service to change those, or to User to lock the Installer switch."
					+ root.changeAccessLevel
		case PluginAccessLevel.SuperUser:
			return "Access level is Superuser, so the User, Installer and Super user switches change. "
					+ "A click on Service shows a message and does not change it. "
					+ "Set it to Service to change it, or to User & Installer or User to lock more."
					+ root.changeAccessLevel
		case PluginAccessLevel.Service:
			return "Access level is Service, so every switch changes. "
					+ "Set it to Superuser or lower, and a click on a locked switch shows a message instead of changing it."
					+ root.changeAccessLevel
		}
		return "The access level is not known yet."
	}

	PluginItemListView {
		PluginPrimaryListLabel {
			text: root.shownHint
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
			text: "Service"
			secondaryText: "Shown"
			showAccessLevel: PluginAccessLevel.Service
		}

		PluginSettingsListHeader {
			text: "Changed from"
		}

		PluginPrimaryListLabel {
			text: root.changedHint
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
