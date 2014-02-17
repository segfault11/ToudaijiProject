uniform samplerCube skyBox;
uniform sampler2D alphaMap;

uniform bool useAlphaMap;
uniform highp float screenWidth;
uniform highp float screenHeight;

varying highp vec3 texCoord;

void main()
{
    highp vec3 tc = normalize(texCoord);
    tc.x *= -1.0;
    highp vec4 color = textureCube(skyBox, tc);

    if (useAlphaMap)
    {
        highp float u = gl_FragCoord.x/screenWidth;
        highp float v = gl_FragCoord.y/screenHeight;
        highp float a  = texture2D(alphaMap, vec2(u,v)).r;
        gl_FragColor = vec4(color.b, color.g, color.r, a);
    }
    else
    {
        gl_FragColor = vec4(color.b, color.g, color.r, 1.0);
    }

}