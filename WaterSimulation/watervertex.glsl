#version 410

in vec4 position;
in vec4 color;
in vec4 normals;

out vec4 outcolor;

uniform mat4 mvp;

out float passvalue;

uniform vec4 lightposition;
uniform vec4 eyeposition;
out float diffuselight;

out vec4 diffusespecular;

void main()
{
    outcolor=color;
    passvalue=position.w;
    vec4 vertexposition=lightposition-vec4(position.xyz,1.0);
    vertexposition=normalize(vertexposition);
    
vec4 negativevertexposition;
negativevertexposition=normalize(reflect(-vertexposition,normalize(normals)));
    
    
    vec4 eyevertexposition=eyeposition-vec4(position.xyz,1.0);
    eyevertexposition=normalize(eyevertexposition);
    
    float specularity=dot(negativevertexposition,eyevertexposition);
    
    specularity=clamp(specularity,0.0,1.0);
    
    specularity=pow(specularity,2.0);
    
   
    float diffuselight=clamp(dot(vertexposition,normalize(normals)),0,1);
    
    
     diffusespecular= vec4(diffuselight)+vec4(specularity);
    

    gl_Position=mvp*vec4(position.xyz,1.0);
}
