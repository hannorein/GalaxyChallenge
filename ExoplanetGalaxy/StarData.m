//
//  StarData.m
//  Exoplanet
//
//  Created by Hanno Rein on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StarData.h"
#import "GLSharedContextWrapper.h"

@implementation StarData

-(void)transferToGPU{
	if (verticesId!=0){
		glDeleteBuffers(1, &verticesId);
	}
	glGenBuffers(1, &verticesId);
	glBindBuffer(GL_ARRAY_BUFFER, verticesId);
	glBufferData(GL_ARRAY_BUFFER, sizeof(float)*8*numStars, (float*)data, GL_DYNAMIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

-(void)drawFrom:(int)from To:(int)to{
	glEnable(GL_POINT_SPRITE_OES);
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, glSharedContextWrapper.cloudTexture.name);
	glTexEnvi( GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE );
	
	glEnableClientState(GL_POINT_SIZE_ARRAY_OES);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, verticesId);

	glVertexPointer(3, GL_FLOAT, 8*sizeof(float), 0);
	glPointSizePointerOES(GL_FLOAT,8*sizeof(float),(GLvoid*) (sizeof(GL_FLOAT)*3));
	glColorPointer(4, GL_FLOAT, 8*sizeof(float), (GLvoid*) (sizeof(GL_FLOAT)*4));
	
	glDrawArrays(GL_POINTS, from, to-from);
	
	glDisableClientState(GL_POINT_SIZE_ARRAY_OES);
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_POINT_SPRITE_OES);

}

-(void)draw{
	[self drawFrom:0 To:numStars];
}

-(void)drawColorless{
	glEnable(GL_POINT_SPRITE_OES);
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, glSharedContextWrapper.cloudTexture.name);
	glTexEnvi( GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE );
	
	glEnableClientState(GL_POINT_SIZE_ARRAY_OES);
	glEnableClientState(GL_VERTEX_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, verticesId);
	
	glPointSizePointerOES(GL_FLOAT,8*sizeof(float),(GLvoid*) (sizeof(GL_FLOAT)*3));
	glVertexPointer(3, GL_FLOAT, 8*sizeof(float), 0);
	
	glDrawArrays(GL_POINTS, 0, numStars);
	
	glDisableClientState(GL_POINT_SIZE_ARRAY_OES);
	glDisableClientState(GL_VERTEX_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_POINT_SPRITE_OES);	
}

-(void)dealloc{
	if (verticesId!=0){
		glDeleteBuffers(1, &verticesId);
	}
	[super dealloc];
}
@end
