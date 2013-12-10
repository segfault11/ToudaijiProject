uniform highp mat4 perspective;
uniform highp mat4 R;
uniform highp mat4 S;
uniform highp mat4 T;
uniform highp float bottomXOffset;
uniform highp float bottomZOffset;
uniform highp float rotAmap;
uniform highp float angleY;
uniform highp float scale;
uniform samplerCube cubeMap;
varying highp vec3 texCoord;
varying highp vec2 texCoordAlpha;
varying highp vec4 p;

attribute highp vec3 pos;

void main()
{
    texCoord = pos; 
    p = (R*T*S*vec4(pos, 1.0));
    
    gl_Position = perspective*R*T*S*vec4(pos, 1.0);
}

