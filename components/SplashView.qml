/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

Item {
	id: root

	signal hideSplash()

	Image {
		id: logoImage
		anchors {
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: Theme.geometry.splashView.verticalCenterOffset
			left: parent.left
			leftMargin: (parent.width - (logoImage.width + logoText.width)) / 2
		}
		source: Theme.screenSize === Theme.FiveInch ? "qrc:/images/splash-logo-only-5inch.svg"
			: "qrc:/images/splash-logo-only-7inch.svg"
		Behavior on opacity { OpacityAnimator { duration: Theme.animation.splash.itemFade.duration } }
	}

	Image {
		id: logoText
		anchors {
			top: logoImage.top
			right: parent.right
			rightMargin: (parent.width - (logoImage.width + logoText.width)) / 2
		}
		source: Theme.screenSize === Theme.FiveInch ? "qrc:/images/splash-logo-text-5inch.svg"
			: "qrc:/images/splash-logo-text-7inch.svg"
		Behavior on opacity { OpacityAnimator { duration: Theme.animation.splash.itemFade.duration } }
	}

	ProgressBar {
		id: progress
		anchors {
			top: logoImage.bottom
			topMargin: Theme.geometry.splashView.spacing
			horizontalCenter: parent.horizontalCenter
		}
		width: Theme.geometry.splashView.progressBar.width
		indeterminate: root.visible
		Behavior on opacity { OpacityAnimator { duration: Theme.animation.splash.itemFade.duration } }
	}

	AnimatedImage {
		id: animation
		anchors.centerIn: parent
		opacity: playing ? 1.0 : 0.0
		source: "qrc:/images/splash-anim.gif" // TODO: // Theme.screenSize === Theme.FiveInch ? "qrc:/images/splash-anim-7inch.gif" : "qrc:/images/splash-anim-7inch.gif"
		playing: false
		paused: currentFrame === 74 // frameCount === (currentFrame+1) // we pause at the "height" of the animation for smooth cross-fade.  NOTE: animation-specific value!
		onPausedChanged: if (paused) root.hideSplash()
		Behavior on opacity { OpacityAnimator { duration: Theme.animation.splash.fade.duration } } // TODO: won't be needed once we have an animation gif with transparent background
	}

	Timer {
		id: splashProgressTimer
		interval: Theme.animation.splash.progress.duration
		running: true
		repeat: false
		property bool pagesLoaded: false
		property int step: 0
		onTriggered: {
			if (step === 0) {
				if (pagesLoaded) {
					// first, fade out the progress bar
					step = 1
					interval = Theme.animation.splash.fade.duration // Note: deliberately longer than itemFade duration.
					progress.opacity = 0.0
				}
				splashProgressTimer.restart()
			} else if (step === 1) {
				// second, fade out the logo label
				logoText.opacity = 0.0
				splashProgressTimer.restart()
				step = 2
			} else {
				// third, fade out the logo image and play the transition animation
				logoImage.opacity = 0.0
				animation.playing = true
			}
		}
	}

	Connections {
		ignoreUnknownSignals: true // SplashView gets created before PageManager - suppress warning messages about "no signal of the target matches the name"
		target: Global.pageManager.emitter
		function onAllPagesLoaded() {
			splashProgressTimer.pagesLoaded = true
		}
	}
}
