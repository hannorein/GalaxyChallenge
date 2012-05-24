//
//  PlanetOrbitViewController.m
//  Exoplanet
//
//  Created by Hanno Rein on 25/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GalaxyViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation GalaxyViewController
@synthesize gv;

- (id)init {
	if (self=[super init]){
		
		gv = [[EAGLGalaxyView alloc] initWithFrame: CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height) ];
		if ([gv respondsToSelector:@selector(setContentScaleFactor:)]){
			gv.contentScaleFactor = [[UIScreen mainScreen] scale];
		}
		
		self.view.autoresizesSubviews = YES;
		gv.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		[self.view addSubview:gv];
		
	}
	return self;
}


-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	// get touch event
	NSSet *to = [event allTouches];
	if ([to count]==1){
		//moving
		NSArray *tArr = [to allObjects];
		touch_start = [[tArr objectAtIndex:0] locationInView:gv];
		distance = 0.0;
	}
	
	if ([to count]==2){
		//calculate distance between two
		NSArray *tArr = [to allObjects];
		CGPoint p1  = [[tArr objectAtIndex:0] locationInView:gv];
		CGPoint p2  = [[tArr objectAtIndex:1] locationInView:gv];
		
		//pythagorize it
		distance = sqrtf(powf(p1.y-p2.y, 2.f) + powf(p1.x-p2.x, 2.f));
	}	
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSSet *to = [event allTouches];
	if ([to count] == 1 && !CGPointEqualToPoint(CGPointZero,touch_start)){
		CGPoint p1 = [[[to allObjects] objectAtIndex:0] locationInView:gv];
		distance = powf(p1.y-touch_start.y, 2.f) + powf(p1.x-touch_start.x, 2.f);
	
		[gv shiftDone];
		if (distance<32.f){
			UITouch *touch = [[event allTouches] anyObject];
			if (touch.tapCount ==1){
				touch_start.y -= gv.frame.origin.y;
				[gv singleTouch:touch_start];
			}else{
				[gv doubleTouch:touch_start];
			}
		}
		touch_start = CGPointZero;
	}
	distance = 0.0;

}

- (void)touchesMoved:(NSSet *)t withEvent:(UIEvent *)event {
	NSSet *to = [event allTouches];
	if ([to count] > 1 && distance == 0.) {
		[gv shiftDone];
		touch_start = CGPointZero;
		[self touchesBegan:t withEvent:event];
		return;
	}
	
	if ([to count] == 1 && !CGPointEqualToPoint(CGPointZero,touch_start)) {
		NSArray *tArr = [to allObjects];
		CGPoint p1 = [[tArr objectAtIndex:0] locationInView:gv];
		[gv shift:touch_start.x-p1.x :touch_start.y-p1.y: touch_start.x: touch_start.y];
	}
	
	
	if ([to count] > 1 && distance > 5.) {
		NSArray *tArr = [to allObjects];
		CGPoint p1 = [[tArr objectAtIndex:0] locationInView:gv];
		CGPoint p2 = [[tArr objectAtIndex:1] locationInView:gv];
		
		//pythagorize it
		float distanceNew = sqrtf(powf(p1.y-p2.y, 2.f) + powf(p1.x-p2.x, 2.f));
		//you can fiddle with the values here to adjust the sensitivity
		float dx	= 1.-(distance-distanceNew)/distance;
		distance	= distanceNew;
		[gv setupViewPort:dx];
		[gv drawView];
	}
}

-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	gv.frame = self.view.frame;	
	[gv setNeedsDisplay];	
}


- (void)viewWillAppear:(BOOL)animated{
	if ([[UIApplication sharedApplication] respondsToSelector:@selector(setStatusBarHidden:withAnimation:)]){
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	}else{
		[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
	}
    [self.navigationController setNavigationBarHidden:YES animated:animated];
		
    [self startAnimation];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self stopAnimation];
	if ([[UIApplication sharedApplication] respondsToSelector:@selector(setStatusBarHidden:withAnimation:)]){
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	}else{
		[[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
	}
    [super viewWillDisappear:animated];
}

-(void) drawFrame{
	[gv drawViewAnimation];
}


- (void)startAnimation
{
    if (!animating){
        animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0)) target:self selector:@selector(drawFrame) userInfo:nil repeats:TRUE];  
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating){
        [animationTimer invalidate];
        animationTimer = nil;
        animating = FALSE;
    }
}


-(void) dealloc{
	[gv release];
	
	[super dealloc];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return YES;
}


@end
