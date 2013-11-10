uniform sampler2D tex;

varying highp vec2 vTexCoord;

void main()
{
    highp vec4 col = texture2D(tex, vTexCoord);
    gl_FragColor = vec4(col.x, col.y, col.z, 0.2);
}