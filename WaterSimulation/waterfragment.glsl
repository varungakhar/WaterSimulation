#version 410

out vec4 fragcolor;
in  vec4 outcolor;
in  float passvalue;

in vec4 diffusespecular;

void main()
{
    if (passvalue>=90)
    {
        fragcolor=vec4(1.0,0.3,0.5,1.0)*diffusespecular;
    }
    else
    {
        fragcolor=vec4(0.0,0.3,0.5,1.0)*diffusespecular;
    }
    
  
  
    
    
    
}