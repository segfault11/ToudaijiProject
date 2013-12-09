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
        alpha = texture2D(alphaMask, texCoordAlpha).r;
        //alpha = 0.1;
    }
    
    highp vec4 color = textureCube(cubeMap, normalize(texCoord));
    gl_FragColor = vec4(color.b, color.g, color.r, alpha);
}