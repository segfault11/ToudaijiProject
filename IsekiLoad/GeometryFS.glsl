#version 150

in vec3 NormalWC;
in vec2 TexC;
out vec4 FragOut;

uniform sampler2D TextureMap;

void main()
{
    vec3 light = normalize(vec3(1.0, 1.0, 1.0));
    vec3 color = vec3(1.0, 0.0, 0.0);
    
    FragOut = texture(TextureMap, TexC);//vec4(color*max(0.0f, dot(light, NormalWC)), 1.0);
}