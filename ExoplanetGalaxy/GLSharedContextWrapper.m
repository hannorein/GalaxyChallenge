//
//  GLSharedContextWrapper.m
//  Exoplanet
//
//  Created by Hanno Rein on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GLSharedContextWrapper.h"
#import "EGAppDelegate.h"

@implementation GLSharedContextWrapper
@synthesize cloudTexture;

+(void)initSingleton{
	if (glSharedContextWrapper==nil){
		glSharedContextWrapper = [[GLSharedContextWrapper alloc] init];
	}
}

-(id)init{
	if (self=[super init]){
	//	sharedContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	//	if (sharedContext == nil){
			sharedContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
	//	}
	}
	return self;
}

-(EAGLContext*) getNewContext{
	return [[EAGLContext alloc] initWithAPI:[sharedContext API] sharegroup:[sharedContext sharegroup]];
}

-(void)load{
	NSAutoreleasePool *arPool = [[NSAutoreleasePool alloc] init];	
	if (!sharedContext || ![EAGLContext setCurrentContext:sharedContext]) {
		NSLog(@"Warning. Cannot create 'sharedContext'.");
	}else{		
        cloudTexture		= [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"texture.png"] filter:GL_LINEAR];
    }
	EGAppDelegate* app = (EGAppDelegate*)[[UIApplication sharedApplication] delegate];
	[app performSelectorOnMainThread:@selector(loadSharedContextDone) withObject:nil waitUntilDone:NO];
	[arPool drain];
}
@end
