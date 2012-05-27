//
//  GalaxyRenderer.m
//  Exoplanet
//
//  Created by Hanno Rein on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UniverseRenderer.h"

@interface UniverseRenderer(){
	NSMutableDictionary* attributes;
	NSMutableDictionary* uniforms;
	NSMutableDictionary* textures;
}
	
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation UniverseRenderer
-(id)init{
	if (self=[super init]){
		attributes	= [[NSMutableDictionary alloc] init];
		uniforms	= [[NSMutableDictionary alloc] init];
		textures	= [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(void)dealloc{
	if (_program) {
		glDeleteProgram(_program);
		_program = 0;
	}
	for (GLKTextureInfo* _texture in textures){
		GLuint name = _texture.name; 
		glDeleteTextures(1, &name);
	}
	[attributes	release];
	[uniforms	release];
	[textures	release];
	[super dealloc];
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader: %@.",file);
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

-(void)addAttribute:(NSString*)_attrib{
	[attributes setValue:[NSNumber numberWithInt:[attributes count]] forKey:_attrib];
}
-(void)addUniform:(NSString*)_uniform{
	[uniforms setValue:[NSNumber numberWithInt:0] forKey:_uniform];
}

-(int)getAttribute:(NSString*)_attrib{
	NSNumber* value = [attributes objectForKey:_attrib];
	if (value) return [value intValue];
	return 0;
}

-(int)getUniform:(NSString*)_uniform{
	NSNumber* value = [uniforms objectForKey:_uniform];
	if (value) return [value intValue];
	return 0;
}

-(void)loadTexture:(NSString*)filename{
	NSError* error=nil;
	GLKTextureInfo* _texture = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:filename].CGImage options:nil error:&error];
	if (error) {
		NSLog(@"Error while loading texture from file %@.",filename);
	}else{
		[textures setValue:_texture forKey:filename];
	}
}

-(unsigned int)getTexture:(NSString*)filename{
	GLKTextureInfo* _texture = [textures objectForKey:filename];
	return _texture.name;
}

- (BOOL)loadShaders{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"URMilkyWayShader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"URMilkyWayShader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
	for (NSString* key in attributes){
		NSNumber* value = [attributes objectForKey:key];
		glBindAttribLocation(_program, [value intValue], [key cStringUsingEncoding:NSASCIIStringEncoding]);
	}
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
	NSArray* keys  = [[uniforms allKeys] copy];
	for (NSString* key in keys){
		[uniforms setValue:[NSNumber numberWithInt:glGetUniformLocation(_program, [key cStringUsingEncoding:NSASCIIStringEncoding])] forKey:key];
	}
	[keys release];
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

@end
