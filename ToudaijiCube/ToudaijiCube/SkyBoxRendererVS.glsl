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
//    texCoord = pos; //normalize(pos);
    texCoord.x = -pos.x;
    texCoord.y = pos.y;
    texCoord.z = pos.z;


//
//    float ur = (pos.x*cos(rotAmap) + pos.z*-sin(rotAmap) - bottomXOffset/scale + 1.0)/2.0;
//    float vr = (pos.x*sin(rotAmap) + pos.z*cos(rotAmap) - bottomZOffset/scale + 1.0)/2.0;

//    float ur = (pos.x*cos(rotAmap) + pos.z*-sin(rotAmap) - 3.0/5.0 + 1.0)/2.0;
//    float vr = (pos.x*sin(rotAmap) + pos.z*cos(rotAmap) - -0.0/5.0 + 1.0)/2.0;
//
//    texCoordAlpha.x = ur;
//    texCoordAlpha.y = vr;

    float utmp = pos.x - bottomXOffset/scale;
    float vtmp = pos.z - bottomZOffset/scale;
    float u = utmp*cos(rotAmap) + vtmp*-sin(rotAmap);
    float v = utmp*sin(rotAmap) + vtmp*cos(rotAmap);
    texCoordAlpha.x = (u + 1.0)/2.0;
    texCoordAlpha.y = (v + 1.0)/2.0;
    
    
    gl_Position = perspective*model*vec4(pos, 1.0);
}

