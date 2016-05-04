#version 410

in vec4 position;
in vec4 color;
in vec4 normals;

out vec4 outcolor;

uniform mat4 mvp;

void main()
{
    outcolor=color;
    
    gl_Position=mvp*position;
}
