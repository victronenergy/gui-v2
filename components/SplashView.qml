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

		running: Global.allPagesLoaded

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
		indeterminate: visible && BackendConnection.state !== BackendConnection.Failed
	}

	Column {
		anchors {
			top: loadingProgress.bottom
			topMargin: Theme.geometry.splashView.progressText.topMargin
			left: parent.left
			leftMargin: Theme.geometry.page.content.horizontalMargin
			right: parent.right
			rightMargin: Theme.geometry.page.content.horizontalMargin
		}
		opacity: BackendConnection.state === BackendConnection.Failed ? 1.0 : loadingProgress.opacity
		visible: BackendConnection.type === BackendConnection.MqttSource

		Item {
			id: alarmIconContainer

			width: parent.width
			height: 0
			opacity: 0

			states: State {
				name: "alarm"
				when: BackendConnection.state >= BackendConnection.Disconnected || mqttErrorLabel.text.length > 0
				PropertyChanges {
					target: alarmIconContainer
					opacity: 1.0
					height: Theme.geometry.splashView.progressIconContainer.size
				}
			}
			transitions: Transition {
				from: ""; to: "alarm"
				NumberAnimation { properties: "opacity,height" }
			}

			CP.ColorImage {
				anchors.centerIn: parent
				sourceSize.width: 24
				sourceSize.height: 24
				source: "qrc:/images/icon_alarm_48.svg"
				color: Theme.color.red
			}
		}

		Label {
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			height: implicitHeight + Theme.geometry.splashView.progressText.spacing
			font.pixelSize: Theme.font.splashView.progressText.size
			color: Theme.color.font.secondary
			wrapMode: Text.Wrap
			text: "[" + BackendConnection.state + "] "
				  //% "Unable to connect"
				+ (BackendConnection.state === BackendConnection.Failed ? qsTrId("splash_view_unable_to_connect")
				  //% "Disconnected, attempting to reconnect"
				: BackendConnection.state === BackendConnection.Reconnecting ? qsTrId("splash_view_reconnecting")
				   //% "Disconnected"
				: BackendConnection.state === BackendConnection.Disconnected ? qsTrId("splash_view_disconnected")
				  //% "Connecting"
				: BackendConnection.state === BackendConnection.Connecting ? qsTrId("splash_view_connecting")
				  //% "Connected, awaiting broker messages"
				: BackendConnection.state === BackendConnection.Connected ? qsTrId("splash_view_connected")
				  //% "Connected, receiving broker messages"
				: BackendConnection.state === BackendConnection.Initializing ? qsTrId("splash_view_initializing")
				  //% "Connected, loading user interface"
				: BackendConnection.state === BackendConnection.Ready ? qsTrId("splash_view_ready")
				  //% "Idle"
				: qsTrId("splash_view_idle"))
		}

		Label {
			id: mqttErrorLabel

			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			font.pixelSize: Theme.font.splashView.progressText.size
			color: Theme.color.font.secondary
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
	}
}
