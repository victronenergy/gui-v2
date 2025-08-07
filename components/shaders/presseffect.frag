/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;

    vec4 color;
    vec2 touchPos;
    float progress;
    float aspectRatio;
    float radiusRatio;
} ubuf;

void main() {
    float maxRadius = 0.7071 *	max(ubuf.aspectRatio, 1.0); // sqrt(0.5)
    float radius = ubuf.progress * maxRadius;

    // Move the animation center from the touch position to center of the area
    vec2 absoluteCenter = vec2(0.5, 0.5);
    vec2 circleCenter = (1.0 - ubuf.progress) * ubuf.touchPos + ubuf.progress*absoluteCenter;

    vec2 normal = vec2(qt_TexCoord0.x - circleCenter.x, qt_TexCoord0.y - circleCenter.y);

    // Skew the normal vector so the circle appears perfectly round
    vec2 aspectVector = vec2(ubuf.aspectRatio, 1.0);
    normal *= aspectVector;

    // Circle equation x² + y² = r²
    float circleMask = step(dot(normal, normal), radius*radius);

    // Skew the geometries so the corners appear perfectly round
    vec2 position = qt_TexCoord0.xy * aspectVector;
    vec2 size = vec2(0.5, 0.5) * aspectVector;
    vec2 center = absoluteCenter * aspectVector;
    float distance = length(max(abs(position - center) - size + ubuf.radiusRatio, 0.0)) - ubuf.radiusRatio;
    float cornerMask = 1.0 - smoothstep(0.0, 0.01, distance);

    fragColor = ubuf.color * circleMask * cornerMask * ubuf.qt_Opacity;
}
