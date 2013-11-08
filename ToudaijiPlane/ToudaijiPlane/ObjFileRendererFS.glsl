uniform sampler2D tex;

varying highp vec2 vTexCoord;

void main()
{
    gl_FragColor = texture2D(tex, vTexCoord);
}