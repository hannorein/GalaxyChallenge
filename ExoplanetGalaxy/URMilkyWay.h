//
//  URMilkyWay.h
//  Exoplanet
//
//  Created by Hanno Rein on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UniverseRenderer.h"

@interface URMilkyWay : UniverseRenderer{
}
-(void)drawWithModelViewMatric:(GLKMatrix4)modelViewMatrix ProjectionMatrix:(GLKMatrix4)projectionMatrix UserScale:(float)userScale;
@end
