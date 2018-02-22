// Author: Prince Polka
// Title: elirect

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D glyphs;

uniform vec2 glyphsize;
uniform int u_seconds;

const vec4 rgbpitch = vec4(-.3333,0.0,0.3333,0.0);

const vec2 original_glyphsize = vec2(100,210);

float elirect(vec2 st, mat3 e, float bg){
  st = (vec3(st,1)*e).xy;
  st *= st;
  st *= step(e[2].y,st);
  return mix(e[2].x,bg,step(1.,st.x+st.y));
}

vec3 s3 (vec4 v, mat3 e, vec3 bg){
  /* samples rgb individually for anti aliasing */

  vec3 vx = vec3(
  dot( vec3(v.ra,1) ,e[0]),
  dot( vec3(v.ga,1) ,e[0]),
  dot( vec3(v.ba,1) ,e[0])
  );

  vec3 vy = vec3(
  dot( vec3(v.ra,1) ,e[1]),
  dot( vec3(v.ga,1) ,e[1]),
  dot( vec3(v.ba,1) ,e[1])
  );

  vx *= vx;
  vy *= vy;

  vx *= step(e[2].y,vx);
  vy *= step(e[2].y,vy);

  return mix(e[2].xxx,bg, step(1.,vx+vy) );
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

    vec3 color = vec3(0.0,0.0,0.0); // IMPORTANT MUST BE 0.0
    vec3 colors[9] = {color,color,color,
                      color,color,color,
                      color,color,color}; // for AA
vec4 samples[9] = {
vec4(-0.4444,-0.1111,0.2222,-0.3333), vec4(-0.3333, 0.0, 0.3333,-0.3333), vec4(-0.2222, 0.1111,0.4444,-0.3333),
vec4(-0.4444,-0.1111,0.2222, 0.0000), vec4(-0.3333, 0.0, 0.3333, 0.0000), vec4(-0.2222, 0.1111,0.4444, 0.0000),
vec4(-0.4444,-0.1111,0.2222, 0.3333), vec4(-0.3333, 0.0, 0.3333, 0.3333), vec4(-0.2222, 0.1111,0.4444, 0.3333)
};

    int g = 65-33 +u_seconds;

    vec2 ratio = original_glyphsize/glyphsize;

    g += int(dot(ivec2(st / glyphsize),ivec2(1)))  ;

    st = mod(st,glyphsize) * ratio;

    vec4 v = st.xxxy;

    for(int i=0;i<29;i++){
    mat3 m = mat3fetch(glyphs,g,i);
    //color = vec3(elirect(st,m,color.g));

    // anti alias , with artifacts
    for(int s = 0;s<9;s++)
    colors[s] = s3(v+samples[s]*ratio.x,m,colors[s]);
    }

    color = ( colors[0] + colors[1] + colors[2] +
              colors[3] + colors[4] + colors[5] +
              colors[6] + colors[7] + colors[8] ) * 0.11112;

              color = 1.055*pow(color,vec3(0.4167))-0.055;
              //color=pow(color,vec3(.83,.83,.83));

    gl_FragColor = vec4(color,1.0);
}
