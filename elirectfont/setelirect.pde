void setElirect(
                int gi , int eri ,
                float addsub, float mode,
                float x, float y, // pos
                float w, float h, // size
                float a, float c, float e, // svg matrix
                float b, float d, float f
                )
{
eri*=9;
float determinant = a*d - c*b;

float A,C,E,
      B,D,F;

A = d / determinant;
C = -c / determinant;
B = -b / determinant;
D = a / determinant;
        
E = e * A + f * C + x;
F = e * B + f * D + y;
        
glyphimg[gi][eri    ] = A/w;
glyphimg[gi][eri + 1] = C/w;
glyphimg[gi][eri + 2] = -E/w;
        
glyphimg[gi][eri + 3] = B/h;
glyphimg[gi][eri + 4] = D/h;
glyphimg[gi][eri + 5] = -F/h;
        
glyphimg[gi][eri + 6] = addsub;
glyphimg[gi][eri + 7] = mode;
}