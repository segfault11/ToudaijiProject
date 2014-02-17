uniform sampler2D amapSampler;

varying highp vec2 texCoord;

void main()
{
    highp vec4 color = texture2D(amapSampler, texCoord);
    gl_FragColor = vec4(color.r, 0.0, 0.0, 1.0);
}