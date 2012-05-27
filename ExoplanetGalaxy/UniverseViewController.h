//
//  EGViewController.h
//  ZweierTEst
//
//  Created by Hanno Rein on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "UniverseRenderer.h"
#import "URMilkyWay.h"

@interface UniverseViewController : GLKViewController{
	CGPoint			iniLocation;
	GLKQuaternion	userQuarternion;
	float			userScale;
	
	UIButton*	infoButton;
	UIButton*	backButton;
	UIButton*	searchButton;
	UIButton*	homeButton;
	UIButton*	dbButton;
	UIButton*	optionsButton;
	
	URMilkyWay* urMilkyWay;
}

@end
