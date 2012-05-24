//
//  PlanetOrbitViewController.h
//  Exoplanet
//
//  Created by Hanno Rein on 25/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "EAGLGalaxyView.h"

@interface GalaxyViewController : UIViewController {
	EAGLGalaxyView* gv;

	float distance;
	CGPoint touch_start;
	
	BOOL animating;
	NSTimer *animationTimer;
	
}
@property (readonly) EAGLGalaxyView* gv;

-(void)startAnimation;
-(void)stopAnimation;
@end
