
varying highp vec3 fragNormal;

void main()
{
    highp vec3 lightCol = vec3(1.0, 1.0, 1.0);
    highp vec3 lightDir = vec3(1.0, 0.5, 0.7);
    lightDir = normalize(lightDir);
    highp vec3 matCol = vec3(1.0, 0.25, 0.25);
    
    gl_FragColor = vec4(lightCol*matCol*max(dot(fragNormal, lightDir), 0.0), 0.1);
}