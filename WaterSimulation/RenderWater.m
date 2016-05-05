//
//  RenderWater.m
//  WaterSimulation
//
//  Created by KindleBit on 04/05/16.
//  Copyright © 2016 KindleBit. All rights reserved.
//
#define ARC4RANDOM_MAX      0x100000000
#import "RenderWater.h"

@implementation RenderWater

@synthesize modelvector;

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
    
  waterprogram=  [self createprogram:@"watervertex" fragment:@"waterfragment"];
    [self water];
    
    
    return self;
}
- (void)resizeWithWidth:(NSRect)size
{
    viewwidth=size.size.width;
    viewheight=size.size.height;
}
-(void)render
{
    glClearColor(0.9, 0.9, 0.9, 1);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, viewwidth, viewheight);

   
    float horizontaldistance=_distance*cos(GLKMathDegreesToRadians(_pitch));
    float verticaldistance=_distance*sin(GLKMathDegreesToRadians(_pitch));
    
    float xoffset=sin(GLKMathDegreesToRadians(180-_yaw))*horizontaldistance;
    float zoffset=cos(GLKMathDegreesToRadians(180-_yaw))*horizontaldistance;

    
cameraposition.x=modelvector.x-xoffset;
cameraposition.y=verticaldistance;
cameraposition.z=modelvector.z-zoffset;
    
    glBindVertexArray(vertexarray);
    GLKMatrix4 prespective=GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60), viewwidth/viewheight, 0.1, 3000);
    
    GLKMatrix4 lookat=[self camera];
    
    GLKMatrix4 model= GLKMatrix4Multiply(GLKMatrix4Identity, GLKMatrix4Multiply(prespective, lookat));
    
  GLKVector4 lightposition=GLKVector4Make(400, 400,100, 1);
    
    
    glUniform4fv(glGetUniformLocation(waterprogram, "lightposition"),1, lightposition.v);
     glUniform4fv(glGetUniformLocation(waterprogram, "eyeposition"),1, cameraposition.v);

glUniformMatrix4fv(glGetUniformLocation(waterprogram, "mvp"),1,GL_FALSE, model.m);
    
    
    double value = 0.0;
    int k=0,m=0;
    for (int z=0; z<waterdimensions; z=z+1)
    {
        for (int x=0; x<waterdimensions; x=x+1)
        {
    
            
            value=sinf(GLKMathDegreesToRadians(m*20))+sinf(GLKMathDegreesToRadians(z+curve)*20);
            
            
            
            if (z%2==0)
            {
                value=0;
            }
            else if(x%2==0)
            {
                value=0;
            }
            else if (x%1==0&&z%1==0)
            {
        value=  ((float)arc4random() / ARC4RANDOM_MAX);;
            }
            else
            {
                value=0;
            }
            
            watervertices[k].position[0]=(float)x/((float)waterdimensions - 1)*800;
            watervertices[k].position[1]=value*5;
            watervertices[k].position[2]=-(float)z/((float)waterdimensions - 1)*800;
            watervertices[k].position[3]=m*20;
            
            watervertices[k].color[0] = (float)x/((float)waterdimensions - 1);
            watervertices[k].color[1] = (float)z/((float)waterdimensions - 1);
            watervertices[k].color[2] = (float)x/((float)waterdimensions - 1);
            watervertices[k].color[3] = (float)z/((float)waterdimensions - 1);
            watervertices[k].normal[0]=0;
            watervertices[k].normal[1]=1;
            watervertices[k].normal[2]=0;
            watervertices[k].normal[3]=1;
            k++;
            

            if(m==9)
            {
                m=0;
            }
            else
            {
                m++;
            }
            
            
        }
    }
    
    int l=0;
    BOOL changetriangle=YES;
    
    const int variable=(waterdimensions-1)*(waterdimensions-1)*2*3;
    GLushort indices[variable];
    for (int row=0; row<waterdimensions-1; row++)
    {
        for (int col=0; col<waterdimensions-1; col++)
        {
            
            if(row%2==0&&col%2==0)
            {
                indices[l++]=waterdimensions*row+col;
                indices[l++]=waterdimensions*row+col+waterdimensions;
                indices[l++]=waterdimensions*row+col+waterdimensions+1;
                
                [self calculatenormals:waterdimensions*row+col b:waterdimensions*row+col+waterdimensions c:waterdimensions*row+col+waterdimensions+1];
                
                indices[l++]=waterdimensions*row+col;
                indices[l++]=waterdimensions*row+col+waterdimensions+1;
                indices[l++]=waterdimensions*row+col+1;
                
                [self calculatenormals:waterdimensions*row+col b:waterdimensions*row+col+waterdimensions+1 c:waterdimensions*row+col+1];
                
                changetriangle=NO;
                
                
            }
            else
            {
                changetriangle=YES;
                
        
                indices[l++]=waterdimensions*row+col;
                indices[l++]=waterdimensions*row+col+1;
                indices[l++]=waterdimensions*row+col+waterdimensions;
        
                [self calculatenormals:waterdimensions*row+col b:waterdimensions*row+col+waterdimensions c:waterdimensions*row+col+waterdimensions+1];
                
                indices[l++]=waterdimensions*row+col+waterdimensions;
                indices[l++]=waterdimensions*row+col+waterdimensions+1;
                indices[l++]=waterdimensions*row+col+1;
                
                [self calculatenormals:waterdimensions*row+col b:waterdimensions*row+col+waterdimensions+1 c:waterdimensions*row+col+1];
                
                
            }
            
           
            
            
            
            
        }
    }
    
      curve++;
    curve=curve%waterdimensions;
  
    
    verticesvalue= sizeof(watervertices);
    indicesvalue=sizeof(indices);
    

    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(watervertices)+sizeof(indices), 0, GL_STATIC_DRAW);

    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(watervertices),watervertices);
    glBufferSubData(GL_ARRAY_BUFFER, sizeof(watervertices), sizeof(indices),indices);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffer);
    
    

  glDrawElements(GL_TRIANGLES,sizeof(GLbyte)*indicesvalue, GL_UNSIGNED_SHORT,(void*)(sizeof(GLbyte)*verticesvalue));
    
}
-(void)calculatenormals:(int)a b:(int)b c:(int)c
{
     GLKVector3 firstvector;
     firstvector.x =  watervertices[a].position[0];
     firstvector.y =  watervertices[a].position[1];
     firstvector.z =  watervertices[a].position[2];
    
    GLKVector3 secondvector;
    secondvector.x =  watervertices[b].position[0];
    secondvector.y =  watervertices[b].position[1];
    secondvector.z =  watervertices[b].position[2];
    
    GLKVector3 thirdvector;
    thirdvector.x =  watervertices[c].position[0];
    thirdvector.y =  watervertices[c].position[1];
    thirdvector.z =  watervertices[c].position[2];
    
    
    GLKVector3 uvector,vvector;
    
    uvector=GLKVector3Subtract(secondvector, firstvector);
     vvector=GLKVector3Subtract(thirdvector, firstvector);
    
    GLKVector3 normals=GLKVector3CrossProduct(vvector, uvector);
   
    normals=GLKVector3Normalize(normals);
    
    
    watervertices[a].normal[0]=normals.x;
    watervertices[a].normal[1]=normals.y;
    watervertices[a].normal[2]=normals.z;
    
    watervertices[b].normal[0]=normals.x;
    watervertices[b].normal[1]=normals.y;
    watervertices[b].normal[2]=normals.z;
    
    watervertices[c].normal[0]=normals.x;
    watervertices[c].normal[1]=normals.y;
    watervertices[c].normal[2]=normals.z;
    
    
   // NSLog(@"%f %f %f",normals.x,normals.y,normals.z);
    
    
    
}
-(GLKMatrix4)camera
{
    GLKMatrix4 matrix=GLKMatrix4Identity;
    matrix=GLKMatrix4Rotate(matrix,GLKMathDegreesToRadians(_pitch),1,0,0);
    matrix=GLKMatrix4Rotate(matrix,GLKMathDegreesToRadians(_yaw),0,1,0);
    GLKVector3 camera=GLKVector3MultiplyScalar(cameraposition, -1);
    matrix= GLKMatrix4Translate(matrix, camera.x, camera.y, camera.z);
    return matrix;
}
-(void)water
{
    double value = 0.0;
    int k=0;
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
    
    verticesvalue= sizeof(watervertices);
    indicesvalue=sizeof(indices);
    

    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(watervertices)+sizeof(indices), 0, GL_STATIC_DRAW);
    
glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(watervertices),watervertices);
glBufferSubData(GL_ARRAY_BUFFER, sizeof(watervertices), sizeof(indices),indices);
glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffer);
    
    [self vao:buffer];
    
    

}
-(void)vao:(GLuint)buffer
{
glGenVertexArrays(1, &vertexarray);
glBindVertexArray(vertexarray);
glEnableVertexAttribArray(glGetAttribLocation(waterprogram, "position"));
glEnableVertexAttribArray(glGetAttribLocation(waterprogram, "color"));
glEnableVertexAttribArray(glGetAttribLocation(waterprogram, "normals"));
    
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glVertexAttribPointer(glGetAttribLocation(waterprogram, "position"), 4, GL_FLOAT, GL_FALSE, sizeof(float)*12, 0);
    glVertexAttribPointer(glGetAttribLocation(waterprogram, "color"),4, GL_FLOAT, GL_FALSE, sizeof(float)*12,(GLvoid*)(sizeof(float)*4));
    glVertexAttribPointer(glGetAttribLocation(waterprogram, "normals"),4, GL_FLOAT, GL_FALSE, sizeof(float)*12,(GLvoid*)(sizeof(float)*8));
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buffer);
    
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
