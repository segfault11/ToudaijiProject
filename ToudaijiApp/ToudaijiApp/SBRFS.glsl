uniform samplerCube skyBox;

varying highp vec3 texCoord;

void main()
{
    highp vec3 tc = normalize(texCoord);
    tc.x *= -1.0;
    
    highp vec4 color = textureCube(skyBox, tc);
    gl_FragColor = vec4(color.b, color.g, color.r, 1.0);
}