//
//  RenderWater.m
//  WaterSimulation
//
//  Created by KindleBit on 04/05/16.
//  Copyright © 2016 KindleBit. All rights reserved.
//

#import "RenderWater.h"

@implementation RenderWater

typedef struct
{
    float position[4];
    float color[4];
    float normal[4];
    
}watervertex;

const int waterdimensions=90;

static watervertex watervertices[waterdimensions*waterdimensions];




-(instancetype)initwithframebuffer:(NSRect)size
{
    
    
    viewwidth=size.size.width;
    viewheight=size.size.height;
    glEnable(GL_DEPTH_TEST);
    
    [self createprogram:@"watervertex" fragment:@"waterfragment"];
    
    return self;
}
- (void)resizeWithWidth:(NSRect)size
{
    viewwidth=size.size.width;
    viewheight=size.size.height;
}
-(void)render
{
    glClearColor(0, 0, 1, 1);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, viewwidth, viewheight);
}

-(void)water
{
    double value = 0.0;
    int k=0,m=0;
    for (int i=0; i<waterdimensions; i=i+1)
    {
        for (int j=0; j<waterdimensions; j=j+1)
        {
            float vv=1;
           
            
            watervertices[k].position[0]=200+(float)j/((float)waterdimensions - 1)*400;
            watervertices[k].position[1]=value;
            watervertices[k].position[2]=-60-(float)i/((float)waterdimensions - 1)*400;
            watervertices[k].position[3]=vv;
            
            watervertices[k].color[0] = (float)j/((float)waterdimensions - 1);
            watervertices[k].color[1] = (float)i/((float)waterdimensions - 1);
            watervertices[k].color[2] = (float)j/((float)waterdimensions - 1);
            watervertices[k].color[3] = (float)i/((float)waterdimensions - 1);
            watervertices[k].normal[0]=0;
            watervertices[k].normal[1]=1;
            watervertices[k].normal[2]=0;
            watervertices[k].normal[3]=1;
            k++;
        
            
        }
    }
    
    int l=0;
    const int variable=(waterdimensions-1)*(waterdimensions-1)*2*3;
    GLushort indices[variable];
    for (int row=0; row<waterdimensions-1; row++)
    {
        for (int col=0; col<waterdimensions-1; col++)
        {
            indices[l++]=waterdimensions*row+col;
            indices[l++]=waterdimensions*row+col+waterdimensions;
            indices[l++]=waterdimensions*row+col+waterdimensions+1;
            indices[l++]=waterdimensions*row+col;
            indices[l++]=waterdimensions*row+col+waterdimensions+1;
            indices[l++]=waterdimensions*row+col+1;
        }
    }
    
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(watervertices)+sizeof(indices), 0, GL_STATIC_DRAW);
    
glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(watervertices),watervertices);
glBufferSubData(GL_ARRAY_BUFFER, sizeof(watervertices), sizeof(indices),indices);
glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffer);

}
-(void)vao
{

    
}


-(GLuint)createprogram:(NSString *)vertex fragment:(NSString*)fragment
{
GLuint program=glCreateProgram();
GLuint vertexshader=[self createshader:vertex type:GL_VERTEX_SHADER];
GLuint fragmentshader=[self createshader:fragment type:GL_FRAGMENT_SHADER];
glAttachShader(program, vertexshader);
glAttachShader(program, fragmentshader);
glLinkProgram(program);
    
    GLint status;
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    
    if (status==GL_FALSE)
    {
        GLchar message[256];
        glGetProgramInfoLog(program, sizeof(message), 0, &message[0]);
        NSString *string=[NSString stringWithUTF8String:message];
        
        NSLog(@"%@",string);
        
    }
    
glUseProgram(program);
    return program;
}

-(GLuint)createshader:(NSString *)shaders type:(GLenum)type
{
    GLuint handleshader;
   handleshader=glCreateShader(type);
    
    NSString *path=[[NSBundle mainBundle]pathForResource:shaders ofType:@"glsl"];
    NSString *data=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
   const char *shadersource=[data UTF8String];
    
    glShaderSource(handleshader, 1, &shadersource,0);
    
    glCompileShader(handleshader);
    
    GLint status;
    glGetShaderiv(handleshader, GL_COMPILE_STATUS, &status);
    
    if (status==GL_FALSE)
    {
        GLchar message[256];
        glGetShaderInfoLog(handleshader, sizeof(message), 0, &message[0]);
        NSString *string=[NSString stringWithUTF8String:message];
        NSLog(@"%@",string);
        
    }
    
    return handleshader;
}

@end
