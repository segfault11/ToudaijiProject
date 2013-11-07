uniform mat4 projection;
uniform mat4 model;

attribute vec3 position;

void main()
{
    gl_Position = projection*model*vec4(position, 1.0);
}