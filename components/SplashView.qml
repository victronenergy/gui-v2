/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Rectangle {
	id: root

	// Skip the fade and logo animations on WebAssembly as startup speed is more important.
	property bool showSplashAnimation: Qt.platform.os != "wasm"
	readonly property bool allPagesLoaded: Global.allPagesLoaded

	color: Theme.color_background_primary
	visible: Global.splashScreenVisible

	onAllPagesLoadedChanged: {
		if (!showSplashAnimation) {
			hideSplashView()
		}
	}

	function hideSplashView() {
		Global.splashScreenVisible = false
		// reset the state variables we animated.
		logoIcon.opacity = 1.0
		logoText.opacity = 1.0
		extraInfoColumn.nextOpacity = 1.0
		loadingProgress.opacity = 1.0
		loadingProgress.visible = true
	}

	OpacityAnimator on opacity {
		id: fadeOutAnim

		running: false
		to: 0
		duration: Theme.animation_splash_fade_duration
		onRunningChanged: {
			if (!running) {
				root.hideSplashView()
			}
		}
	}

	AnimatedImage {
		id: animatedLogo

		anchors {
			centerIn: parent
			verticalCenterOffset: Theme.geometry_splashView_gaugeAnimation_verticalCenterOffset
		}

		playing: false
		cache: false
		paused: currentFrame === Theme.animation_splash_gaugeAnimation_fadeFrame
		onPausedChanged: {
			if (paused) {
				fadeOutAnim.start()
			}
		}

		source: !root.showSplashAnimation ? ""
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
		source: Theme.screenSize === Theme.FiveInch
				? "qrc:/images/splash-logo-icon-5inch.svg"
				: "qrc:/images/splash-logo-icon-7inch.svg"
		color: Theme.color_splash_logo

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
		source: Theme.screenSize === Theme.FiveInch
				? "qrc:/images/splash-logo-text-5inch.svg"
				: "qrc:/images/splash-logo-text-7inch.svg"
		color: Theme.color_splash_logo

		OpacityAnimator on opacity {
			id: logoTextFadeOutAnim

			running: false
			to: 0
			duration: Theme.animation_splash_logoText_fade_duration

			onRunningChanged: {
				if (running) {
					logoIconFadeOutAnim.running = true
				} else if (Global.backendReady) {
					animatedLogo.playing = true
				}
			}
		}
	}

	SequentialAnimation {
		id: initialFadeAnimation

		running: Global.dataManagerLoaded && !welcomeLoader.active && Global.allPagesLoaded && root.showSplashAnimation
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
			bottomMargin: Theme.geometry_splashView_progressBar_bottomMargin
			horizontalCenter: parent.horizontalCenter
		}
		width: Theme.geometry_splashView_progressBar_width
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
			root.showSplashAnimation = true
		}
	}
}
