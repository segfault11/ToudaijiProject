uniform mat4 perspective;
uniform mat4 model;
uniform samplerCube cubeMap;
varying highp vec3 texCoord;
attribute vec3 pos;

void main()
{
    texCoord = normalize(pos);
    gl_Position = perspective*model*vec4(pos, 1.0);
}