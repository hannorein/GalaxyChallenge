uniform sampler2D Sampler;
varying lowp vec4 colorVarying;

void main(){
    gl_FragColor = texture2D(Sampler, gl_PointCoord)*colorVarying;
}