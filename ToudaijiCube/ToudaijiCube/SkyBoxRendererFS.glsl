uniform samplerCube cubeMap;
varying highp vec3 texCoord;

void main()
{
    highp vec4 color = textureCube(cubeMap, texCoord);
    gl_FragColor = vec4(color.b, color.g, color.r, 1.0);
}