#version 440
layout(location = 0) in vec2 vTexCoord;
layout(location = 1) in vec2 pixelPosition;

layout(location = 0) out vec4 fragColor;

// uniform block: 156 bytes
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;         // offset 0
    float qt_Opacity;       // offset 64
    int direction;          // offset 68
    int vertexCount;        // offset 72
    float xCenter;          // offset 76
    float yCenter;          // offset 80
    float value;            // offset 84
    float radius;           // offset 88
    float strokeWidth;      // offset 92
    float startAngle;       // offset 96
    float endAngle;         // offset 100
    float transitionAngle;  // offset 104
    vec4 progressColor;     // offset 108
    vec4 remainderColor;    // offset 124
    vec4 fillColor;         // offset 140 -> 156
} ubuf;

void main() {
    // find the polar coordinates of this pixel.
    float r = length(pixelPosition);
    float theta = atan(pixelPosition.y, pixelPosition.x);

    // determine if this pixel should be discarded.
    //if (theta > ubuf.endAngle || theta < ubuf.startAngle
    //        || r < ubuf.radius || r > (ubuf.radius+ubuf.strokeWidth))
    //    discard;

    // determine which color to use for the pixel
    if (theta < ubuf.transitionAngle)
        fragColor = ubuf.progressColor;
    else
        fragColor = ubuf.remainderColor;
}
