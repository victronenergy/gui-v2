/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Switch control for SwitchableOutput_Type_SteppedSwitch type.
*/
FocusScope {
	id: root

	required property SwitchableOutput switchableOutput

	focus: true
	KeyNavigationHighlight.active: activeFocus

	Keys.onPressed: (event) => {
		switch (event.key) {
		case Qt.Key_Space:
			if (!multiStep.activeFocus) {
				multiStep.focus = true
				event.accepted = true
			}
			break
		case Qt.Key_Return:
		case Qt.Key_Enter:
		case Qt.Key_Escape:
			if (multiStep.activeFocus) {
				multiStep.focus = false
				event.accepted = true
			}
			break
		}
	}

	SwitchableOutputCardDelegateHeader {
		id: header

		anchors {
			top: parent.top
			topMargin: Theme.geometry_switches_header_topMargin
			left: parent.left
			leftMargin: Theme.geometry_controlCard_button_margins
			right: parent.right
			rightMargin: Theme.geometry_controlCard_button_margins
		}
		switchableOutput: root.switchableOutput
	}

	MultiStepButton {
		id: multiStep

		anchors {
			left: parent.left
			right: parent.right
			top: header.bottom
		}
		checked: multiStepState.expectedValue === 1
		onOnClicked: multiStepState.writeValue(1)
		onOffClicked: multiStepState.writeValue(0)

		// Get/set the current index. Note Dimming and DimmingMax are 1-based. E.g. if Dimming=1
		// and DimmingMax=5, the options are 1-5 inclusive, and the first option is selected.
		currentIndex: dimmingSync.expectedValue - 1
		onIndexClicked: (index) => {
			dimmingSync.writeValue(index + 1)
			// With a named off state (single-choice control) selecting a step also switches on.
			if (multiStep.exclusive && multiStepState.expectedValue !== 1) {
				multiStepState.writeValue(1)
			}
		}

		SettingSync {
			id: dimmingSync
			dataItem: VeQuickItem {
				uid: root.switchableOutput.uid + "/Dimming"
			}
		}

		// The /DimmingMax holds the maximum value.
		VeQuickItem {
			id: multiStepMax
			uid: root.switchableOutput.uid + "/Settings/DimmingMax"
			onValueChanged: multiStep.rebuildModel()
		}

		// The optional /Settings/Labels names the options. Like /Dimming it is 1-based; index 0
		// optionally names the off state, which turns the control into a single-choice group.
		VeQuickItem {
			id: multiStepLabels
			uid: root.switchableOutput.uid + "/Settings/Labels"
			onValueChanged: multiStep.rebuildModel()
		}

		// Reserved "/keyword" labels are translated when the model is built
		Connections {
			target: Language
			function onCurrentLanguageChanged() { multiStep.rebuildModel() }
		}

		function rebuildModel() {
			if (multiStepMax.value === undefined) {
				multiStep.model = []
				multiStep.labels = []
				multiStep.offText = ""
				return
			}
			const rawLabels = multiStepLabels.value && typeof multiStepLabels.value !== "string" && multiStepLabels.value.length
					? multiStepLabels.value : []
			const offLabel = rawLabels[0]
			multiStep.offText = typeof offLabel === "string" && offLabel.trim().length > 0
					? VenusOS.ioChannel_labelToText(offLabel)
					: ""
			let items = []
			let labels = []
			// limit maximum number of options
			let totalOptions = Math.min(7, multiStepMax.value)
			for (let i = 0; i < totalOptions; i++) {
				items.push({ 'text': i + 1 })   // options are 1-based
				const label = rawLabels[i + 1]
				labels.push(typeof label === "string" && label.trim().length > 0
						? VenusOS.ioChannel_labelToText(label)
						: "")
			}
			multiStep.model = items
			multiStep.labels = labels
		}

		SettingSync {
			id: multiStepState
			dataItem: VeQuickItem {
				uid: root.switchableOutput.uid + "/State"
			}
		}
	}
}
