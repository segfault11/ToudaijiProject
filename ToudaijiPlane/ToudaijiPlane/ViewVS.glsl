uniform sampler2D frame;
attribute vec2 pos;
varying lowp vec2 texCoord;

void main()
{
    vec2 texc;
    texc.x = pos.x;
    texc.y = 1.0 - pos.y;
    texCoord = texc;
    vec2 posNDC;
    posNDC.x = 2.0*pos.x - 1.0;
    posNDC.y = 2.0*(pos.y) - 1.0;
    gl_Position = vec4(posNDC, 0.0, 1.0);
}