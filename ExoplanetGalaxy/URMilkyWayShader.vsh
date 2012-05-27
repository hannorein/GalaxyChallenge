attribute vec4 Position;
attribute vec4 Color;
attribute float PointSize;

uniform float UserScale;
uniform mat4 modelViewProjectionMatrix;

varying vec2 TextureCoordOut;
varying lowp vec4 colorVarying;

void main(){
	gl_Position = modelViewProjectionMatrix * Position;
	colorVarying = Color;
	// A sqrt dependence on the scale seems to give a good effect
	gl_PointSize = 0.3*PointSize/sqrt(UserScale/300.);
}
