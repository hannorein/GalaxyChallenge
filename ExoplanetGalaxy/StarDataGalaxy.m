//
//  dataGalaxy.m
//  Exoplanet
//
//  Created by Hanno Rein on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StarDataGalaxy.h"
#import <sys/utsname.h> 
#import "GLSharedContextWrapper.h"
#define SUNOFFSET (.7f)


@implementation StarDataGalaxy
@synthesize galaxyViewRotX,galaxyViewRotY;

-(id)init{
	self = [super init];
    if (self) {
        numStars = 32000;
        
		data = malloc(sizeof(float)*8*numStars);
		data_new = nil;
		normaldistribution2_ready = NO;
		// Generate Data
		for (int i=0; i<numStars;i++) {
			float f = (float)rand()/(float)RAND_MAX;
			if (f<0.17){
				// centre
				float r = 0.4f*(float)rand()/(float)RAND_MAX;
				float phi = (float)rand()/(float)RAND_MAX;
				data[i*8+0] = 100.*r*sinf(M_PI*2.f*phi);
				data[i*8+1] = 100.*r*cosf(M_PI*2.f*phi) + 100.*SUNOFFSET;
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
				data[i*8+1] = 100.*r*cosf(M_PI*2.f*phi) +100.*SUNOFFSET;
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
				data[i*8+1] = 100.*r*cosf(M_PI*2.f*phi) + 100.*SUNOFFSET;
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
				data[i*8+1] = 100.*r*cosf(M_PI*2.f*phi) + 100.*SUNOFFSET;
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
				data[i*8+1] = 100.*r*cosf(M_PI*2.f*phi) + 100.*SUNOFFSET;
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
				data[i*8+1] = 100.*r*cosf(M_PI*2.f*phi) + 100.*SUNOFFSET;
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
				data[i*8+1] = 100.*y+100.*SUNOFFSET;
				data[i*8+2] = 100.*z;
				data[i*8+3] = 3.f+9.f*(float)rand()/(float)RAND_MAX;
				data[i*8+4] = 1.;
				data[i*8+5] = 1.;
				data[i*8+6] = 1.;
				data[i*8+7] = .6;
			}
		}
		
    }
    return self;
}
- (bool) isModern{
	return NO;
	struct utsname systemInfo;
    uname(&systemInfo);
    NSString* name = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
	if ([name isEqualToString:@"iPod1,1"]) return NO;
	if ([name isEqualToString:@"iPod2,1"]) return NO;
	if ([name isEqualToString:@"iPod3,1"]) return NO;
	if ([name isEqualToString:@"iPhone1,1"]) return NO;
	if ([name isEqualToString:@"iPhone1,2"]) return NO;
	if ([name isEqualToString:@"iPad1,1"]) return NO;
	return YES;
}

-(void)draw{
	if ([self isModern]){
		const float texturescale = 40;
		if (data_new==nil){
			numStars_new = 512;
			data_new = malloc(sizeof(float)*3*numStars_new);
			// Generate Data
			for (int i=0; i<numStars_new;i++) {
				float f = (float)rand()/(float)RAND_MAX;
				if (f<100.){
					// centre
					float r = 1.2f*(float)rand()/(float)RAND_MAX;
					float phi = (float)rand()/(float)RAND_MAX;
					data_new[i*3+0] = 100 * r*sinf(M_PI*2.f*phi);
					data_new[i*3+1] = 100 * r*cosf(M_PI*2.f*phi) + 100.*SUNOFFSET;
					data_new[i*3+2] = 100 * [self normalD:0.005/(r+0.1)];
				}	
			}
		}
		
	
		
		float cosfX = cosf(-galaxyViewRotX/180.*M_PI);
		float sinfX = sinf(-galaxyViewRotX/180.*M_PI);
		
		
		glEnable(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D, glSharedContextWrapper.cloudTexture.name);
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		
		glPushMatrix();
		glColor4f(1, 1, 1, 0.05);
		

        for (int i=0; i<numStars_new;i++) {
			glTranslatef(data_new[i*3+0],  data_new[i*3+1],  data_new[i*3+2]);
			glRotatef(-galaxyViewRotY, cosfX, sinfX, 0.);
			glRotatef(-galaxyViewRotX, 0, 0, 1);
			glScalef(texturescale, texturescale, texturescale);
			[glSharedContextWrapper.cloudTexture drawAtCenter];
			glScalef(1./texturescale, 1./texturescale, 1./texturescale);
			glRotatef( galaxyViewRotX, 0, 0, 1);
			glRotatef( galaxyViewRotY, cosfX, sinfX, 0.);
			glTranslatef(-data_new[i*3+0], -data_new[i*3+1], -data_new[i*3+2]);
		}
		

		glPopMatrix();
		
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		glDisableClientState(GL_VERTEX_ARRAY);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		glDisable(GL_TEXTURE_2D);
    }
    
	[super draw];
}



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

-(void)dealloc{
	free(data);
	free(data_new);
	[super dealloc];
}

@end
