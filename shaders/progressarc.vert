#version 440
layout(location=0) in vec4 qt_Vertex;
layout(location=1) in vec2 qt_MultiTexCoord0;

layout(location=0) out vec2 qt_TexCoord0;
layout(location=1) out vec2 pixelPosition;

layout(std140, binding=0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
} ubuf;

out gl_PerVertex {
    vec4 gl_Position;
};

void main() {
    qt_TexCoord0 = qt_MultiTexCoord0;
    pixelPosition = vec2(qt_Vertex.s, qt_Vertex.t); // TODO: actually calculate it.
    vec4 pos = qt_Vertex;
    gl_Position = ubuf.qt_Matrix * pos;
}
