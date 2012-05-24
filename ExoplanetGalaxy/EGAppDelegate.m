//
//  EGAppDelegate.m
//  ExoplanetGalaxy
//
//  Created by Hanno Rein on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EGAppDelegate.h"
#import "GalaxyViewController.h"
#import "GLSharedContextWrapper.h"
@implementation EGAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [self loadSharedContext];
    return YES;
}

-(void)loadSharedContext{
	if(glSharedContextWrapper==nil){
		[GLSharedContextWrapper initSingleton];
		[glSharedContextWrapper performSelectorInBackground:@selector(load) withObject:nil];	
	}else{
		[self loadSharedContextDone];
	}
}

-(void)loadSharedContextDone{
    self.viewController = [[[GalaxyViewController alloc] init] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
}

@end
