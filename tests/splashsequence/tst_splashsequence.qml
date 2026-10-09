/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtTest

TestCase {
	id: root
	name: "SplashSequenceTest"

	property var _sequences: []

	Component {
		id: sequenceComponent
		SplashSequence {}
	}

	function createSequence(props) {
		const sequence = sequenceComponent.createObject(root, props)
		verify(sequence)
		_sequences.push(sequence)
		return sequence
	}

	function init() {
		_sequences = []
	}

	function cleanup() {
		for (let i = 0; i < _sequences.length; ++i) {
			const sequence = _sequences[i]
			if (sequence) {
				sequence.destroy()
			}
		}
		_sequences = []
	}

	function test_staysWaitingUntilPagesAndDataAreReady() {
		const sequence = createSequence({ ready: true, showAnimation: true })
		compare(sequence.phase, VenusOS.Splash_Phase_Waiting)

		sequence.pagesLoaded = true
		compare(sequence.phase, VenusOS.Splash_Phase_Waiting)

		sequence.dataReady = true
		compare(sequence.phase, VenusOS.Splash_Phase_HidingProgress)
	}

	function test_animationOffHidesWhenPagesLoad() {
		const sequence = createSequence({
			ready: true,
			showAnimation: false,
			pagesLoaded: true,
		})
		compare(sequence.phase, VenusOS.Splash_Phase_Hidden)
	}

	function test_welcomeBlocksAnimationOffHide() {
		const sequence = createSequence({
			ready: true,
			showAnimation: false,
			pagesLoaded: true,
			dataReady: true,
			welcomeActive: true,
		})
		compare(sequence.phase, VenusOS.Splash_Phase_Waiting)

		sequence.welcomeActive = false
		compare(sequence.phase, VenusOS.Splash_Phase_Hidden)
	}

	function test_welcomeReturnsLaterPhasesToWaiting() {
		const sequence = createSequence({
			ready: true,
			showAnimation: true,
			pagesLoaded: true,
			dataReady: true,
		})
		sequence.notifyProgressHidden()
		sequence.notifyLogoFaded()
		compare(sequence.phase, VenusOS.Splash_Phase_PlayingGauge)

		sequence.welcomeActive = true
		compare(sequence.phase, VenusOS.Splash_Phase_Waiting)
		sequence.notifyGaugePaused()
		sequence.notifyFadedOut()
		compare(sequence.phase, VenusOS.Splash_Phase_Waiting)

		sequence.welcomeActive = false
		compare(sequence.phase, VenusOS.Splash_Phase_HidingProgress)

		sequence.preloadComplete = true
		sequence.notifyProgressHidden()
		sequence.notifyLogoFaded()
		sequence.notifyGaugePaused()
		compare(sequence.phase, VenusOS.Splash_Phase_FadingOut)

		sequence.welcomeActive = true
		compare(sequence.phase, VenusOS.Splash_Phase_Waiting)
		sequence.notifyFadedOut()
		compare(sequence.phase, VenusOS.Splash_Phase_Waiting)
	}

	function test_welcomeBlocksProgressHide() {
		const sequence = createSequence({
			ready: true,
			showAnimation: true,
			pagesLoaded: true,
			dataReady: true,
			welcomeActive: true,
		})
		compare(sequence.phase, VenusOS.Splash_Phase_Waiting)

		sequence.welcomeActive = false
		compare(sequence.phase, VenusOS.Splash_Phase_HidingProgress)
	}

	function test_stepsFollowAnimationCompletions() {
		const sequence = createSequence({
			ready: true,
			showAnimation: true,
			pagesLoaded: true,
			dataReady: true,
		})
		compare(sequence.phase, VenusOS.Splash_Phase_HidingProgress)

		sequence.notifyProgressHidden()
		compare(sequence.phase, VenusOS.Splash_Phase_FadingLogo)

		sequence.notifyLogoFaded()
		compare(sequence.phase, VenusOS.Splash_Phase_PlayingGauge)

		sequence.preloadComplete = true
		compare(sequence.phase, VenusOS.Splash_Phase_PlayingGauge)

		sequence.notifyGaugePaused()
		compare(sequence.phase, VenusOS.Splash_Phase_FadingOut)

		sequence.notifyFadedOut()
		compare(sequence.phase, VenusOS.Splash_Phase_Hidden)
	}

	function test_gaugePauseWaitsForPreload() {
		const sequence = createSequence({
			ready: true,
			showAnimation: true,
			pagesLoaded: true,
			dataReady: true,
		})
		sequence.notifyProgressHidden()
		sequence.notifyLogoFaded()
		sequence.notifyGaugePaused()
		compare(sequence.phase, VenusOS.Splash_Phase_WaitingForPreload)

		sequence.preloadComplete = true
		compare(sequence.phase, VenusOS.Splash_Phase_FadingOut)
	}

	function test_lateNotificationsAreIgnored() {
		const sequence = createSequence({ ready: true })
		sequence.notifyLogoFaded()
		sequence.notifyGaugePaused()
		sequence.notifyFadedOut()
		compare(sequence.phase, VenusOS.Splash_Phase_Waiting)

		sequence.showAnimation = true
		sequence.pagesLoaded = true
		sequence.dataReady = true
		sequence.notifyLogoFaded()
		compare(sequence.phase, VenusOS.Splash_Phase_HidingProgress)
	}

	function test_rebuildReturnsToWaiting() {
		const sequence = createSequence({
			ready: true,
			showAnimation: true,
			pagesLoaded: true,
			dataReady: true,
		})
		sequence.notifyProgressHidden()
		compare(sequence.phase, VenusOS.Splash_Phase_FadingLogo)

		sequence.pagesLoaded = false
		sequence.dataReady = false
		compare(sequence.phase, VenusOS.Splash_Phase_Waiting)

		sequence.notifyLogoFaded()
		compare(sequence.phase, VenusOS.Splash_Phase_Waiting)

		sequence.pagesLoaded = true
		sequence.dataReady = true
		compare(sequence.phase, VenusOS.Splash_Phase_HidingProgress)
	}

	function test_doesNotEvaluateBeforeReady() {
		const sequence = createSequence({
			ready: false,
			showAnimation: false,
			pagesLoaded: true,
		})
		compare(sequence.phase, VenusOS.Splash_Phase_Waiting)

		sequence.ready = true
		compare(sequence.phase, VenusOS.Splash_Phase_Hidden)
	}

	function test_skipSplashDoesNotAdvance() {
		const sequence = createSequence({
			ready: true,
			splashVisible: false,
			showAnimation: true,
			pagesLoaded: true,
			dataReady: true,
		})
		compare(sequence.phase, VenusOS.Splash_Phase_Waiting)
	}
}
