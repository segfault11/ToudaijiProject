uniform highp mat4 perspective;
uniform highp mat4 R;
uniform highp mat4 S;
uniform highp mat4 T;
uniform samplerCube cubeMap;
uniform sampler2D alphaLayer;
varying highp vec3 texCoord;


void main()
{
    highp float u = gl_FragCoord.x/1024.0;
    highp float v = gl_FragCoord.y/768.0;
    
    highp float a  = texture2D(alphaLayer, vec2(u,v)).r;
    
    highp vec3 tc = normalize(texCoord);
    tc.x *= -1.0;
    
    highp vec4 color = textureCube(cubeMap, tc);
    gl_FragColor = vec4(color.b, color.g, color.r, a);
}