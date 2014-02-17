uniform mat4 projection;
uniform mat4 view;

varying highp vec2 texCoord;

attribute vec3 position;

void main()
{
    texCoord.x = (position.x + 1.0)/2.0;
    texCoord.y = (position.z + 1.0)/2.0;
    
    gl_Position = projection*view*vec4(position, 1.0);
//    gl_Position = vec4(position.x, position.z, 0.0, 1.0);
//    gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
}