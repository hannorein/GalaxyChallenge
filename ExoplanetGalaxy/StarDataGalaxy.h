//
//  StarDataGalaxy.h
//  Exoplanet
//
//  Created by Hanno Rein on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StarData.h"

@interface StarDataGalaxy : StarData {
	float		normaldistribution2_rsq;    
	float		normaldistribution2_v2;     
	float		galaxyViewRotX;
	float		galaxyViewRotY;
	BOOL		normaldistribution2_ready; 
	GLfloat*	data_new;
	int numStars_new;
}
-(float)normalD:(float) variance;
- (bool) isModern;
@property 	float		galaxyViewRotX;
@property	float		galaxyViewRotY;

@end
