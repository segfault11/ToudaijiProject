uniform mat4 perspective;
uniform mat4 model;
uniform float bottomXOffset;
uniform float bottomZOffset;
uniform float scale;
uniform samplerCube cubeMap;
varying highp vec3 texCoord;
varying highp vec2 texCoordAlpha;
attribute vec3 pos;

void main()
{
    texCoord = pos; //normalize(pos);
    texCoordAlpha.x = (pos.x + 1.0 - bottomXOffset/scale)/2.0;
    texCoordAlpha.y = (pos.z + 1.0 - bottomZOffset/scale)/2.0;
//    texCoordAlpha.x = (pos.x + 1.0)/2.0;
//    texCoordAlpha.y = (pos.z + 1.0)/2.0;
    
    gl_Position = perspective*model*vec4(pos, 1.0);
}