uniform highp float offX;
uniform highp float offZ;
uniform highp mat4 perspective;
uniform highp mat4 R;
uniform highp mat4 S;
uniform highp mat4 T;

attribute vec3 pos;


varying highp vec2 tc;

void main()
{
    vec4 p = S*vec4(pos.x, pos.y, pos.z, 1.0);
    tc.x = (pos.x + 1.0)/2.0;
    tc.y = (pos.z + 1.0)/2.0;

    p.x += offX;
    p.z += offZ;
    gl_Position = perspective*R*T*p;
}
