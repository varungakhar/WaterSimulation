//
//  RenderWater.h
//  WaterSimulation
//
//  Created by KindleBit on 04/05/16.
//  Copyright © 2016 KindleBit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
#import <GLKit/GLKit.h>
@interface RenderWater : NSObject
{
    GLuint viewwidth;
    GLuint viewheight;
}
-(instancetype)initwithframebuffer:(NSRect)size;
- (void)resizeWithWidth:(NSRect)size;
-(void)render;
@end
