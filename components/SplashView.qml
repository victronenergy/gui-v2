/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Rectangle {
	id: root

	color: Theme.color_background_primary
	visible: Global.splashScreenVisible

	OpacityAnimator on opacity {
		id: fadeOutAnim

		running: false
		to: 0
		duration: Theme.animation_splash_fade_duration
		onRunningChanged: {
			if (!running) {
				Global.splashScreenVisible = false
				// reset the state variables we animated.
				logoIcon.opacity = 1.0
				logoText.opacity = 1.0
				extraInfoColumn.nextOpacity = 1.0
				loadingProgress.opacity = 1.0
				loadingProgress.visible = true
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
				} else if (BackendConnection.state === BackendConnection.Ready) {
					animatedLogo.playing = true
				}
			}
		}
	}

	SequentialAnimation {
		id: initialFadeAnimation

		running: Global.allPagesLoaded

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
				when: BackendConnection.state >= BackendConnection.Disconnected || mqttErrorLabel.text.length > 0
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
				color: Theme.color_red
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
				  //% "Connected, loading user interface"
				: BackendConnection.state === BackendConnection.Ready ? qsTrId("splash_view_ready")
				: CommonWords.idle)
		}

		Label {
			id: mqttErrorLabel

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
	}
}
