uniform highp mat4 projection;
uniform highp mat4 model;
uniform sampler2D tex;
uniform highp float alpha;

varying highp vec2 vTexCoord;

void main()
{
    highp vec4 col = texture2D(tex, vTexCoord);
    gl_FragColor = vec4(col.x, col.y, col.z, alpha);
}