// Author: Prince Polka
// Title: elirect

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D glyphs;

uniform vec2 glyphsize;
uniform int u_seconds;

const mat3 pitch = mat3(
-0.4444,-0.1111,0.2222,
-0.3333, 0.0000,0.3333,
-0.2222, 0.1111,0.4444
);

const vec2 original_glyphsize = vec2(100,210);

const mat4 m4_0 = mat4(0.0);
const vec4 v4_1 = vec4(1.0);

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

void main() {
    vec2 st = gl_FragCoord.xy;
    st.y = 500.-st.y; // why is this needed? svg coordinate system is the same ?

    vec3 color = vec3(0.0,0.0,0.0); // IMPORTANT MUST BE 0.0
    vec3 colors[9] = {color,color,color,
                      color,color,color,
                      color,color,color}; // for AA


    int g = 65-33 +u_seconds;

    vec2 ratio = original_glyphsize/glyphsize;

    g += int(dot(ivec2(st / glyphsize),ivec2(1)))  ;

    st = mod(st,glyphsize) * ratio;

    vec3 vp = st.y + pitch[1] * ratio.x;
    mat3 oosam = st.x + pitch * ratio.x;

    for(int i=0;i<29;i++){
    mat3 e = mat3fetch(glyphs,g,i);
    float mode = e[2].y;
    vec3 addsub = e[2].xxx;

    vec3 vpx = vp * e[0].y + e[0].z;
    vec3 vpy = vp * e[1].y + e[1].z;

    mat3 samX, samY, osamX, osamY;
    osamX = oosam * e[0].x;
    osamY = oosam * e[1].x;

    int s = 0;

    for(int ve=0;ve<3;ve++){
      samX = osamX + vpx[ve];
      samX = matrixCompMult(samX,samX);
      samX[0] *= step( mode , samX[0] );
      samX[1] *= step( mode , samX[1] );
      samX[2] *= step( mode , samX[2] );
      samY = osamY + vpy[ve];
      samY = matrixCompMult(samY,samY);
      samY[0] *= step( mode , samY[0] );
      samY[1] *= step( mode , samY[1] );
      samY[2] *= step( mode , samY[2] );
      samX += samY;
      colors[s] = mix(addsub,colors[s],step( 1.0 , samX[0] ) ); s++;
      colors[s] = mix(addsub,colors[s],step( 1.0 , samX[1] ) ); s++;
      colors[s] = mix(addsub,colors[s],step( 1.0 , samX[2] ) ); s++;
    }

    }

    color = ( colors[0] + colors[1] + colors[2] +
              colors[3] + colors[4] + colors[5] +
              colors[6] + colors[7] + colors[8] ) * 0.11112;
    /* if mat3 colors[3]
     color = (colors[0] + colors[1] + colors[2]) * vec3(0.1111111);
    */

    color = 1.055 * pow( color, vec3(0.4167) ) - 0.055;

    gl_FragColor = vec4(color,1.0);
}
