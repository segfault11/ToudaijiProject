uniform mat4 view;
uniform mat4 perspective;

varying highp vec3 texCoord;

attribute vec3 position;

void main()
{
//    gl_PointSize = 10.0;
    texCoord = position;
    
    vec4 pos = perspective*view*vec4(position, 1.0);
    gl_Position = pos;
}