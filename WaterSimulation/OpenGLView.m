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

@end
