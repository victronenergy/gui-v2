#version 440
#define CONSTANT_PI 3.141592653589793
#define CONSTANT_TAU 6.283185307179586
layout(location = 0) in vec2 coord;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;

    vec4 remainderColor;
    vec4 progressColor;
    float startAngle;
    float endAngle;
    float progressAngle;
    float innerRadius;
    float radius;
    float outerRadius;
    float smoothing;
    float clockwise;
    float xscale;
    float xtranslate;
    float yscale;
    float ytranslate;
} ubuf;

// atan2 which isn't undefined at x == 0
float my_atan2(float y, float x) {
    return x == 0.0 ? sign(y) * CONSTANT_PI : atan(y, x);
}

// angle expressed in normal radians, but with orientation.
float denormalizedAngle(float a, float clockwise) {
    float angle = clockwise*(1.0 - a) + (1.0 - clockwise)*a;
    return (angle * CONSTANT_TAU) - CONSTANT_PI;
}

// angle must be in radians [-PI, PI].
// return value is normalized to [0.0, 1.0],
// inverted if necessary to adjust for clockwise vs anticlockwise.
float normalizedAngle(float angle, float clockwise) {
    float a = (angle + CONSTANT_PI) / CONSTANT_TAU;
    a = clockwise*(1.0 - a) + (1.0 - clockwise)*a;
    return a;
}

// converts from cartesian to polar coordinates (angle, radius).
// angle is normalized to [0.0, 1.0].
vec2 toPolar(vec2 point, float clockwise) {
    // note that we have flipped y/x to x/y to get angle from y axis (i.e. vertical).
    return vec2(normalizedAngle(atan(point.x, point.y), clockwise), length(point));
}

// converts from polar to cartesian coordinates (x, y).
vec2 toCartesian(vec2 polar, float clockwise) {
    float angle = denormalizedAngle(polar.x, clockwise);
    // note that we have flipped cos/sin to sin/cos since angle is from y axis (i.e. vertical).
    return vec2(polar.y * sin(angle), polar.y * cos(angle));
}

// if you move the specified distance along the arc, how much angle has been traversed?
// the error grows larger and larger the bigger distanceMoved is (since we assume straight-line movement)...
float angleDelta(float startAngle, float endAngle, float radius, float distanceMoved) {
    float arcLength = (endAngle - startAngle) * CONSTANT_TAU * radius;
    return distanceMoved / arcLength;
}

void main() {
    // first transform uv so that we "clip" to the section of the arc we want.
    // that is: notionally (0,0) is the origin of the unit circle,
    // but we might be displaying one small segment of the arc,
    // so (0,0) might not be represented at all in any of our fragments.
    vec2 uv = vec2(coord.x*ubuf.xscale + ubuf.xtranslate, coord.y*ubuf.yscale + ubuf.ytranslate);
    float uvDistance = length(uv); // distance from the center

    // note: we want angle from y axis rather than x axis, so flip args of atan2.
    float uvAngle = normalizedAngle(my_atan2(uv.x, uv.y), ubuf.clockwise);
    float withinGaugeAngle = (uvAngle < ubuf.startAngle || uvAngle > ubuf.endAngle) ? 0.0 : 1.0;

    // calculate the rounded caps.
    float capRadius = ubuf.outerRadius - ubuf.radius;
    float capAngleDelta = angleDelta(ubuf.startAngle, ubuf.endAngle, ubuf.radius, capRadius);

    // the startAngle cap.
    vec2 startCapCenter = toCartesian(vec2(ubuf.startAngle, ubuf.radius), ubuf.clockwise);
    float startCapAlpha = 1.0 - smoothstep(capRadius, capRadius + ubuf.smoothing, distance(uv, startCapCenter));

    // the endAngle cap.
    vec2 endCapCenter = toCartesian(vec2(ubuf.endAngle, ubuf.radius), ubuf.clockwise);
    float endCapAlpha = 1.0 - smoothstep(capRadius, capRadius + ubuf.smoothing, distance(uv, endCapCenter));

    // the progress cap.
    vec2 progressCapCenter = toCartesian(vec2(ubuf.progressAngle, ubuf.radius), ubuf.clockwise);
    float progressCapMix = 1.0 - smoothstep(capRadius, capRadius + ubuf.smoothing, distance(uv, progressCapCenter));

    // antialiasing.
    float gaugeAngleAlpha = max(endCapAlpha, max(startCapAlpha, withinGaugeAngle));
    float gaugeStrokeAlpha = smoothstep(ubuf.innerRadius - ubuf.smoothing, ubuf.innerRadius, uvDistance)
                             * (1.0 - smoothstep(ubuf.outerRadius, ubuf.outerRadius + ubuf.smoothing, uvDistance));

    float isProgressBar = ((uvAngle > (ubuf.endAngle + capAngleDelta)) || uvAngle <= ubuf.progressAngle) ? 1.0 : 0.0;
    float progressColorMix = max(isProgressBar, progressCapMix);

    // Qt expects pre-multiplied output, so don't just set w-channel.
    fragColor = mix(ubuf.remainderColor, ubuf.progressColor, progressColorMix) * gaugeAngleAlpha * gaugeStrokeAlpha * ubuf.qt_Opacity;
}
