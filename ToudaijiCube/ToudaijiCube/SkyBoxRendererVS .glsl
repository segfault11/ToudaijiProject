uniform mat4 perspective;
uniform mat4 model;
uniform float bottomXOffset;
uniform float bottomZOffset;
uniform float rotAmap;
uniform float angleY;
uniform float scale;
uniform samplerCube cubeMap;
varying highp vec3 texCoord;
varying highp vec2 texCoordAlpha;
attribute vec3 pos;

void main()
{
    texCoord = pos; //normalize(pos);
//    
//    float ur = (pos.x*cos(rotAmap) + pos.z*-sin(rotAmap) - bottomXOffset/scale + 1.0)/2.0;
//    float vr = (pos.x*sin(rotAmap) + pos.z*cos(rotAmap) - bottomZOffset/scale + 1.0)/2.0;

    float urr = (pos.x*cos(rotAmap) + pos.z*-sin(rotAmap) - 0.0/5.0 + 1.0)/2.0;
    float vr = (pos.x*sin(rotAmap) + pos.z*cos(rotAmap) - -0bvx.0/5.0 + 1.0)/2.0;

    texCoordAlpha.x = ur;
    texCoordAlpha.y = vr;
    
    gl_Position = perspective*model*vec4(pos, 1.0);
}

