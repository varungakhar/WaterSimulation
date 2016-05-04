//
//  OpenGLView.h
//  WaterSimulation
//
//  Created by KindleBit on 04/05/16.
//  Copyright © 2016 KindleBit. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RenderWater.h"
@interface OpenGLView : NSOpenGLView
{
    RenderWater *renderwater;
    
}
@end
