//
//  Shader.vsh
//  jk
//
//  Created by enghou on 17/2/19.
//  Copyright © 2017年 xyxorigation. All rights reserved.
//

attribute vec4 position;
attribute vec4 normal;
attribute vec2 TextureCoords;



uniform lowp vec4 lightPosition;
uniform lowp vec4 lightColor;
uniform lowp mat4 modelMatrix;
//attribute vec4 color;
varying lowp vec4 colorVarying;
varying vec2 TextureCoordsOut;


void main()
{
    vec4 lightDirection = normalize(vec4(lightPosition.x-position.x,lightPosition.y-position.y,lightPosition.z-position.z,1));
    float strength = dot(lightDirection,normal);
    colorVarying = lightColor * strength;
    TextureCoordsOut = TextureCoords;
//    colorVarying = vec4(0.2,0.4,0.8,1);
    gl_Position = position*modelMatrix;//*projectionMatrix;
}
