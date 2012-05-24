//
//  StarData.h
//  Exoplanet
//
//  Created by Hanno Rein on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import "Texture2D.h"


@interface StarData : NSObject {
	GLuint		verticesId;
	int			numStars;
	GLfloat*	data;
}

-(void)draw;
-(void)drawFrom:(int)from To:(int)to;
-(void)drawColorless;
-(void)transferToGPU;
@end
