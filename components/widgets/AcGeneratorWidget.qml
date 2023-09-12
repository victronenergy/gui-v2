/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils

AcInputWidget {
	id: root

	title: CommonWords.generator
	icon.source: "qrc:/images/generator.svg"
	type: VenusOS.OverviewWidget_Type_AcGenerator
	input: Global.acInputs.generatorInput
	extraContent.children: input && input.connected
			? phaseModel && phaseModel.count > 1 ? phaseDisplay : []
			: _generatorInfo

	property list<Label> _generatorInfo: [
		Label {
			x: Theme.geometry.overviewPage.widget.content.horizontalMargin
			y: Theme.geometry.overviewPage.widget.extraContent.topMargin
			width: parent ? parent.width - 2*Theme.geometry.overviewPage.widget.content.horizontalMargin : 0
			elide: Text.ElideRight

			//: Shows the amount of time that has passed since the generator was stopped
			//% "Stopped %1"
			text: qsTrId("overview_acinputwidget_generator_stopped")
					.arg(Utils.formatAsHHMMSS(Global.generators.first ? Global.generators.first.runtime : 0))
			color: Theme.color.font.secondary
		}
	]
}
