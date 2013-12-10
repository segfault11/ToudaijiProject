uniform sampler2D aMap;

varying highp vec2 tc;


void main()
{
    highp float a = texture2D(aMap, tc).r;

    gl_FragColor = vec4(a, 0.0, 0.0, 1.0);
}
