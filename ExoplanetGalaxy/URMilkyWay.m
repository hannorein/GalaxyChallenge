//
//  URMilkyWay.m
//  Exoplanet
//
//  Created by Hanno Rein on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "URMilkyWay.h"


@implementation URMilkyWay

long numStars = 32000;
GLuint _vertexBuffer;

-(id)init{
	if (self=[super init]){
		[self generateMilkyWay];
		
		[self loadTexture:@"texture.png"];
		
		[self addUniform:@"modelViewProjectionMatrix"];
		[self addUniform:@"UserScale"];
		[self addUniform:@"Sampler"];
		
		[self addAttribute:@"Position"];
		[self addAttribute:@"PointSize"];
		[self addAttribute:@"Color"];
		
		[self loadShaders];
	}
	return self;
}


-(void)drawWithModelViewMatric:(GLKMatrix4)modelViewMatrix ProjectionMatrix:(GLKMatrix4)projectionMatrix UserScale:(float)userScale{
	glUseProgram(_program);
	glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindTexture(GL_TEXTURE_2D, [self getTexture:@"texture.png"]);
	
	GLKMatrix4 _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
	glUniformMatrix4fv([self getUniform:@"modelViewProjectionMatrix"], 1, 0, _modelViewProjectionMatrix.m);
    glUniform1f([self getUniform:@"Sampler"], 0);
	glUniform1f([self getUniform:@"UserScale"], userScale);
	
	glEnableVertexAttribArray([self getAttribute:@"Position"]);
	glEnableVertexAttribArray([self getAttribute:@"Color"]);
	glEnableVertexAttribArray([self getAttribute:@"PointSize"]);
	
    glVertexAttribPointer([self getAttribute:@"Position"], 3, GL_FLOAT, GL_FALSE, sizeof(float)*8, 0);
	glVertexAttribPointer([self getAttribute:@"PointSize"], 1, GL_FLOAT, GL_FALSE, sizeof(float)*8, BUFFER_OFFSET(sizeof(float)*3));
	glVertexAttribPointer([self getAttribute:@"Color"], 4, GL_FLOAT, GL_FALSE, sizeof(float)*8, BUFFER_OFFSET(sizeof(float)*4));
	
	glEnable (GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);	
	
    glDrawArrays(GL_POINTS, 0, numStars);

	glDisable (GL_BLEND);
	
	glBindTexture(GL_TEXTURE_2D, 0);
	glDisableVertexAttribArray([self getAttribute:@"Position"]);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

// This is a terrible model that looks like a galaxy.
-(void)generateMilkyWay{
	float* data = malloc(sizeof(float)*8*numStars);
	for (int i=0; i<numStars;i++) {
		float f = (float)rand()/(float)RAND_MAX;
		if (f<0.17){
			// centre
			float r = 0.4f*(float)rand()/(float)RAND_MAX;
			float phi = (float)rand()/(float)RAND_MAX;
			data[i*8+0] = 100.*r*sinf(M_PI*2.f*phi);
			data[i*8+1] = 100.*r*cosf(M_PI*2.f*phi);
			data[i*8+2] = 100.* [self normalD:0.005];
			data[i*8+3] = 3.f+9.f*(float)rand()/(float)RAND_MAX;
			float yellow = 0.9+0.1f*(float)rand()/(float)RAND_MAX;
			data[i*8+4] = 1.;
			data[i*8+5] = .9;
			data[i*8+6] = yellow;
			data[i*8+7] = .6;
		}	
		if(f>=0.17&&f<0.4){
			//arm 1
			float r = 0.4f+0.6*(float)rand()/(float)RAND_MAX+[self normalD:0.1];
			float dphi = [self normalD:0.005];
			float phi = r+[self normalD:0.005];
			data[i*8+0] = 100.*r*sinf(M_PI*2.f*phi);
			data[i*8+1] = 100.*r*cosf(M_PI*2.f*phi);
			data[i*8+2] = 100.*[self normalD:0.003];
			data[i*8+3] = 3.f+9.f*(float)rand()/(float)RAND_MAX;
			float red = 0.9+0.1f*(float)rand()/(float)RAND_MAX;
			if ((float)rand()/(float)RAND_MAX/600.f+(float)rand()/(float)RAND_MAX*dphi*dphi<0.0006f){ red*=0.45;}
			data[i*8+4] = 1.;
			data[i*8+5] = red;
			data[i*8+6] = 1.2*red;
			data[i*8+7] = .6;				
		}
		if (f>=0.4&&f<0.6) {
			//arm 2					
			float r = 0.4f+0.6*(float)rand()/(float)RAND_MAX+[self normalD:0.1];
			float dphi = [self normalD:0.005];
			float phi = r+0.5+dphi;
			data[i*8+0] = 100.*r*sinf(M_PI*2.f*phi);
			data[i*8+1] = 100.*r*cosf(M_PI*2.f*phi);
			data[i*8+2] = 100.*[self normalD:0.003];
			data[i*8+3] = 3.f+9.f*(float)rand()/(float)RAND_MAX;
			float red = 0.9+0.1f*(float)rand()/(float)RAND_MAX;
			if ((float)rand()/(float)RAND_MAX/600.f+(float)rand()/(float)RAND_MAX*dphi*dphi<0.0006f){ red*=0.45;}
			data[i*8+4] = 1.;
			data[i*8+5] = red;
			data[i*8+6] = 1.2*red;
			data[i*8+7] = .6;					
		}
		if (f>=0.6&&f<0.65) {
			//buldge
			float r = 0.4f*(float)rand()/(float)RAND_MAX;
			float phi = 0.9f+[self normalD:0.001];
			float updown = (float)rand()/(float)RAND_MAX;
			if (updown>0.5) {phi+=0.5f;}
			data[i*8+0] = 100.*r*sinf(M_PI*2.f*phi);
			data[i*8+1] = 100.*r*cosf(M_PI*2.f*phi);
			float z = [self normalD:0.0025];
			data[i*8+2] = 100.*z;
			data[i*8+3] = 3.f+9.f*(float)rand()/(float)RAND_MAX;
			float yellow = 0.9+0.1f*(float)rand()/(float)RAND_MAX;
			data[i*8+4] = 1.;
			data[i*8+5] = 0.8;
			data[i*8+6] = yellow;
			data[i*8+7] = .6;					
		}
		if (f>=0.65&&f<0.7) {
			//arm 3					
			float r = 0.35f+0.8*(float)rand()/(float)RAND_MAX;
			float dphi = [self normalD:0.002];
			float phi = r+0.25+dphi;
			data[i*8+0] = 100.*r*sinf(M_PI*2.f*phi);
			data[i*8+1] = 100.*r*cosf(M_PI*2.f*phi);
			float z = [self normalD:0.003];
			data[i*8+2] = 100.*z;
			data[i*8+3] = 3.f+9.f*(float)rand()/(float)RAND_MAX;
			float red = 0.9+0.1f*(float)rand()/(float)RAND_MAX;
			if ((float)rand()/(float)RAND_MAX/600.f+(float)rand()/(float)RAND_MAX*dphi*dphi<0.0006f){ red*=0.45;}
			data[i*8+4] = 1.;
			data[i*8+5] = red;
			data[i*8+6] = 1.2*red;
			data[i*8+7] = .6;					
		}
		if (f>=0.7&&f<0.84) {
			//arm 4				
			float r = 0.15f+0.8*(float)rand()/(float)RAND_MAX;
			float dphi = [self normalD:0.002];
			float phi = r+0.76+dphi;
			data[i*8+0] = 100.*r*sinf(M_PI*2.f*phi);
			data[i*8+1] = 100.*r*cosf(M_PI*2.f*phi);
			float z = [self normalD:0.003];
			data[i*8+2] = 100.*z;
			data[i*8+3] = 3.f+9.f*(float)rand()/(float)RAND_MAX;
			float red = 0.9+0.1f*(float)rand()/(float)RAND_MAX;
			if ((float)rand()/(float)RAND_MAX/600.f+(float)rand()/(float)RAND_MAX*dphi*dphi<0.0006f){ red*=0.45;}
			data[i*8+4] = 1.;
			data[i*8+5] = red;
			data[i*8+6] = 1.2*red;
			data[i*8+7] = .6;					
		}
		if (f>=0.84){
			// halo
			float	x = [self normalD:0.5];
			float	y = [self normalD:0.5];
			float	z = [self normalD:0.07];
			
			data[i*8+0] = 100.*x;
			data[i*8+1] = 100.*y;
			data[i*8+2] = 100.*z;
			data[i*8+3] = 3.f+9.f*(float)rand()/(float)RAND_MAX;
			data[i*8+4] = 1.;
			data[i*8+5] = 1.;
			data[i*8+6] = 1.;
			data[i*8+7] = .6;
		}
		/*
		if (f>=0.96&&f<0.97){
			// dust arm 1
			float r = 0.4f+0.6*(float)rand()/(float)RAND_MAX+[self normalD:0.1];
			float phi = 0.1+r+[self normalD:0.005];
			data[i*8+0] = 100.*r*sinf(M_PI*2.f*phi);
			data[i*8+1] = 100.*r*cosf(M_PI*2.f*phi);
			data[i*8+2] = 100.*[self normalD:0.001];
			data[i*8+3] = 3000.f+9.f*(float)rand()/(float)RAND_MAX;
			data[i*8+4] = 0.;
			data[i*8+5] = 0.;
			data[i*8+6] = 0.;
			data[i*8+7] = 1;
		} 		
		if (f>=0.97&&f<0.98){
			// dust arm 2					
			float r = 0.4f+0.6*(float)rand()/(float)RAND_MAX+[self normalD:0.1];
			float dphi = [self normalD:0.005];
			float phi = 0.1+r+0.5+dphi;
			data[i*8+0] = 100.*r*sinf(M_PI*2.f*phi);
			data[i*8+1] = 100.*r*cosf(M_PI*2.f*phi);
			data[i*8+2] = 100.*[self normalD:0.001];
			data[i*8+3] = 3000.f+9.f*(float)rand()/(float)RAND_MAX;
			data[i*8+4] = 0;
			data[i*8+5] = 0;
			data[i*8+6] = 0;
			data[i*8+7] = 1;
		}
		if (f>=0.98&&f<0.99){
			// dust arm 3					
			float r = 0.35f+0.8*(float)rand()/(float)RAND_MAX;
			float dphi = [self normalD:0.002];
			float phi = 0.1+r+0.25+dphi;
			data[i*8+0] = 100.*r*sinf(M_PI*2.f*phi);
			data[i*8+1] = 100.*r*cosf(M_PI*2.f*phi);
			data[i*8+2] = 100.*[self normalD:0.001];
			data[i*8+3] = 3000.f+9.f*(float)rand()/(float)RAND_MAX;
			data[i*8+4] = 0;
			data[i*8+5] = 0;
			data[i*8+6] = 0;
			data[i*8+7] = 1;
		}
		if (f>=0.99){
			// dust arm 4				
			float r = 0.15f+0.8*(float)rand()/(float)RAND_MAX;
			float dphi = [self normalD:0.002];
			float phi = 0.1+r+0.76+dphi;
			data[i*8+0] = 100.*r*sinf(M_PI*2.f*phi);
			data[i*8+1] = 100.*r*cosf(M_PI*2.f*phi);
			data[i*8+2] = 100.*[self normalD:0.001];
			data[i*8+3] = 3000.f+9.f*(float)rand()/(float)RAND_MAX;
			data[i*8+4] = 0;
			data[i*8+5] = 0;
			data[i*8+6] = 0;
			data[i*8+7] = 1;					
		}
		*/
	}	
	glGenBuffers(1, &_vertexBuffer);
	glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(float)*8*numStars, data, GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	free(data);
}

float		normaldistribution2_rsq;    
float		normaldistribution2_v2;     
BOOL		normaldistribution2_ready = NO; 

-(float)normalD:(float) variance{
	if (normaldistribution2_ready){
		normaldistribution2_ready=false;
		return normaldistribution2_v2*sqrtf(-2.*log(normaldistribution2_rsq)/normaldistribution2_rsq*variance);
	}
	float v1=0,v2=0,rsq=1.f;
	while(rsq>=1.f || rsq<1.0e-6){
		v1=2.f*((float)rand())/((float)(RAND_MAX))-1.0f;
		v2=2.f*((float)rand())/((float)(RAND_MAX))-1.0f;
		rsq=v1*v1+v2*v2;
	}
	normaldistribution2_ready = true;
	normaldistribution2_rsq   = rsq;
	normaldistribution2_v2    = v2;
	return  v1*sqrtf(-2.f*logf(rsq)/rsq*variance);
}


@end
