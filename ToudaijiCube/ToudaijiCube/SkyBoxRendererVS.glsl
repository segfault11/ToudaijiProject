uniform highp mat4 perspective;
uniform highp mat4 R;
uniform highp mat4 S;
uniform highp mat4 T;
uniform samplerCube cubeMap;
varying highp vec3 texCoord;

attribute vec3 pos;

void main()
{
    texCoord = pos; //normalize(pos);
    
    gl_Position = perspective*R*T*S*vec4(pos, 1.0);
}

