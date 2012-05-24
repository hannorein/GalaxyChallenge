//
//  EAGLView.h
//  OpenGLBasics
//
//  Created by Charlie Key on 6/24/09.
//


#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "Texture2D.h"
#import "StarDataGalaxy.h"

extern float	realtime;
extern float	galaxyViewScale, galaxyViewRotX, galaxyViewRotY;

enum ZOOM_LEVEL {
	ZOOM_UNIVERSE,
	ZOOM_GALAXY,
	ZOOM_NONE,
	ZOOM_PLANETARYSYSTEM
};

enum ZOOM_DIRECTION {
	ZOOMDIRECTION_NONE,
	ZOOMDIRECTION_INWARD,
	ZOOMDIRECTION_OUTWARD
};


@interface EAGLGalaxyView : UIView {
    
@private
	/* The pixel dimensions of the backbuffer */
	GLuint				viewRenderbuffer, viewFramebuffer;
	GLint				backingWidth, backingHeight;
	EAGLContext*		context;
		
	// Zoom/Move Animations
	int					zoomLevel;
	int					zoomDirection;
	float				moveTo;	
    
	float				rottotal_x, rottotal_y;
		

	GLfloat				swidth;
	GLfloat				sheight;
	GLuint				circleID;
	GLuint				circleTextID;
	int					scaleTextureInt;
	Texture2D*			scaleTexture;
		
	
	StarDataGalaxy*		starDataGalaxy;
}

- (id)initWithFrame:(CGRect)frame;

- (void)initData;
- (void)setupView;
- (void)setupViewPort:(float)_dx;

- (void)shift:(float)_x:(float)_y:(float)cx:(float)cy;
- (void)shiftDone;
- (void)singleTouch:(CGPoint)touch_point;
- (void)doubleTouch:(CGPoint)touch_point;


- (void)drawView;
- (void)drawViewAnimation;
- (void)drawStars;
- (void)drawScale;

@end
