uniform samplerCube cubeMap;
uniform sampler2D alphaMask;
uniform bool isBottom;
varying highp vec3 texCoord;
varying highp vec2 texCoordAlpha;

void main()
{
    highp float alpha = 1.0;
    
    if (isBottom)
    {
        //alpha = 0.8;
        alpha = texture2D(alphaMask, texCoordAlpha).r;
        //alpha = texCoordAlpha.x*texCoordAlpha.y;
    }
    
    highp vec4 color = textureCube(cubeMap, texCoord);
    gl_FragColor = vec4(color.b, color.g, color.r, alpha);
}