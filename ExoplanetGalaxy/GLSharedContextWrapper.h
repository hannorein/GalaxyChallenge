//
//  GLSharedContextWrapper.h
//  Exoplanet
//
//  Created by Hanno Rein on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "Texture2D.h"

@interface GLSharedContextWrapper : NSObject{
	EAGLContext*	sharedContext;
	Texture2D*		cloudTexture;
}
@property (readonly) Texture2D*			cloudTexture;

+(void)initSingleton;
-(EAGLContext*) getNewContext;
-(void)load;
@end

//Singleton
GLSharedContextWrapper* glSharedContextWrapper;
