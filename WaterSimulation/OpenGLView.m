//
//  OpenGLView.m
//  WaterSimulation
//
//  Created by KindleBit on 04/05/16.
//  Copyright © 2016 KindleBit. All rights reserved.
//

#import "OpenGLView.h"

@implementation OpenGLView

-(void)awakeFromNib
{
    NSOpenGLPixelFormatAttribute attrs[] =
    {
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFADepthSize, 24,
        NSOpenGLPFAOpenGLProfile,
        NSOpenGLProfileVersion3_2Core,
        0
    };
    NSOpenGLPixelFormat *format=[[NSOpenGLPixelFormat alloc]initWithAttributes:attrs];
    
    NSOpenGLContext *context=[[NSOpenGLContext alloc]initWithFormat:format shareContext:nil];
    [self setPixelFormat:format];
    [self setOpenGLContext:context];
    [[self openGLContext] makeCurrentContext];
    
    NSRect rect=[self bounds];
    
    renderwater=[[RenderWater alloc]initwithframebuffer:rect];
    renderwater.distance=200;
    renderwater.yaw=0;
    renderwater.pitch=0;
    renderwater.cameradirection=GLKVector3Make(0, 0, -1);
    
    
}
-(void)prepareOpenGL
{
    NSTimer* renderTimer = [NSTimer timerWithTimeInterval:0.05   //a 1ms time interval
                            
                                                   target:self
                            
                                                 selector:@selector(timerFired:)
                            
                                                 userInfo:nil
                            
                                                  repeats:YES];
    
    
    [[NSRunLoop currentRunLoop] addTimer:renderTimer
     
                                 forMode:NSDefaultRunLoopMode];
    
    [[NSRunLoop currentRunLoop] addTimer:renderTimer
     
                                 forMode:NSEventTrackingRunLoopMode];
    
    
    
    
}

-(void)timerFired:(NSTimer*)t
{
   [self drawview];

}
-(void)reshape
{
    NSRect rect=[self bounds];
    [renderwater resizeWithWidth:rect];
     [self drawview];

}


- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    [self drawview];
    
}
-(void)drawview
{
    [[self openGLContext] makeCurrentContext];
    CGLLockContext([[self openGLContext] CGLContextObj]);
    
    
    [renderwater render];
    
    
    
    CGLFlushDrawable([[self openGLContext] CGLContextObj]);
    CGLUnlockContext([[self openGLContext] CGLContextObj]);

    
}
-(void)keyDown:(NSEvent*)event
{
    unichar c = [[event charactersIgnoringModifiers] characterAtIndex:0];
    float speed=10;
    if (c==119||c==63232)
    {
        renderwater.modelvector=GLKVector3Add(renderwater.modelvector,GLKVector3MultiplyScalar(renderwater.cameradirection, speed));
    }
    else if (c==115||c==63233)
    {
        renderwater.modelvector=GLKVector3Add(renderwater.modelvector,GLKVector3MultiplyScalar(renderwater.cameradirection, -speed));
        
    }
    
    
    
    [self drawview];
}
-(void)mouseDragged:(NSEvent *)theEvent
{
    
    CGFloat delx=theEvent.deltaX;
    CGFloat dely=theEvent.deltaY;

    
    renderwater.yaw+=delx/20;
    renderwater.pitch+=dely/20;
    
    if (renderwater.pitch>89)
    {
        renderwater.pitch=89;
    }
    
    GLKMatrix4 matrix=GLKMatrix4Identity;
    //
    matrix=GLKMatrix4Rotate(matrix,GLKMathDegreesToRadians(-delx/20), 0, 1, 0);
    //  matrix=GLKMatrix4Rotate(matrix,GLKMathDegreesToRadians(-dely/20), 1, 0, 0);
    
    GLKVector4 direction;
    
    direction=GLKMatrix4MultiplyVector4(matrix,GLKVector4Make(renderwater.cameradirection.x, renderwater.cameradirection.y, renderwater.cameradirection.z, 0));
    direction=GLKVector4Normalize(direction);
    
    
    renderwater.cameradirection=GLKVector3Make(direction.x, direction.y, direction.z);
    

    [self drawview];
    
}
-(void)scrollWheel:(NSEvent *)theEvent
{
    
    CGFloat dely=theEvent.deltaY;
    
    renderwater.distance-=dely;
    
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}
@end
