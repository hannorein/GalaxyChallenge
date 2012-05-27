//
//  EGAppDelegate.m
//  ExoplanetGalaxy
//
//  Created by Hanno Rein on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EGAppDelegate.h"
#import "UniverseViewController.h"
@implementation EGAppDelegate

@synthesize window = _window;

- (void)dealloc{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.rootViewController = [[[UniverseViewController alloc] init] autorelease];
    [self.window makeKeyAndVisible];

    return YES;
}



@end
