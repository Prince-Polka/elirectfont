XML font;
XML shape;
XML[] glyphs,shapes,components;
int index = 0;
int gi = 0; // glyph index
PShader blablabla;

float[][] glyphimg = new float[96][9*29];

void setfloatarray(PShader target, String sampler2Dname, float[][] source){
    int cols,rows;
    cols = source.length;
    rows = source[0].length;
    PImage array = createImage(rows,cols,ARGB);
    
    for(int i=0,c=0;c<cols;c++)
    for(int     r=0;r<rows;r++)
    array.pixels[i++] = Float.floatToIntBits( source[c][r] );
    target.set(sampler2Dname,array); 
}

void setup(){
  size(500,500,P2D);
  blablabla = loadShader("blablabla.frag");
  font = loadXML("AZazlayered.svg");
  glyphs = font.getChildren("g");
  for (int i = 0; i < glyphs.length; i++) {
    String id = glyphs[i].getString("inkscape:label");
    if (id.length()==1 ){
    index = 0;
    gi = (int)id.charAt(0)-33;
    shapes = glyphs[i].getChildren();
    for(int j=0; j < shapes.length; j++){
      shape = shapes[j];
      String shape_name = shape.getName();
      
      if(shape_name.equals("ellipse")){
        float cx,cy,rx,ry;
        cx = shape.getFloat("cx");
        cy = shape.getFloat("cy");
        rx = shape.getFloat("rx");
        ry = shape.getFloat("ry");
        
        String style = shape.getString("style");
        float addsub = 0.0;
        
        if(style !=null && style.contains("fill") ){
          int fillpos = style.indexOf("fill");
          style = style.substring(fillpos+5,fillpos+12);
          if ( style.equals("#000000") || style.equals("#00ff00") ) addsub = 1.0;
        }
        
        String t = shape.getString("transform");
        String[] abcd;
        float a,b,c,d,e,f;
        e=f=0.0;
        float determinant;
        
        if(t!=null && t.contains("rotate") ){
        t = t.substring(7,t.length()-1);
        abcd = t.split(",");
        a = Float.parseFloat(abcd[0]);
        b = Float.parseFloat(abcd[1]);
        c = Float.parseFloat(abcd[2]);
        
        float ang = radians(a);
        float sina = sin(ang), cosa = cos(ang);
        a = d = cosa;
        e = -(b*cosa + c*-sina - b);
        f = -(b*sina + c*cosa - c);
        b = sina; c = -sina;
        /*
        rotate(a,x,y)
        a = radians(a)
        translate(x,y)
        rotate(a) == cos(a),-sin(a) sin(a),cos(a)
        translate(-x,-y)
        rotate(30.0, 100.0, 100.0) -> matrix(0.87,0.5,-0.5,0.87, 63.4,-36.6 )
        */
        }
        else if(t!=null && t.contains("translate") ){
        t = t.substring(10,t.length()-1);
        abcd = t.split(",");
        a = 1.0;
        b = 0.0;
        c = 0.0;
        d = 1.0;
        e = Float.parseFloat(abcd[0]);
        f = Float.parseFloat(abcd[1]);
        t = "1.0,0.0,0.0,1.0,"+e+","+f;
        }
        
        else if(t!=null && t.contains("matrix") ){
        t = t.substring(7,t.length()-1);
        abcd = t.split(",");
        a = Float.parseFloat(abcd[0]);
        b = Float.parseFloat(abcd[1]);
        c = Float.parseFloat(abcd[2]);
        d = Float.parseFloat(abcd[3]);
        e = Float.parseFloat(abcd[4]);
        f = Float.parseFloat(abcd[5]);
      }
        
        else {
          t = "1.0,0.0,0.0,1.0";
          a = 1.0;
          b = 0.0;
          c = 0.0;
          d = 1.0;
        }
        
        determinant = a*d - c*b;
        
        //cx+=e;
        //cy+=f;
        
        //d /= determinant;
        //c = -c / determinant;
        //cx=determinant*100+cx;
        //cy-=-b*100 - a*100 +100;
        //cx += a*100;
        //cx = (c * cy - d * cx) /determinant;
        //cy = (b * cx - a * cy) /determinant;

        
        
        glyphimg[gi][index*9    ] = d / determinant / rx;
        glyphimg[gi][index*9 + 1] = -c / determinant / rx;
        glyphimg[gi][index*9 + 2] = -cx / rx;
        
        glyphimg[gi][index*9 + 3] = -b / determinant / ry;
        glyphimg[gi][index*9 + 4] = a / determinant / ry;
        glyphimg[gi][index*9 + 5] = -cy /ry;
        
        glyphimg[gi][index*9 + 6] = addsub;
        glyphimg[gi][index*9 + 7] = 0.0;
        glyphimg[gi][index*9 + 8] = 0.0;
        
        float A,C,E,
              B,D,F;
              
        A = d / determinant;
        C = -c / determinant;
        B = -b / determinant;
        D = a / determinant;
        
        E=-cx;
        F=-cy;
        
        E -= e * A + f * C;
        F -= e * B + f * D;
        
        
        
        glyphimg[gi][index*9    ] = A/rx;
        glyphimg[gi][index*9 + 1] = C/rx;
        glyphimg[gi][index*9 + 2] = E/rx;
        //glyphimg[gi][index*9 + 2] = -m02;
        
        glyphimg[gi][index*9 + 3] = B/ry;
        glyphimg[gi][index*9 + 4] = D/ry;
        glyphimg[gi][index*9 + 5] = F/ry;
        //glyphimg[gi][index*9 + 5] = -m12;
        
        glyphimg[gi][index*9 + 6] = addsub;
        glyphimg[gi][index*9 + 7] = 0.0;
        

        //println(a,b,c,d,e,f);
        
        index ++;
      }
      if(shape_name.equals("rect")){
        float x,y,w,h, a,b,c,d,e,f;
        e=f=0.0;
        String[] abcd = new String[4];
        x = shape.getFloat("x");
        y = shape.getFloat("y");
        w = shape.getFloat("width")/2.0;
        h = shape.getFloat("height")/2.0;
        
        String style = shape.getString("style");
        float addsub = 0.0;
        
        if(style !=null && style.contains("fill") ){
          int fillpos = style.indexOf("fill");
          style = style.substring(fillpos+5,fillpos+12);
          if ( style.equals("#000000") || style.equals("#00ff00") ) addsub = 1.0;
          
        }
        
        String t = shape.getString("transform");
        
        if(t!=null && t.contains("matrix") ){
        t = t.substring(7,t.length()-1);
        abcd = t.split(",");
        a = Float.parseFloat(abcd[0]);
        b = Float.parseFloat(abcd[1]);
        c = Float.parseFloat(abcd[2]);
        d = Float.parseFloat(abcd[3]);
        e = Float.parseFloat(abcd[4]);
        f = Float.parseFloat(abcd[5]);
        }
        else if(t!=null && t.contains("rotate") ){
        t = t.substring(7,t.length()-1);
        abcd = t.split(",");
        a = Float.parseFloat(abcd[0]);
        b = Float.parseFloat(abcd[1]);
        c = Float.parseFloat(abcd[2]);
        
        float ang = radians(a);
        float sina = sin(ang), cosa = cos(ang);
        a = d = cosa;
        e = -(b*cosa + c*-sina - b);
        f = -(b*sina + c*cosa - c);
        b = sina; c = -sina;
        }
        else if(t!=null && t.contains("translate") ){
        t = t.substring(10,t.length()-1);
        abcd = t.split(",");
        a = 1.0;
        b = 0.0;
        c = 0.0;
        d = 1.0;
        e = Float.parseFloat(abcd[0]);
        f = Float.parseFloat(abcd[1]);
        t = "1.0,0.0,0.0,1.0,"+e+","+f;
        }
        else {
          t = "1.0,0.0,0.0,1.0";
          a = 1.0;
          b = 0.0;
          c = 0.0;
          d = 1.0;
        }
        
        float determinant = a*d - c*b;
        
        /*
        https://github.com/processing/processing-android/blob/master/core/src/processing/core/PMatrix2D.java
        
        translate
        m02 = tx*m00 + ty*m01 + m02;
        m12 = tx*m10 + ty*m11 + m12;
        
        invert
  
        float m02,m12;
        e -= w+x;
        f -= h+y;
        m02 = (c * f - d * e) / determinant / w;
        m12 = (b * e - a * f) / determinant / h;
        
        m02 = (t01 * t12 - t11 * t02) / determinant;
        m12 = (t10 * t02 - t00 * t12) / determinant;
        */
        
        x+=w;
        y+=h;
        
        //x+=e * a + f * c;
        //y+=e * b + f * d;
        //x+=w * a + h * c;
        //y+=w * b + h * d;
        
        float m02,m12;
        m02 = (c * f - d * e) / determinant;
        m12 = (b * e - a * f) / determinant;
        
        float A,C,E,
              B,D,F;
              
        A = d / determinant;
        C = -c / determinant;
        B = -b / determinant;
        D = a / determinant;
        
        E=-x;
        F=-y;
        
        E -= e * A + f * C;
        F -= e * B + f * D;
        
        
        
        glyphimg[gi][index*9    ] = A/w;
        glyphimg[gi][index*9 + 1] = C/w;
        glyphimg[gi][index*9 + 2] = E/w;
        //glyphimg[gi][index*9 + 2] = -m02;
        
        glyphimg[gi][index*9 + 3] = B/h;
        glyphimg[gi][index*9 + 4] = D/h;
        glyphimg[gi][index*9 + 5] = F/h;
        //glyphimg[gi][index*9 + 5] = -m12;
        
        glyphimg[gi][index*9 + 6] = addsub;
        glyphimg[gi][index*9 + 7] = 1.0;
        //glyphimg[gi][index*9 + 8] = 0.0;
        /*
        print( "a["+index+"] = new_rect(");
        print(a+","+b+","+c+","+d+","+t);
        println(", 1.0);");
        */
        index ++;
      }
    }
    for(int fill = index;fill<29;fill++){
        glyphimg[gi][fill*9    ] = 1.;
        glyphimg[gi][fill*9 + 1] = 1.;
        glyphimg[gi][fill*9 + 2] = 1.;
        
        glyphimg[gi][fill*9 + 3] = 1.;
        glyphimg[gi][fill*9 + 4] = 1.;
        glyphimg[gi][fill*9 + 5] = 1.;
        
        glyphimg[gi][fill*9 + 6] = 1.0;
        glyphimg[gi][fill*9 + 7] = 0.0;
        glyphimg[gi][fill*9 + 8] = 0.0;
      
    }
    
    
    }
  }
  setfloatarray(blablabla,"glyphs",glyphimg);
  shader(blablabla);
  //println(index);
}
void draw(){
  int sec = frameCount/30;
  blablabla.set("u_seconds",sec%22 + 32 * int(sec<22)  );
  rect(0,0,width,height);
}