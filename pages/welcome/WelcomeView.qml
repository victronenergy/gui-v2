/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

Rectangle {
	id: root
	width: Theme.geometry_screen_width
	height: Theme.geometry_screen_height
	color: Theme.color_page_background

	// Stop mouse events from getting through the view
	MouseArea {
		anchors.fill: parent
	}

	Item {
		id: header
		x: Theme.geometry_page_content_horizontalMargin
		width: parent.width - (2 * Theme.geometry_page_content_horizontalMargin)
		height: Theme.geometry_statusBar_height

		Label {
			id: whatsNewLabel
			anchors {
				bottom: progressBar.top
				bottomMargin: Theme.geometry_welcome_header_bottomMargin
			}
			font.pixelSize: Theme.font_size_body2
			//% "What's New"
			text: qsTrId("welcome_whatsnew")
		}

		Button {
			anchors {
				right: parent.right
				verticalCenter: whatsNewLabel.verticalCenter
			}
			font.pixelSize: Theme.font_size_body2
			//% "Skip"
			text: qsTrId("welcome_skip")
			flat: true
			color: Theme.color_ok
			onClicked: onboardingDone.setValue(1)
		}

		ProgressBar {
			id: progressBar
			width: parent.width
			anchors.bottom: parent.bottom
			from: 0
			to: welcomePages.count
			value: stackView.depth
		}
	}

	readonly property var welcomePageModel: [
		{
			//% "Welcome!"
			title: qsTrId("welcome_landing_title"),
			imageUrl: "qrc:/images/welcome-landing.png",
			//% "We’re excited to introduce a completely redesigned interface that enhances both "
			//% "the usability and aesthetics of your GX.\n\n"
			//% "With streamlined navigation and a fresh look, everything you love is now even "
			//% "easier to access and more visually appealing."
			text: qsTrId("welcome_landing_text")
		},
		{
			//% "Dark - light mode"
			title: qsTrId("welcome_colors_title"),
			imageUrl: "qrc:/images/welcome-dark.png",
			//% "Different environments call for different display settings. Dark and Light Modes "
			//% "ensure the best viewing experience no matter where you are."
			text: qsTrId("welcome_colors_text")
		},
		{
			//% "Brief"
			title: qsTrId("welcome_brief_title"),
			imageUrl: "qrc:/images/welcome-brief.png",
			//% "All the key information you need, presented in a clean and simple layout. The "
			//% "centerpiece is a customizable widget featuring rings, giving you quick access to "
			//% "your system insights at a glance."
			text: qsTrId("welcome_brief_text")
		},
		{
			//% "Overview"
			title: qsTrId("welcome_overview_title"),
			imageUrl: "qrc:/images/welcome-overview.png",
			//% "Gain greater control with our updated Overview panel, featuring real-time system "
			//% "data — all in one place for easy monitoring."
			text: qsTrId("welcome_overview_text")
		},
		{
			//% "Controls"
			title: qsTrId("welcome_controls_title"),
			imageUrl: "qrc:/images/welcome-controls.png",
			//% "All the day to day controls are now combined together in the new Controls pane. "
			//% Accessible from anywhere by tapping the dedicated button on top left of the display."
			text: qsTrId("welcome_controls_text")
		},
		{
			//% "Watts & Amps"
			title: qsTrId("welcome_units_title"),
			imageUrl: "qrc:/images/welcome-units.png",
			//% "You can now switch between Watts and Amps. Choose the unit that best fits your "
			//% "preference."
			text: qsTrId("welcome_units_text")
		},
		{
			//% "Learn more"
			title: qsTrId("welcome_more_title"),
			imageUrl: "qrc:/images/welcome-more.png",
			text: Qt.platform.os === "wasm"
				  //: %1 = link to URL with more information
				  //% "Access the link below to find out more about the Renewed UI.<br /><br /><a href=\"%1\">%1</a>"
				? qsTrId("welcome_more_text_wasm").arg("https://ve3.nl/gx-nui-ob")
				  //% "Scan the QR code to find out more about the Renewed UI."
				: qsTrId("welcome_more_text"),
			qrCodeUrl: Qt.platform.os === "wasm" ? "" : "qrc:/images/welcome-qrCode.png"
		}
	]

	Instantiator {
		id: welcomePages
		model: welcomePageModel
		delegate: WelcomePage {
			imageUrl: modelData.imageUrl
			title: modelData.title
			text: modelData.text
			qrCodeUrl: modelData.qrCodeUrl || ""
			backButtonEnabled: model.index > 0
			nextButtonText: model.index === welcomePages.count - 1
				  //% "Done"
				? qsTrId("welcome_done")
				  //% "Next"
				: qsTrId("welcome_next")
			onBackClicked: {
				if (stackView.depth > 1) {
					stackView.pop()
				}
			}
			onNextClicked: {
				if (stackView.depth === welcomePages.count) {
					onboardingDone.setValue(1)
				} else {
					stackView.push(welcomePages.objectAt(stackView.depth))
				}
			}
		}
		onObjectAdded: (index, object) => {
			if (index === 0) {
				stackView.push(object, {}, C.StackView.Immediate)
			}
		}
	}

	C.StackView {
		id: stackView
		anchors {
			left: parent.left
			right: parent.right
			top: header.bottom
			bottom: parent.bottom
		}
	}

	VeQuickItem {
		id: onboardingDone
		uid: Global.systemSettings.serviceUid + "/Settings/Gui2/OnBoarding"
	}
}
