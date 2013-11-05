uniform mat4 projection;
uniform mat4 model;

attribute vec3 normal;
attribute vec3 position;

varying highp vec3 fragNormal;

void main()
{
    fragNormal = -normal;
    gl_Position = projection*model*vec4(position, 1.0);
}