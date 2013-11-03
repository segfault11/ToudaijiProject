#version 150

in vec3 NormalWC;
out vec4 FragOut;

void main()
{
    vec3 light = normalize(vec3(1.0, 1.0, 1.0));
    vec3 color = vec3(1.0, 0.0, 0.0);
    
    FragOut = vec4(color*max(0.0f, dot(light, NormalWC)), 1.0);
}