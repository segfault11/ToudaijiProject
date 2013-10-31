uniform sampler2D frame;
varying lowp vec2 texCoord;

void main()
{
    gl_FragColor = texture2D(frame, texCoord);
}