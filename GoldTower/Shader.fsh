//
//  Shader.fsh
//  jk
//
//  Created by enghou on 17/2/19.
//  Copyright © 2017年 xyxorigation. All rights reserved.
//
precision mediump float;
varying lowp vec4 colorVarying;
uniform sampler2D tex;
varying vec2 TextureCoordsOut;
void main()
{
    gl_FragColor = colorVarying * texture2D(tex,TextureCoordsOut);
}
