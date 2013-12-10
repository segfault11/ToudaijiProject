uniform highp float offX;
uniform highp float offY;
uniform highp float offZ;
uniform highp mat4 perspective;
uniform highp mat4 R;
uniform highp mat4 S;
uniform highp float scaleObj;
uniform highp mat4 T;
uniform highp mat4 SR; // rotation around self

attribute vec3 pos;


varying highp vec2 tc;

void main()
{
    vec4 p = SR*vec4(scaleObj*pos.x, 0.0, scaleObj*pos.z, 1.0);
    tc.x = (pos.x + 1.0)/2.0;
    tc.y = (pos.z + 1.0)/2.0;

    p.x += offX;
    p.y += offY;
    p.z += offZ;
    gl_Position = perspective*R*T*p;
}
