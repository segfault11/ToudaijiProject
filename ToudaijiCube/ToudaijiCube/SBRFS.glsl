uniform highp mat4 perspective;
uniform highp mat4 R;
uniform highp mat4 S;
uniform highp mat4 T;
uniform highp float bottomXOffset;
uniform highp float bottomZOffset;
uniform highp float rotAmap;
uniform highp vec3 camPos;
uniform highp float scale;
uniform samplerCube cubeMap;
uniform sampler2D alphaMask;
uniform bool isBottom;
varying highp vec3 texCoord;
varying highp vec2 texCoordAlpha;
varying highp vec4 p;

//mat3 inverse(mat3 m)
//{
//    m[0][0] =
//}

void main()
{
    highp float alpha = 1.0;
    
    highp vec4 r = R*T*vec4(bottomXOffset, -scale, bottomZOffset, 1.0);
    highp vec4 v0 = R*vec4(1.0, 0.0, 0.0, 0.0);
    highp vec4 v1 = R*vec4(0.0, 0.0, -1.0, 0.0);
    
    highp mat3 M = mat3(v0.xyz, v1.xyz, p.xyz);
    
    highp vec3 res = inverse(M)*r.xyz;
//
//    float u = 0.0f;
//    float v = 0.0f;

    highp float y = (-scale - camPos.y)/(scale*texCoord.y);
    highp float a = camPos.x + y*scale*texCoord.x - bottomXOffset;
    highp float b = bottomZOffset - camPos.z - y*scale*texCoord.z;
    highp float u = 1.0/2.0*(a/(scale) + 1.0);
    highp float v = 1.0/2.0*(b/(scale) + 1.0);
    
    alpha = texture2D(alphaMask, vec2(u, v)).r;
    
    highp vec4 color = textureCube(cubeMap, normalize(texCoord));
    gl_FragColor = vec4(color.b, color.g, color.r, alpha);
}