/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

ShaderEffect {
	id: shaderEffect

	property real radius
	property real progress
	property point touchPos
	property real aspectRatio: height > 0 ? width / height : 1.0
	property real radiusRatio: height > 0 ? radius / height : 0.0
	property color color

	fragmentShader:  "qrc:/components/shaders/presseffect.frag.qsb"
}
