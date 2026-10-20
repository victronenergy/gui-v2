/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Splash phase machine. SplashView plays the animation for the current phase
	and reports when that step finishes. This object decides the next phase.

	Waiting
	  -> Hidden             pages are loaded, animation is off, welcome is not showing
	  -> HidingProgress     pages and data are ready, animation is on, welcome is not showing
	HidingProgress -> FadingLogo          progress hide/pause finished
	FadingLogo     -> PlayingGauge        logo fade finished
	PlayingGauge   -> FadingOut           gauge paused and page preload is done
				   -> WaitingForPreload   gauge paused and page preload is not done
	WaitingForPreload -> FadingOut        page preload finished
	FadingOut      -> Hidden              opacity fade finished

	A UI rebuild that clears pages or data returns an in-progress sequence to Waiting.
	--skip-splash hides the splash without completing the sequence. If that happens
	after a step has started, return to Waiting instead of continuing.
	welcomeActive holds the sequence in Waiting. If it becomes active during any
	later phase, return to Waiting instead of continuing to Hidden.
	notify* calls from the wrong phase are ignored.
	A notify* call, or a flag change, made while the phase is changing (for example from an
	onPhaseChanged handler) runs as soon as that change has finished. Changing the phase
	from inside its own change would leave 'phase' on the old value.
	Evaluation waits until ready, so the view can finish creating the welcome loader first.
*/
QtObject {
	id: root

	property bool ready: false
	property bool splashVisible: true
	property bool showAnimation: true
	property bool pagesLoaded: false
	property bool dataReady: false
	property bool welcomeActive: false
	property bool preloadComplete: false

	readonly property int phase: _phase
	property int _phase: VenusOS.Splash_Phase_Waiting
	property bool _changingPhase: false
	property var _callsAfterPhaseChange: []

	Component.onCompleted: {
		if (ready) {
			_evaluate()
		}
	}

	onReadyChanged: {
		if (ready) {
			_evaluate()
		}
	}
	onSplashVisibleChanged: _evaluate()
	onShowAnimationChanged: _evaluate()
	onPagesLoadedChanged: _evaluate()
	onDataReadyChanged: _evaluate()
	onWelcomeActiveChanged: _evaluate()
	onPreloadCompleteChanged: _evaluate()

	function notifyProgressHidden() {
		if (_delayIfChangingPhase(notifyProgressHidden)
				|| _phase !== VenusOS.Splash_Phase_HidingProgress) {
			return
		}
		_enter(VenusOS.Splash_Phase_FadingLogo)
	}

	function notifyLogoFaded() {
		if (_delayIfChangingPhase(notifyLogoFaded)
				|| _phase !== VenusOS.Splash_Phase_FadingLogo) {
			return
		}
		_enter(VenusOS.Splash_Phase_PlayingGauge)
	}

	function notifyGaugePaused() {
		if (_delayIfChangingPhase(notifyGaugePaused)
				|| _phase !== VenusOS.Splash_Phase_PlayingGauge) {
			return
		}
		if (preloadComplete) {
			_enter(VenusOS.Splash_Phase_FadingOut)
		} else {
			_enter(VenusOS.Splash_Phase_WaitingForPreload)
		}
	}

	function notifyFadedOut() {
		if (_delayIfChangingPhase(notifyFadedOut)
				|| _phase !== VenusOS.Splash_Phase_FadingOut) {
			return
		}
		_enter(VenusOS.Splash_Phase_Hidden)
	}

	function _evaluate() {
		if (_delayIfChangingPhase(_evaluate)
				|| !ready || _phase === VenusOS.Splash_Phase_Hidden) {
			return
		}
		// Visibility can be applied after other flags (createObject order, or
		// skipSplashScreen() after the view has already been created).
		if (!splashVisible) {
			if (_phase !== VenusOS.Splash_Phase_Waiting) {
				_enter(VenusOS.Splash_Phase_Waiting)
			}
			return
		}
		if (_phase !== VenusOS.Splash_Phase_Waiting && (!pagesLoaded || !dataReady)) {
			_enter(VenusOS.Splash_Phase_Waiting)
			return
		}
		// Welcome covers the splash. Skipping or continuing would hide the splash
		// and destroy the welcome view. Hold here until onboarding finishes.
		if (welcomeActive) {
			if (_phase !== VenusOS.Splash_Phase_Waiting) {
				_enter(VenusOS.Splash_Phase_Waiting)
			}
			return
		}
		if (_phase === VenusOS.Splash_Phase_Waiting) {
			if (!pagesLoaded) {
				return
			}
			if (!showAnimation) {
				_enter(VenusOS.Splash_Phase_Hidden)
				return
			}
			if (dataReady) {
				_enter(VenusOS.Splash_Phase_HidingProgress)
			}
			return
		}
		if (_phase === VenusOS.Splash_Phase_WaitingForPreload && preloadComplete) {
			_enter(VenusOS.Splash_Phase_FadingOut)
		}
	}

	function _enter(nextPhase) {
		if (_phase === nextPhase) {
			return
		}
		console.info("SplashSequence:", _phaseName(_phase), "->", _phaseName(nextPhase))
		_changingPhase = true
		_phase = nextPhase
		_changingPhase = false
		while (_callsAfterPhaseChange.length > 0) {
			const call = _callsAfterPhaseChange.shift()
			call()
		}
	}

	// Returns true if the call was saved to run after the current phase change.
	function _delayIfChangingPhase(call) {
		if (!_changingPhase) {
			return false
		}
		_callsAfterPhaseChange.push(call)
		return true
	}

	function _phaseName(phase) {
		switch (phase) {
		case VenusOS.Splash_Phase_Waiting:
			return "Waiting"
		case VenusOS.Splash_Phase_HidingProgress:
			return "HidingProgress"
		case VenusOS.Splash_Phase_FadingLogo:
			return "FadingLogo"
		case VenusOS.Splash_Phase_PlayingGauge:
			return "PlayingGauge"
		case VenusOS.Splash_Phase_WaitingForPreload:
			return "WaitingForPreload"
		case VenusOS.Splash_Phase_FadingOut:
			return "FadingOut"
		case VenusOS.Splash_Phase_Hidden:
			return "Hidden"
		}
		return "Unknown"
	}
}
