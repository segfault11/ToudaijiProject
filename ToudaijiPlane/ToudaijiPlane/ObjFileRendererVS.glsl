uniform mat4 projection;
uniform mat4 model;

attribute vec3 position;
attribute vec2 texCoord;

varying highp vec2 vTexCoord;

void main()
{
    vTexCoord.x = texCoord.x;
    vTexCoord.y = 1.0 - texCoord.y;
    gl_Position = projection*model*vec4(position, 1.0);
}