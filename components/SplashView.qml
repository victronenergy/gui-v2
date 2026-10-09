/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Rectangle {
	id: root

	color: Theme.color_page_background
	visible: UiConfig.splashScreenVisible

	// Phase changes start the matching animation. Completion handlers below
	// report back to the sequence; they do not start the next animation.
	SplashSequence {
		id: sequence

		splashVisible: UiConfig.splashScreenVisible
		showAnimation: UiConfig.showSplashAnimation
		pagesLoaded: Global.allPagesLoaded
		dataReady: Global.dataManagerLoaded
		// Same condition as welcomeLoader.active. This object is created first,
		// so it must not reference the loader id.
		welcomeActive: Global.dataManagerLoaded && Global.systemSettings.needsOnboarding
		preloadComplete: Global.pagePreloadComplete

		onPhaseChanged: root._applyPhase(phase)
	}

	readonly property bool pagePreloadComplete: Global.pagePreloadComplete
	onPagePreloadCompleteChanged: {
		if (pagePreloadComplete) {
			console.info("SplashView: page preload complete")
		}
	}

	// Backstop if the gauge has paused and PagePreloader has not finished.
	Timer {
		interval: 16000
		running: sequence.phase === VenusOS.Splash_Phase_WaitingForPreload
		onTriggered: {
			console.warn("SplashView: page preload wait timed out")
			Global.pagePreloadComplete = true
		}
	}

	Component.onCompleted: sequence.ready = true

	function hideSplashView() {
		console.info("SplashView: UI ready; hiding splash view")
		if (!Global.pagePreloadComplete) {
			Global.pagePreloadComplete = true
		}
		UiConfig.splashScreenVisible = false
		// reset the state variables we animated.
		logoIcon.opacity = 1.0
		logoText.opacity = 1.0
		extraInfoColumn.nextOpacity = 1.0
		loadingProgress.opacity = 1.0
		loadingProgress.visible = true
	}

	function _applyPhase(phase) {
		_stopAnimationsForOtherPhases(phase)
		switch (phase) {
		case VenusOS.Splash_Phase_Waiting:
			_restoreLoadingChrome()
			break
		case VenusOS.Splash_Phase_HidingProgress:
			console.info("SplashView: application content pages have loaded, running initial fade animation")
			initialFadeAnimation.start()
			break
		case VenusOS.Splash_Phase_FadingLogo:
			console.info("SplashView: fading out logo text")
			logoIconFadeOutAnim.running = true
			logoTextFadeOutAnim.running = true
			break
		case VenusOS.Splash_Phase_PlayingGauge:
			if (Global.backendReady || Global.backendReadyLatched) {
				console.info("SplashView: finished fading out logo text")
			} else {
				// Should not happen: the logo fade starts only after data is ready.
				// Keep going so the splash cannot get stuck.
				console.info("SplashView: fading out logo text but backend is not ready!")
			}
			animatedLogo.playing = true
			if (animatedLogo.paused) {
				sequence.notifyGaugePaused()
			}
			break
		case VenusOS.Splash_Phase_WaitingForPreload:
			console.info("SplashView: waiting for page preload before fade out")
			break
		case VenusOS.Splash_Phase_FadingOut:
			console.info("SplashView: playing view opacity fade out animation")
			fadeOutAnim.running = true
			break
		case VenusOS.Splash_Phase_Hidden:
			hideSplashView()
			break
		}
	}

	function _stopAnimationsForOtherPhases(phase) {
		if (phase !== VenusOS.Splash_Phase_HidingProgress && initialFadeAnimation.running) {
			initialFadeAnimation.stop()
		}
		if (phase !== VenusOS.Splash_Phase_FadingLogo) {
			if (logoTextFadeOutAnim.running) {
				logoTextFadeOutAnim.running = false
			}
			if (logoIconFadeOutAnim.running) {
				logoIconFadeOutAnim.running = false
			}
		}
		if (phase !== VenusOS.Splash_Phase_FadingOut && fadeOutAnim.running) {
			fadeOutAnim.running = false
		}
		if (phase !== VenusOS.Splash_Phase_PlayingGauge
				&& phase !== VenusOS.Splash_Phase_WaitingForPreload
				&& phase !== VenusOS.Splash_Phase_FadingOut
				&& phase !== VenusOS.Splash_Phase_Hidden) {
			animatedLogo.playing = false
		}
	}

	function _restoreLoadingChrome() {
		root.opacity = 1.0
		logoIcon.opacity = 1.0
		logoText.opacity = 1.0
		extraInfoColumn.nextOpacity = 1.0
		loadingProgress.opacity = 1.0
		loadingProgress.visible = true
		animatedLogo.playing = false
		animatedLogo.currentFrame = 0
	}

	OpacityAnimator on opacity {
		id: fadeOutAnim

		running: false
		to: 0
		duration: Theme.animation_splash_fade_duration
		onRunningChanged: {
			if (running || sequence.phase !== VenusOS.Splash_Phase_FadingOut) {
				return
			}
			console.info("SplashView: finished view opacity fade out animation")
			sequence.notifyFadedOut()
		}
	}

	AnimatedImage {
		id: animatedLogo

		anchors {
			centerIn: parent
			verticalCenterOffset: Theme.geometry_splashView_gaugeAnimation_verticalCenterOffset
		}

		playing: false
		onPlayingChanged: {
			if (playing) {
				console.info("SplashView: playing gauge gif animation")
			}
		}
		cache: false
		paused: currentFrame === Theme.animation_splash_gaugeAnimation_fadeFrame
		onPausedChanged: {
			if (!paused) {
				return
			}
			console.info("SplashView: finished gauge gif animation")
			if (sequence.phase === VenusOS.Splash_Phase_PlayingGauge) {
				sequence.notifyGaugePaused()
			}
		}

		source: !UiConfig.showSplashAnimation ? ""
			: Theme.colorScheme === Theme.Light
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
			verticalCenterOffset: Theme.geometry_splashView_logo_verticalCenterOffset
			horizontalCenterOffset: Theme.geometry_splashView_logo_horizontalCenterOffset
		}
		source: "qrc:/images/splash-logo-icon.svg"
		color: Theme.color_splash_logo_icon
		width: Theme.geometry_splashScreen_logo_width
		height: Theme.geometry_splashScreen_logo_height
		sourceSize: Qt.size(width, height)

		OpacityAnimator on opacity {
			id: logoIconFadeOutAnim

			running: false
			to: 0
			duration: Theme.animation_splash_logoIcon_fade_duration
		}
	}

	CP.ColorImage {
		id: logoText

		anchors {
			centerIn: parent
			verticalCenterOffset: Theme.geometry_splashView_logo_verticalCenterOffset
			horizontalCenterOffset: Theme.geometry_splashView_logo_horizontalCenterOffset
		}
		source: "qrc:/images/splash-logo-text.svg"
		color: Theme.color_splash_logo_text
		width: Theme.geometry_splashScreen_logo_width
		height: Theme.geometry_splashScreen_logo_height
		sourceSize: Qt.size(width, height)

		OpacityAnimator on opacity {
			id: logoTextFadeOutAnim

			running: false
			to: 0
			duration: Theme.animation_splash_logoText_fade_duration

			onRunningChanged: {
				if (running || sequence.phase !== VenusOS.Splash_Phase_FadingLogo) {
					return
				}
				sequence.notifyLogoFaded()
			}
		}
	}

	SequentialAnimation {
		id: initialFadeAnimation

		onFinished: {
			if (sequence.phase !== VenusOS.Splash_Phase_HidingProgress) {
				return
			}
			console.info("SplashView: finished running initial fade animation")
			sequence.notifyProgressHidden()
		}

		PropertyAction {
			target: extraInfoColumn
			property: "nextOpacity"
			value: 0
		}
		PropertyAction {
			target: loadingProgress
			property: "opacity"
			value: 0
		}
		PropertyAction {
			target: loadingProgress
			property: "visible"
			value: false
		}
		PauseAnimation {
			duration: Theme.animation_splash_logo_preFadePause_duration
		}
	}

	ProgressBar {
		id: loadingProgress

		anchors {
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: Theme.geometry_splashView_progressBar_verticalCenterOffset
			horizontalCenter: parent.horizontalCenter
		}
		width: Math.min(Theme.geometry_splashView_progressBar_width, parent.width - 2 * Theme.geometry_page_content_horizontalMargin)
		indeterminate: visible && BackendConnection.state !== BackendConnection.Failed
		opacity: 1.0
		Behavior on opacity {
			OpacityAnimator {
				duration: Theme.animation_splash_progressBar_fade_duration
			}
		}
	}

	Column {
		id: extraInfoColumn
		anchors {
			top: loadingProgress.bottom
			topMargin: Theme.geometry_splashView_progressText_topMargin
			left: parent.left
			leftMargin: Theme.geometry_page_content_horizontalMargin
			right: parent.right
			rightMargin: Theme.geometry_page_content_horizontalMargin
		}
		visible: BackendConnection.type === BackendConnection.MqttSource
		property real nextOpacity: 1.0
		opacity: BackendConnection.state === BackendConnection.Failed ? 1.0 : nextOpacity
		Behavior on opacity {
			OpacityAnimator {
				duration: Theme.animation_splash_progressBar_fade_duration
			}
		}

		Item {
			id: alarmIconContainer

			width: parent.width
			height: 0
			opacity: 0

			states: State {
				name: "alarm"
				when: errorStateTimer.errorIsPersistent
					|| mqttErrorLabel.visible
					|| mqttHeartbeatLabel.visible
				PropertyChanges {
					target: alarmIconContainer
					opacity: 1.0
					height: Theme.geometry_splashView_progressIconContainer_size
				}
			}
			transitions: Transition {
				from: ""; to: "alarm"
				NumberAnimation { properties: "opacity,height" }
			}

			CP.ColorImage {
				anchors.centerIn: parent
				source: "qrc:/images/icon_warning_24.svg"
				color: (errorStateTimer.errorIsPersistent
						|| mqttErrorLabel.visible
						|| (BackendConnection.vrm && BackendConnection.heartbeatState === BackendConnection.HeartbeatInactive))
					? Theme.color_critical
					: Theme.color_warning
			}

			// Upon waking up a WASM tab, the websocket may have been dropped,
			// so there will be both an MQTT comms error and a disconnected -> reconnecting state change.
			// This is a common case, so we shouldn't alarm the user and show the warning labels
			// unless reconnection fails (Serj suggested waiting for 3 seconds).
			Timer {
				id: errorStateTimer
				interval: 3000
				property bool errorIsPersistent
				property bool stateIsError: BackendConnection.state >= BackendConnection.Disconnected
				onStateIsErrorChanged: {
					if (stateIsError) {
						start()
					} else {
						errorIsPersistent = false
					}
				}
				onTriggered: errorIsPersistent = true
			}
		}

		Label {
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			height: implicitHeight + Theme.geometry_splashView_progressText_spacing
			font.pixelSize: Theme.font_splashView_progressText_size
			color: Theme.color_font_secondary
			wrapMode: Text.Wrap
			text: "[" + BackendConnection.state + "] "
				  //% "Unable to connect"
				+ (BackendConnection.state === BackendConnection.Failed ? qsTrId("splash_view_unable_to_connect")
				  //% "Disconnected, attempting to reconnect"
				: BackendConnection.state === BackendConnection.Reconnecting ? qsTrId("splash_view_reconnecting")
				: BackendConnection.state === BackendConnection.Disconnected ? CommonWords.disconnected
				  //% "Connecting"
				: BackendConnection.state === BackendConnection.Connecting ? qsTrId("splash_view_connecting")
				  //% "Connected, awaiting broker messages"
				: BackendConnection.state === BackendConnection.Connected ? qsTrId("splash_view_connected")
				  //% "Connected, receiving broker messages"
				: BackendConnection.state === BackendConnection.Initializing ? qsTrId("splash_view_initializing")
				: BackendConnection.state === BackendConnection.Ready
					? (BackendConnection.vrm && BackendConnection.heartbeatState !== BackendConnection.HeartbeatActive)
						? Global.backendReadyLatched // whether we ever had an active heartbeat
							  //% "Connection to the device has been lost, awaiting reconnection"
							? qsTrId("splash_view_device_disconnected")
							  //% "Connected to VRM, awaiting device"
							: qsTrId("splash_view_awaiting_heartbeat")
						  //% "Connected, loading user interface"
						: qsTrId("splash_view_ready")
				: CommonWords.idle)
		}

		Label {
			id: mqttErrorLabel

			visible: text.length > 0 && errorStateTimer.errorIsPersistent
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			font.pixelSize: Theme.font_splashView_progressText_size
			color: Theme.color_font_secondary
			wrapMode: Text.Wrap
			text: (BackendConnection.mqttClientError !== BackendConnection.MqttClient_NoError
				  ? "[" + BackendConnection.mqttClientError + "] " : "")
				  //% "Invalid protocol version"
				+ (BackendConnection.mqttClientError === BackendConnection.MqttClient_InvalidProtocolVersion ? qsTrId("splash_view_invalid_protocol_version")
				  //% "Client ID rejected"
				: BackendConnection.mqttClientError === BackendConnection.MqttClient_IdRejected ? qsTrId("splash_view_client_id_rejected")
				   //% "Broker service not available"
				: BackendConnection.mqttClientError === BackendConnection.MqttClient_ServerUnavailable ? qsTrId("splash_view_server_unavailable")
				  //% "Bad username or password"
				: BackendConnection.mqttClientError === BackendConnection.MqttClient_BadUsernameOrPassword ? qsTrId("splash_view_bad_username_or_password")
				  //% "Client not authorized"
				: BackendConnection.mqttClientError === BackendConnection.MqttClient_NotAuthorized ? qsTrId("splash_view_not_authorized")
				  //% "Transport connection error"
				: BackendConnection.mqttClientError === BackendConnection.MqttClient_TransportInvalid ? qsTrId("splash_view_transport_invalid")
				  //% "Protocol violation error"
				: BackendConnection.mqttClientError === BackendConnection.MqttClient_ProtocolViolation ? qsTrId("splash_view_protocol_violation")
				  //% "Unknown error"
				: BackendConnection.mqttClientError === BackendConnection.MqttClient_UnknownError ? qsTrId("splash_view_unknown_error")
				  //% "MQTT protocol level 5 error"
				: BackendConnection.mqttClientError === BackendConnection.MqttClient_Mqtt5SpecificError ? qsTrId("splash_view_mqtt5_error")
				: "")
		}

		Label {
			id: mqttHeartbeatLabel

			visible: false
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			font.pixelSize: Theme.font_splashView_progressText_size
			color: Theme.color_font_secondary
			wrapMode: Text.Wrap
			text: "[" + BackendConnection.heartbeatState + "] "
				+ (BackendConnection.heartbeatState === BackendConnection.HeartbeatMissing
				  //% "Device may have lost connectivity to VRM"
				? qsTrId("splash_view_heartbeat_missing")
				  //% "Device is not connected to VRM"
				: qsTrId("splash_view_heartbeat_inactive"))

			// if we successfully connected to VRM but the device isn't available, show a message.
			property bool heartbeatError: BackendConnection.vrm
				&& (BackendConnection.state === BackendConnection.Connected
					|| BackendConnection.state === BackendConnection.Initializing
					|| BackendConnection.state === BackendConnection.Ready)
				&& BackendConnection.heartbeatState !== BackendConnection.HeartbeatActive

			onHeartbeatErrorChanged: {
				if (heartbeatError) {
					awaitInitialHeartbeatTimer.start()
				} else {
					awaitInitialHeartbeatTimer.stop()
					mqttHeartbeatLabel.visible = false
				}
			}

			// When we first connect, it can take some time before we will receive
			// the first heartbeat message from the device, as we will receive
			// that one after all other initial messages are received (and parsed).
			// We should NOT show the error label during this waiting period.
			Timer {
				id: awaitInitialHeartbeatTimer
				interval: 8000
				onTriggered: mqttHeartbeatLabel.visible = true
			}
		}
	}

	Loader {
		id: welcomeLoader

		active: Global.dataManagerLoaded && Global.systemSettings.needsOnboarding
		anchors.fill: parent
		sourceComponent: WelcomeView {
			anchors.centerIn: parent
		}
		onLoaded: {
			// If the welcome screen is shown, force the splash animation to be shown even on wasm
			// so that there is a nicer transition from the welcome to the main screen.
			console.info("SplashView: welcome view loaded, starting splash animation")
			UiConfig.showSplashAnimation = true
		}
	}
}
