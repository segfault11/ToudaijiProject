uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

varying highp vec2 texCoord;

attribute vec3 position;

void main()
{
    texCoord.x = (position.x + 1.0)/2.0;
    texCoord.y = (position.z + 1.0)/2.0;
    
    gl_Position = projection*view*model*vec4(position, 1.0);
}