//
//  EGAppDelegate.h
//  ExoplanetGalaxy
//
//  Created by Hanno Rein on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalaxyViewController.h"

@class EGViewController;

@interface EGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) GalaxyViewController *viewController;

@end
