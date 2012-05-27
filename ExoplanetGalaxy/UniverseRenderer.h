//
//  GalaxyRenderer.h
//  Exoplanet
//
//  Created by Hanno Rein on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#define BUFFER_OFFSET(i) ((char *)NULL + (i))


@interface UniverseRenderer : NSObject{
	GLuint _program;
}

- (BOOL)loadShaders;


-(void)addAttribute:(NSString*)_attrib;
-(void)addUniform:(NSString*)_uniform;
-(int)getAttribute:(NSString*)_attrib;
-(int)getUniform:(NSString*)_uniform;

-(void)loadTexture:(NSString*)filename;
-(unsigned int)getTexture:(NSString*)filename;

@end
