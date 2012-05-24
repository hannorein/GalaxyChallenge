//
//  EAGLView.m
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "EAGLGalaxyView.h"
#import "GLSharedContextWrapper.h"

// Global variables (there is only one Galaxy View at a time)
float	realtime;
float	galaxyViewScale, galaxyViewRotX, galaxyViewRotY;

@interface EAGLGalaxyView ()

@property (nonatomic, retain) EAGLContext *context;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

@end


@implementation EAGLGalaxyView
@synthesize context;

// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

//Created GlView
- (id)initWithFrame:(CGRect)frame{
	if ((self = [super initWithFrame:frame])) {

		CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		
		eaglLayer.opaque = YES;
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		
		context = [glSharedContextWrapper getNewContext];

		
		if (!context || ![EAGLContext setCurrentContext:context]) {
			[self release];
			NSLog(@"Cancel loading EAGLGalaxyView");
			return nil;
		}
		
		starDataGalaxy	= [[StarDataGalaxy alloc] init];
		[starDataGalaxy		transferToGPU];
		zoomLevel		= ZOOM_GALAXY;
		galaxyViewScale	= 0.005;
		galaxyViewRotX	= 0;
		galaxyViewRotY	= 0;

		// Init stuff
		moveTo					= 0.;
		zoomDirection			= ZOOMDIRECTION_NONE;
		if (zoomLevel!=ZOOM_GALAXY||zoomLevel!=ZOOM_PLANETARYSYSTEM) zoomLevel = ZOOM_GALAXY;
		rottotal_x				= galaxyViewRotX;
		rottotal_y				= galaxyViewRotY;
		realtime				= 0.f;
		[self initData];
    }
	
	return self;
}

-(void)initData{
#define CIRCLEHIGHRES_NUMP 512
#define CIRCLEHIGHRESTEXT_NUMP 32
	GLfloat* circleDataTexture = malloc(CIRCLEHIGHRESTEXT_NUMP*(3+2)*2*sizeof(GLfloat));
	
	for (int i=0;i<CIRCLEHIGHRESTEXT_NUMP;i++){
		circleDataTexture[i*(3+2)*2+0] = cosf((float)i*1.5f*M_PI/(float)CIRCLEHIGHRESTEXT_NUMP);
		circleDataTexture[i*(3+2)*2+1] = sinf((float)i*1.5f*M_PI/(float)CIRCLEHIGHRESTEXT_NUMP);
		circleDataTexture[i*(3+2)*2+2] = 0.0f;
		circleDataTexture[i*(3+2)*2+3] = (float)i/(float)CIRCLEHIGHRESTEXT_NUMP;
		circleDataTexture[i*(3+2)*2+4] = 1.0f;
		circleDataTexture[i*(3+2)*2+5] = 1.3f*cosf((float)i*1.5f*M_PI/(float)CIRCLEHIGHRESTEXT_NUMP);
		circleDataTexture[i*(3+2)*2+6] = 1.3f*sinf((float)i*1.5f*M_PI/(float)CIRCLEHIGHRESTEXT_NUMP);
		circleDataTexture[i*(3+2)*2+7] = 0.0f;
		circleDataTexture[i*(3+2)*2+8] = (float)i/(float)CIRCLEHIGHRESTEXT_NUMP;
		circleDataTexture[i*(3+2)*2+9] = 0.0f;
	}
	 
		if (circleTextID!=0){
		glDeleteBuffers(1, &circleTextID);
	}
	glGenBuffers(1, &circleTextID);
	glBindBuffer(GL_ARRAY_BUFFER, circleTextID);
	glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*(3+2)*2*CIRCLEHIGHRESTEXT_NUMP, (GLfloat*)circleDataTexture, GL_DYNAMIC_DRAW);
	free(circleDataTexture);

	float* circleData = malloc(CIRCLEHIGHRES_NUMP*3*sizeof(GLfloat));
	for (int i=0;i<CIRCLEHIGHRES_NUMP;i++){
		circleData[i*3+0] = cosf((float)i*2.0f*M_PI/(float)CIRCLEHIGHRES_NUMP);
		circleData[i*3+1] = sinf((float)i*2.0f*M_PI/(float)CIRCLEHIGHRES_NUMP);
		circleData[i*3+2] = 0.0f;
	}
	if (circleID!=0){
		glDeleteBuffers(1, &circleID);
	}
	glGenBuffers(1, &circleID);
	glBindBuffer(GL_ARRAY_BUFFER, circleID);
	glBufferData(GL_ARRAY_BUFFER, sizeof(float)*3*CIRCLEHIGHRES_NUMP, (float*)circleData, GL_DYNAMIC_DRAW);
	free(circleData);
	
	[self setNeedsLayout];
}

- (void)setupView {
	glEnable(GL_BLEND );
    glBlendFunc(GL_SRC_ALPHA, GL_ONE );
	glShadeModel(GL_SMOOTH);
	if ([self respondsToSelector:@selector(setContentScaleFactor:)]){
		glLineWidth(self.contentScaleFactor);
	}

	
	glEnable(GL_LIGHTING);
	float global_ambient[] = { 0.0f, 0.0f, 0.0f, 0.0f };
	glLightModelfv(GL_LIGHT_MODEL_AMBIENT, global_ambient);
	
	glEnable(GL_LIGHT0);
    float diffuse0[] = {1.0f, 1.0f, 1.0f, 1.0f};
    glLightfv(GL_LIGHT0, GL_DIFFUSE, diffuse0);
	float ambient0[] = { 0.15f, 0.15f, 0.15f };
	glLightfv(GL_LIGHT0, GL_AMBIENT, ambient0);
	glDisable(GL_LIGHT0);
	glDisable(GL_LIGHTING);
	
	[self setupViewPort:1.];
	glLoadIdentity();
	
	glClearColor(0.f, 0.f, 0.f, 1.0f);	
}


- (void) setupViewPort:(float)_dx{
	galaxyViewScale *= _dx;


    /*
	if (zoomLevel== ZOOM_GALAXY){
		if (galaxyViewScale < 0.0004999f){
			zoomLevel = ZOOM_UNIVERSE;
			galaxyViewScale = 50.f;	
		}else{
		if (galaxyViewScale > 500.f){
			galaxyViewScale = 1.58125e-5;
			zoomLevel = ZOOM_PLANETARYSYSTEM;
		}
		}
	}
     */
	
	
	sheight = 1.6/galaxyViewScale;
	CGRect rect = self.frame;
	if ([self respondsToSelector:@selector(setContentScaleFactor:)]){
		rect.size.height *= self.contentScaleFactor;
		rect.size.width *= self.contentScaleFactor;
	}

	swidth = sheight/(rect.size.height/rect.size.width);
	glViewport(0, 0, rect.size.width, rect.size.height);
}

#define fieldOfView  60.0
#define SUNOFFSET (0.7f)

- (void)shift:(float)_x:(float)_y:(float)cx:(float)cy{
	//float size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
	CGRect rect = self.frame;
	if ([self respondsToSelector:@selector(setContentScaleFactor:)]){
		rect.size.height *= self.contentScaleFactor;
		rect.size.width *= self.contentScaleFactor;
	}

	float offset_y;
	if (galaxyViewScale>1.){
		offset_y = - 1.f/(sqrtf(galaxyViewScale)*galaxyViewScale) * SUNOFFSET;	
	}else {
		offset_y = - SUNOFFSET;	
	}
	
	float fy = rect.size.height/2.*(1-offset_y/sheight);
	
	galaxyViewRotX = rottotal_x - ((fy-cy>0)?1.f:-1.f)*4.f*_x/rect.size.width * fieldOfView;
	galaxyViewRotY = rottotal_y - 4.f*_y/rect.size.width * fieldOfView;
	
	[self drawView];
}


-(void)shiftDone{
	rottotal_x= galaxyViewRotX;
	rottotal_y= galaxyViewRotY;
}


- (void)singleTouch:(CGPoint)touch_point{
    // Routine to select planet was here.
}

- (void)doubleTouch:(CGPoint)touch_point{
	if (zoomLevel == ZOOM_PLANETARYSYSTEM && moveTo <=0.f){
		zoomDirection = ZOOMDIRECTION_OUTWARD;
	}
	if (zoomLevel != ZOOM_PLANETARYSYSTEM && moveTo <=0.f){
		zoomDirection = ZOOMDIRECTION_INWARD;
	}
}

/***************
 ** DRAW VIEW
 ***************/

- (void)drawView {
	[EAGLContext setCurrentContext:context];
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glClear(GL_COLOR_BUFFER_BIT); 
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	
	///////////////////////////////
	//////// GL_PROJECTION ////////
	///////////////////////////////
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	if (zoomLevel==ZOOM_GALAXY || zoomLevel==ZOOM_UNIVERSE)
		glOrthof(swidth, -swidth, -sheight, sheight, -10000., 10000.0);
	if (zoomLevel==ZOOM_PLANETARYSYSTEM)
		glOrthof(swidth, -swidth, -sheight, sheight, -60000., 60000.0);
	
	if (zoomLevel==ZOOM_GALAXY){
		if (galaxyViewScale>0.01){
			glTranslatef(0.f,-0.1f/(sqrtf(galaxyViewScale)*galaxyViewScale)*SUNOFFSET,-1);	
		}else {
			glTranslatef(0.f,-SUNOFFSET*100.,-1);	
		}
	}else{
		glTranslatef(0.f,0.f,-1);	
	}
	if(zoomLevel==ZOOM_UNIVERSE){
		glTranslatef(0.f,-SUNOFFSET*0.001,0);	
	}
	glRotatef(+galaxyViewRotX, 0, 0, 1.);
	glRotatef(+galaxyViewRotY, cosf(-galaxyViewRotX/180.*M_PI), sinf(-galaxyViewRotX/180.*M_PI), 0.);

	///////////////////////////////
	//////// GL_MODELVIEW  ////////
	///////////////////////////////
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
		
	// Keep Light fixesd at origin
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	float light_position0[] = { 0.0, 0.0, 0.0, 1.0 };
    glLightfv(GL_LIGHT0, GL_POSITION, light_position0);
	glDisable(GL_LIGHT0);
	glDisable(GL_LIGHTING);
	
    [self drawScale];

	if (zoomLevel==ZOOM_GALAXY){
		[self drawStars];		
	}

	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void) drawViewAnimation{
	// Camera movement for animation was here.
	[self drawView];
	realtime += 1.f/60.f;
}



- (void)drawScale{	
	#define scalesNUM 15
	GLfloat		scalesValGalaxy[scalesNUM] = {0.1f/500.f,0.474375f/500.f,1.f/500.f,3.f/500.f,10.f/500.f,30.f/500.f,100.f/500.f,300.f/500.f,1000.f/500.f,3000.f/500.f,10000.f/500.f,30000.f/500.f,100000.f/500.f,300000.f/500.f,10000.f/5.f};
	NSString*	scalesTxtGalaxy[scalesNUM] = {@"NA",@"30000 astronomical units",@"1 lightyear",@"3 lightyears",@"10 lightyears",@"30 lightyears",@"100 lightyears",@"300 lightyears",@"1000 lightyears",@"3000 lightyears",@"10000 lightyears",@"30000 lightyears",@"100000 lightyears",@"300000 lightyears",@"1 million lightyears"};
	
	int textureSize=512;
	float textureFontSize = 25.;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		textureSize=1024; //High res for iPad
		textureFontSize=50.;
	}
	
	glEnableClientState(GL_VERTEX_ARRAY);
	
	GLfloat*   scalesVal = scalesValGalaxy;
	NSString** scalesTxt = scalesTxtGalaxy;
		
	for (int i=0;i<scalesNUM;i++){
		float cur = scalesVal[i];
		
		glScalef(cur,cur,cur);
		float al = expf(-(.5/cur-galaxyViewScale)*(.5/cur-galaxyViewScale)/0.125/galaxyViewScale/galaxyViewScale);
		al = (al>1.f)?1.f:al;
		if (al>0.06){
			if (scaleTextureInt!=i||scaleTexture==nil){
				scaleTextureInt = i;
				if (scaleTexture!=nil){
					[scaleTexture release];
					scaleTexture = nil;
				}
				scaleTexture =[[Texture2D alloc] initWithString:scalesTxt[i] dimensions:CGSizeMake(textureSize,textureSize/16) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:textureFontSize];	
			}
			
			glColor4f(0.2f, 0.2f, 1.f, al);
			glEnable(GL_TEXTURE_2D);			
			glBindBuffer(GL_ARRAY_BUFFER,circleTextID);
			glVertexPointer(3,GL_FLOAT,		5*sizeof(GLfloat), 0);
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);	
			glTexCoordPointer(2, GL_FLOAT,	5*sizeof(GLfloat), (void*)(3*sizeof(GLfloat)));
			glBindTexture(GL_TEXTURE_2D, scaleTexture.name);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, CIRCLEHIGHRESTEXT_NUMP*2);
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			glDisable(GL_TEXTURE_2D);
		}
		al = expf(-(.5/cur-galaxyViewScale)*(.5/cur-galaxyViewScale)/0.5/galaxyViewScale/galaxyViewScale);;
		al = (al>1.f)?1.f:al;
		if (al>0.06){
			glColor4f(0.f, 0.f, 1.f, al);
			glBindBuffer(GL_ARRAY_BUFFER, circleID);
			glVertexPointer(3, GL_FLOAT, 3*sizeof(float), 0);		
			glDrawArrays(GL_LINE_LOOP, 0, CIRCLEHIGHRES_NUMP);
			glBindBuffer(GL_ARRAY_BUFFER, 0);
		}	
		glScalef(1.f/cur,1.f/cur,1.f/cur);
	}
	glDisableClientState(GL_VERTEX_ARRAY);
}


- (void)drawStars{	
	starDataGalaxy.galaxyViewRotX = galaxyViewRotX;
	starDataGalaxy.galaxyViewRotY = galaxyViewRotY;
	
    float optStarSize = 0.5f;
	GLfloat attenuate[4] = { .013/(optStarSize * galaxyViewScale), 0,0,0 };  //Const, linear, quadratic ;
	if ([self respondsToSelector:@selector(setContentScaleFactor:)]){
		attenuate[0] *= 1./(self.contentScaleFactor*self.contentScaleFactor);
	}
	glPointParameterfv(GL_POINT_DISTANCE_ATTENUATION, attenuate);
 	glPointParameterf( GL_POINT_SIZE_MIN, 1.0f ); 
	glPointParameterf( GL_POINT_SIZE_MAX, 16.0f ); 
    [starDataGalaxy draw];
	
}

- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
    if (viewFramebuffer!=0) [self destroyFramebuffer];
    [self createFramebuffer];
	[self setupView];
	[self drawView];
}

- (BOOL)createFramebuffer {
	
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}


- (void)destroyFramebuffer {
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
}

- (void)dealloc {    	
	[EAGLContext setCurrentContext:context];
	
	[starDataGalaxy release];
	
	if (circleID!=0){
		glDeleteBuffers(1, &circleID);
	}
	if (circleTextID!=0){
		glDeleteBuffers(1, &circleTextID);
	}
	if (scaleTexture){
		[scaleTexture  release];
	}
	
	if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    [context release];  
		
    [super dealloc];
}


@end
