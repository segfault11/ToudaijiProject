uniform mat4 view;
uniform mat4 perspective;

varying highp vec3 texCoord;

attribute vec3 position;

void main()
{
    texCoord = position;
    gl_Position = perspective*view*vec4(position, 1.0);
}