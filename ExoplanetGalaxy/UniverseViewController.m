//
//  EGViewController.m
//  ZweierTEst
//
//  Created by Hanno Rein on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UniverseViewController.h"

@interface UniverseViewController () {
    GLKMatrix4 _modelViewProjectionMatrix;
	GLKMatrix4 modelViewMatrix;
	GLKMatrix4 projectionMatrix;
    float _rotation;
	float _radians_per_pixel;
}

@property (strong, nonatomic) EAGLContext *context;
- (void)setupGL;
- (void)tearDownGL;
@end


@implementation UniverseViewController

@synthesize context = _context;

- (void)dealloc{
    [_context release];
    [super dealloc];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
	_radians_per_pixel = M_PI / self.view.bounds.size.width;
    
    [self setupGL];
	[self initArcBall];
	userScale = 300;
		
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [view addGestureRecognizer:panRecognizer];
    [panRecognizer release];

	UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [view addGestureRecognizer:pinchRecognizer];
    [pinchRecognizer release];
}


- (void) initArcBall{
	userQuarternion = GLKQuaternionMake(0.f, 0.f, 0.f, 1.f);
	iniLocation = CGPointMake(0.f, 0.f);
}

- (void) rotateMatrixWithArcBall:(GLKMatrix4 *)matrix{
	GLKVector3 axis = GLKQuaternionAxis(userQuarternion);
	float angle = GLKQuaternionAngle(userQuarternion);
	if( angle != 0.f )
		*matrix = GLKMatrix4Rotate(*matrix, angle, axis.v[0], axis.v[1], axis.v[2]);
}

// ------------------------------------------------------------------------------------------

- (void) rotateQuaternionWithVector:(CGPoint)delta{
	GLKVector3 up = GLKVector3Make(0.f, 1.f, 0.f);
	GLKVector3 right = GLKVector3Make(-1.f, 0.f, 0.f);
	
	up = GLKQuaternionRotateVector3( GLKQuaternionInvert(userQuarternion), up );
	userQuarternion = GLKQuaternionMultiply(userQuarternion, GLKQuaternionMakeWithAngleAndVector3Axis(delta.x * _radians_per_pixel, up));
	
	right = GLKQuaternionRotateVector3( GLKQuaternionInvert(userQuarternion), right );
	userQuarternion = GLKQuaternionMultiply(userQuarternion, GLKQuaternionMakeWithAngleAndVector3Axis(delta.y * _radians_per_pixel, right));
}

- (void)viewWillAppear:(BOOL)animated{
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	[self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	[super viewWillDisappear:animated];
}

- (void)viewDidUnload{    
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return YES;
}


#pragma mark - User Interaction

CGPoint panVelocity;
CGPoint panInitial;
float   panTimePassed=1;
float	pinchVelocity;
float	pinchInitial;
float   pinchTimePassed=1;

-(void)pan:(UIPanGestureRecognizer*)gesture {
    if ([gesture state] == UIGestureRecognizerStateBegan){
		panInitial = CGPointMake(0, 0);
		panTimePassed=1;
	}
	if ([gesture state] == UIGestureRecognizerStateChanged || [gesture state] == UIGestureRecognizerStateEnded) {
        CGPoint translation = [gesture translationInView:[gesture view]];;
		[self rotateQuaternionWithVector:CGPointMake(translation.x-panInitial.x, -(translation.y-panInitial.y))];
		panInitial = translation;
    }
	if ([gesture state] == UIGestureRecognizerStateEnded){
		panVelocity = [gesture velocityInView:[gesture view]];
		panTimePassed=0;
	}
}

-(void)pinch:(UIPinchGestureRecognizer*)gesture {
	if ([gesture state] == UIGestureRecognizerStateBegan){
		pinchInitial = 1;
		pinchTimePassed = 1;
	}
	if ([gesture state] == UIGestureRecognizerStateChanged || [gesture state] == UIGestureRecognizerStateEnded) {
        float scale = gesture.scale;
		userScale /= scale/pinchInitial;
		pinchInitial = scale;
    }
	if ([gesture state] == UIGestureRecognizerStateEnded){
		pinchVelocity = gesture.velocity;
		pinchTimePassed = 0;
		if (pinchVelocity>7.){
			pinchVelocity = 7.;
		}
		if (pinchVelocity<-7.){
			pinchVelocity = -7.;
		}
	}
}

#pragma mark - OpenGL 

- (void)setupGL{
    [EAGLContext setCurrentContext:self.context];
	urMilkyWay = [[URMilkyWay alloc] init];
}

- (void)tearDownGL{
    [EAGLContext setCurrentContext:self.context];
	[urMilkyWay release];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update{
	if (panTimePassed<1.){
		panTimePassed+=self.timeSinceLastUpdate;
		float slowdown = (1.-panTimePassed)*(1.-panTimePassed);
		[self rotateQuaternionWithVector:CGPointMake(panVelocity.x*self.timeSinceLastUpdate*slowdown, -panVelocity.y*self.timeSinceLastUpdate*slowdown)];
	}
	if (pinchTimePassed<1.){
		pinchTimePassed+=self.timeSinceLastUpdate;
		float slowdown = (1.-pinchTimePassed)*(1.-pinchTimePassed)*(1.-pinchTimePassed)*(1.-pinchTimePassed);		
		userScale /= 1.+pinchVelocity*self.timeSinceLastUpdate*slowdown;
	}
	_rotation += self.timeSinceLastUpdate * 0.025f;

	
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
	projectionMatrix = GLKMatrix4MakeOrtho(-aspect*userScale, aspect*userScale, -1*userScale, 1*userScale, 0.1*userScale, 100.f*userScale);
    
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f*userScale);
	[self rotateMatrixWithArcBall:&baseModelViewMatrix];
    
    // Compute the model view matrix for the object rendered with ES2
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 0.0f, 0.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
	[urMilkyWay drawWithModelViewMatric:modelViewMatrix ProjectionMatrix:projectionMatrix UserScale:userScale];
}

@end
