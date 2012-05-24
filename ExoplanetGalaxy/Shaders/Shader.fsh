//
//  Shader.fsh
//  ExoplanetGalaxy
//
//  Created by Hanno Rein on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
