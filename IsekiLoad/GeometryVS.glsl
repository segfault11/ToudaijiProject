#version 150

uniform mat4 View;
uniform mat4 Proj;
uniform mat4 Model;

in vec3 Position;
in vec3 Normal;
in vec2 TexCoord;

out vec3 NormalWC;
out vec2 TexC;

void main()
{
    TexC.x = TexCoord.x;
    TexC.y = 1.0f - TexCoord.y;

    vec4 nwc = normalize(Model*vec4(Normal, 1.0f));
    
    NormalWC.x = nwc.x;
    NormalWC.y = nwc.y;
    NormalWC.z = nwc.z;

    gl_Position = Proj*View*Model*vec4(Position, 1.0f);
}
