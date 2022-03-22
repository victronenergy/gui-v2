/*!
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Flickable {
	id: root

	width: parent.width
	height: parent.height
	contentWidth: contentRow.width
	leftMargin: contentRow.width > width
			? Theme.geometry.levelsPage.environment.minimumHorizontalMargin
			: (width - contentRow.width) / 2
	boundsBehavior: Flickable.StopAtBounds

	Row {
		id: contentRow

		height: parent.height

		spacing: {
			if (levelsRepeater.count === 0) {
				return 0
			}
			// Find a spacing between panels that is within the min/max spacing range.
			const availableWidth = root.width - Theme.geometry.levelsPage.environment.minimumHorizontalMargin*2
			let panelWidths = 0
			for (let i = 0; i < levelsRepeater.count; ++i) {
				panelWidths += levelsRepeater.itemAt(i).width
			}
			let candidateSpacing = Math.max(Theme.geometry.levelsPage.environment.minimumSpacing,
					Math.min(Theme.geometry.levelsPage.environment.maximumSpacing, (availableWidth - panelWidths) / (levelsRepeater.count-1)))

			// If the spacing is larger than the horizontal margin, use the horizontal margin as
			// the spacing instead, otherwise looks odd when panels are pushed to edges.
			let requiredAreaWidth = panelWidths + ((levelsRepeater.count-1) * candidateSpacing)
			let candidateHorizontalMargin = (root.width - requiredAreaWidth) / 2
			if (candidateSpacing > candidateHorizontalMargin) {
				candidateSpacing = candidateHorizontalMargin
			}
			return Math.max(Theme.geometry.levelsPage.environment.minimumSpacing, candidateSpacing)
		}

		Repeater {
			id: levelsRepeater
			model: environmentLevels.model

			delegate: EnvironmentGaugePanel {
				horizontalSize: {
					if (levelsRepeater.count === 0) {
						return EnvironmentGaugePanel.Size.Expanded
					}
					// If available area is not big enough to fit all the panels at their max width,
					// use a compact (reduced) width for two-gauge panels.
					const availableAreaWidth = root.width - Theme.geometry.levelsPage.environment.minimumHorizontalMargin*2
					let panelWidths = 0
					for (let i = 0; i < levelsRepeater.count; ++i) {
						panelWidths += levelsRepeater.itemAt(i).expandedWidth
					}
					const requiredAreaWidth = panelWidths + ((levelsRepeater.count-1) * Theme.geometry.levelsPage.environment.minimumSpacing)
					return requiredAreaWidth > availableAreaWidth
							? EnvironmentGaugePanel.Size.Compact
							: EnvironmentGaugePanel.Size.Expanded
				}
				verticalSize: PageManager.interactivity === PageManager.InteractionMode.Idle
						? EnvironmentGaugePanel.Size.Expanded
						: EnvironmentGaugePanel.Size.Compact
				title: model.input.customName || model.input.productName || ""
				temperature: model.input.temperature
				humidity: model.input.humidity
			}
		}
	}
}
