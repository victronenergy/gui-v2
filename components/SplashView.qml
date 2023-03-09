/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Rectangle {
	id: root

	color: Theme.color.background.primary
	visible: Global.splashScreenVisible

	OpacityAnimator on opacity {
		id: fadeOutAnim

		running: false
		to: 0
		duration: Theme.animation.splash.fade.duration
		onRunningChanged: {
			if (!running) {
				Global.splashScreenVisible = false
			}
		}
	}

	AnimatedImage {
		id: animatedLogo

		anchors {
			centerIn: parent
			verticalCenterOffset: Theme.geometry.splashView.gaugeAnimation.verticalCenterOffset
		}

		playing: false
		cache: false
		paused: currentFrame === Theme.animation.splash.gaugeAnimation.fadeFrame
		onPausedChanged: {
			if (paused) {
				fadeOutAnim.start()
			}
		}

		source: Theme.colorScheme === Theme.Light
				? Theme.screenSize === Theme.SevenInch
				  ? "qrc:/images/gauge_intro_7_matte_white.gif"
				  : "qrc:/images/gauge_intro_5_matte_white.gif"
				: Theme.screenSize === Theme.SevenInch
				  ? "qrc:/images/gauge_intro_7_matte_black.gif"
				  : "qrc:/images/gauge_intro_5_matte_black.gif"
	}

	CP.ColorImage {
		id: logoIcon

		anchors {
			centerIn: parent
			verticalCenterOffset: Theme.geometry.splashView.logo.verticalCenterOffset
			horizontalCenterOffset: Theme.geometry.splashView.logo.horizontalCenterOffset
		}
		source: Theme.screenSize === Theme.FiveInch
				? "qrc:/images/splash-logo-icon-5inch.svg"
				: "qrc:/images/splash-logo-icon-7inch.svg"
		color: Theme.color.splash.logo

		OpacityAnimator on opacity {
			id: logoIconFadeOutAnim

			running: false
			to: 0
			duration: Theme.animation.splash.logoIcon.fade.duration
		}
	}

	CP.ColorImage {
		id: logoText

		anchors {
			centerIn: parent
			verticalCenterOffset: Theme.geometry.splashView.logo.verticalCenterOffset
			horizontalCenterOffset: Theme.geometry.splashView.logo.horizontalCenterOffset
		}
		source: Theme.screenSize === Theme.FiveInch
				? "qrc:/images/splash-logo-text-5inch.svg"
				: "qrc:/images/splash-logo-text-7inch.svg"
		color: Theme.color.splash.logo

		OpacityAnimator on opacity {
			id: logoTextFadeOutAnim

			running: false
			to: 0
			duration: Theme.animation.splash.logoText.fade.duration

			onRunningChanged: {
				if (running) {
					logoIconFadeOutAnim.running = true
				} else if (BackendConnection.state === BackendConnection.Ready) {
					animatedLogo.playing = true
				}
			}
		}
	}

	SequentialAnimation {
		id: initialFadeAnimation

		running: Global.allPagesLoaded || BackendConnection.state === BackendConnection.Failed

		NumberAnimation {
			target: loadingProgress
			property: "opacity"
			from: 1; to: 0
			duration: Theme.animation.splash.progressBar.fade.duration
		}
		PropertyAction {
			target: loadingProgress
			property: "visible"
			value: false
		}
		PauseAnimation {
			duration: Theme.animation.splash.logo.preFadePause.duration
		}
		PropertyAction {
			target: logoTextFadeOutAnim
			property: "running"
			value: true
		}
	}

	ProgressBar {
		id: loadingProgress

		anchors {
			bottom: parent.bottom
			bottomMargin: Theme.geometry.splashView.progressBar.bottomMargin
			horizontalCenter: parent.horizontalCenter
		}
		width: Theme.geometry.splashView.progressBar.width
		indeterminate: visible
	}

	Label {
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: loadingProgress.bottom
			topMargin: Theme.geometry.progressBar.height
		}
		opacity: BackendConnection.state === BackendConnection.Failed ? 1.0 : loadingProgress.opacity
		font.pixelSize: Theme.font.size.caption
		color: Theme.color.font.secondary
		text: //% "Unable to connect"
			 ((BackendConnection.state === BackendConnection.Failed ? qsTrId("splash_view_unable_to_connect")
			  //% "Disconnected, attempting to reconnect"
			: BackendConnection.state === BackendConnection.Disconnected ? qsTrId("splash_view_disconnected")
			  //% "Connecting"
			: BackendConnection.state === BackendConnection.Connecting ? qsTrId("splash_view_connecting")
			  //% "Connected, awaiting broker messages"
			: BackendConnection.state === BackendConnection.Connected ? qsTrId("splash_view_connected")
			  //% "Connected, loading user interface"
			: BackendConnection.state === BackendConnection.Ready ? qsTrId("splash_view_ready")
			  //% "Idle"
			: qsTrId("splash_view_idle")) + " [" + BackendConnection.state) + "]"
	}
}
