// Author: Prince Polka
// Title: blablabla

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D glyphs;
uniform int u_seconds;

float elirect(vec2 st, mat3 e, float background){
    st = (vec3(st,1) * e).xy;

    float mode = e[2].y;

    float ret = mix(float( dot(st,st) < 1.0 ), // ellipse
               float( abs(st.x) < 1.0 && abs(st.y) < 1.0), // rect
               mode);
    float addsub = e[2].x;
    return mix(
        min(background,1.0-ret),
        max(background,ret),
        addsub);;
}

float ff(sampler2D sampler, int y_index , int x_index){
    ivec4 temp = ivec4(texelFetch(sampler,ivec2(x_index,y_index),0) * 255.0);

    int intbits =
    (temp.a << 24) |
    (temp.r << 16) |
    (temp.g <<  8) |
     temp.b;

    return intBitsToFloat(intbits);
}

mat3 mat3fetch(sampler2D s, int y, int x){
x*=9;
return mat3(
ff(s,y,x  ),ff(s,y,x+1),ff(s,y,x+2),
ff(s,y,x+3),ff(s,y,x+4),ff(s,y,x+5),
ff(s,y,x+6),ff(s,y,x+7),ff(s,y,x+8)
);
}

mat3 new_eli(float cx,float cy, float rx, float ry, float a, float b, float c, float d, float addsub){

    float determinant = a * d - c * b;
    mat3 ret = mat3( d,-c, 0,
                    -b, a, 0,
                     0, 0, 0) / determinant;

    ret[0].z -= cx;
    ret[1].z -= cy;

    ret[0]/=rx;
    ret[1]/=ry;

    ret[2] = vec3(addsub,0,0);

    return ret;
}

void main() {
    vec2 st = gl_FragCoord.xy;

    st.y = 500.-st.y; // why is this needed? svg coordinate system is the same ?

    float color = 0.0;

    int g = 65-33 +u_seconds;

    //g-=32;

    //g-= int(st.y<250.0) *32;

    //g += int( dot(st/vec2(100,200),vec2(1,5));

    g += int(st.x/100);


    st = mod(st, vec2(100,500) );

    for(int i=0;i<29;i++) color = elirect(st, mat3fetch(glyphs,g,i) ,color);


    gl_FragColor = vec4(vec3(color),1.0);
}
