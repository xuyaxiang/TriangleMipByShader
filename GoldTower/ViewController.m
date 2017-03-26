//
//  ViewController.m
//  GoldTower
//
//  Created by enghou on 17/3/20.
//  Copyright © 2017年 xyxorigation. All rights reserved.
//

#import "ViewController.h"
typedef enum
{
    AGLK1 = 1,
    AGLK2 = 2,
    AGLK4 = 4,
    AGLK8 = 8,
    AGLK16 = 16,
    AGLK32 = 32,
    AGLK64 = 64,
    AGLK128 = 128,
    AGLK256 = 256,
    AGLK512 = 512,
    AGLK1024 = 1024,
}
AGLKPowerOf2;

static NSData *AGLKDataWithResizedCGImageBytes(
                                               CGImageRef cgImage,
                                               size_t *widthPtr,
                                               size_t *heightPtr);

static AGLKPowerOf2 AGLKCalculatePowerOf2ForDimension(
                                                      GLuint dimension);
typedef struct {
    GLKVector3  position;
    GLKVector3  normal;
    GLKVector4  color;
    GLKVector2 texCoords;
}
SceneVertex;

typedef struct {
    SceneVertex vertices[3];
}
SceneTriangle;

static const SceneVertex vertexA =
{{-0.5,  0.5, 0}, {0.0, 0.0, 1.0},{1,1,1,1},{0,1}};
static const SceneVertex vertexB =
{{-0.5,  0.0, 0}, {0.0, 0.0, 1.0},{1,1,1,1},{0,0.5}};
static const SceneVertex vertexC =
{{-0.5, -0.5, 0}, {0.0, 0.0, 1.0},{1,1,1,1},{0,0}};
static const SceneVertex vertexD =
{{ 0.0,  0.5, 0}, {0.0, 0.0, 1.0},{1,1,1,1},{0.5,1}};
static const SceneVertex vertexE =
{{ 0.0,  0.0, 0.5}, {0.0, 0.0, 1.0},{1,1,1,1},{0.5,0.5}};
static const SceneVertex vertexF =
{{ 0.0, -0.5, 0}, {0.0, 0.0, 1.0},{1,1,1,1},{0.5,0}};
static const SceneVertex vertexG =
{{ 0.5,  0.5, 0}, {0.0, 0.0, 1.0},{1,1,1,1},{1,1}};
static const SceneVertex vertexH =
{{ 0.5,  0.0, 0}, {0.0, 0.0, 1.0},{1,1,1,1},{1,0.5}};
static const SceneVertex vertexI =
{{ 0.5, -0.5, 0}, {0.0, 0.0, 1.0},{1,1,1,1},{1,0}};

SceneTriangle triangle[8];


@interface ViewController ()
@property(nonatomic,assign)GLuint program;
@property(nonatomic,assign)int lightPositionP;
@property(nonatomic,assign)int lightColor;
@property(nonatomic,assign)int modelMatrix;
@property(nonatomic,assign)int viewMatrix;
@property(nonatomic,assign)GLint texCoords;
@property(nonatomic,assign)GLuint texture;
@end

@implementation ViewController{
    GLKBaseEffect *effect;
}
-(void)makeTriangles{
    triangle[0] = [self makeTriangle:vertexA B:vertexB C:vertexD];
    triangle[1] = [self makeTriangle:vertexG B:vertexD C:vertexH];
    triangle[2] = [self makeTriangle:vertexH B:vertexF C:vertexI];
    triangle[3] = [self makeTriangle:vertexB B:vertexC C:vertexF];
    triangle[4] = [self makeTriangle:vertexD B:vertexB C:vertexE];
    triangle[5] = [self makeTriangle:vertexD B:vertexE C:vertexH];
    triangle[6] = [self makeTriangle:vertexH B:vertexE C:vertexF];
    triangle[7] = [self makeTriangle:vertexF B:vertexE C:vertexB];
}

-(SceneTriangle)makeTriangle:(SceneVertex)A B:(SceneVertex)B C:(SceneVertex)C{
    SceneTriangle triangle;
    triangle.vertices[0] = A;
    triangle.vertices[1] = B;
    triangle.vertices[2] = C;
    GLKVector3 AB = GLKVector3Make(B.position.x - A.position.x, B.position.y - A.position.y, B.position.z - B.position.z);
    GLKVector3 AC = GLKVector3Make(C.position.x - A.position.x, C.position.y - A.position.y, C.position.z - B.position.z);
    GLKVector3 normal = GLKVector3CrossProduct(AB, AC);
    normal = GLKVector3Normalize(normal);
    triangle.vertices[0].normal = normal;
    triangle.vertices[1].normal = normal;
    triangle.vertices[2].normal = normal;
    return triangle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView *view = (GLKView *)self.view;
    view.context =[[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    effect = [[GLKBaseEffect alloc]init];
    effect.useConstantColor = GL_TRUE;
    effect.constantColor = GLKVector4Make(0, 0, 0, 1);
    
    [self makeTriangles];
    GLuint name;
    glGenBuffers(1, &name);
    glBindBuffer(GL_ARRAY_BUFFER, name);
    glBufferData(GL_ARRAY_BUFFER, sizeof(triangle), triangle, GL_STATIC_DRAW);
    
    glEnable(GL_TEXTURE_2D);
    UIImage *image = [UIImage imageNamed:@"1.jpg"];
    size_t width;
    size_t height;
    NSData *data = AGLKDataWithResizedCGImageBytes(image.CGImage, &width, &height);
    glGenTextures(1, &_texture);
    glActiveTexture(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data.bytes);
    
    glClearColor(0, 0, 0, 1);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL);
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL + offsetof(SceneVertex, normal));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL+offsetof(SceneVertex, color));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL+offsetof(SceneVertex, texCoords));
    glEnable(GL_DEPTH_TEST | GL_CULL_FACE);
    [self loadShaders];
    glUniform1i(_texCoords, 0);
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    static float i = 0.0;
    glUseProgram(_program);
    glUniform4f(_lightPositionP, 1, 0, 1, 1);
    glUniform4f(_lightColor, 0, 0.5, 0.5, 1);
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, 2);
    GLfloat ratio = (GLfloat)view.drawableWidth / view.drawableHeight;
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 3, 3*ratio, 3);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(60), 1, 0, 0);
    i = i + 0.001;
    GLKMatrix4 projection = GLKMatrix4MakeFrustum(-1, 1, -1, 1, 1, 50);
    glUniformMatrix4fv(_modelMatrix, 1, 0, modelViewMatrix.m);
    glUniformMatrix4fv(_viewMatrix, 1, 0, projection.m);
    glDrawArrays(GL_TRIANGLES, 0, sizeof(triangle)/sizeof(SceneVertex));
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord0, "TextureCoords");
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
    
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    char *position = "lightPosition";
    char *lightColor = "lightColor";
    _lightPositionP = glGetUniformLocation(_program, position);
    _lightColor = glGetUniformLocation(_program, lightColor);
    _modelMatrix = glGetUniformLocation(_program, "modelMatrix");
    _viewMatrix = glGetUniformLocation(_program, "projectionMatrix");
    _texCoords = glGetUniformLocation(_program, "tex");
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
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

- (BOOL)validateProgram:(GLuint)prog
{
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
static AGLKPowerOf2 AGLKCalculatePowerOf2ForDimension(
                                                      GLuint dimension)
{
    AGLKPowerOf2  result = AGLK1;
    
    if(dimension > (GLuint)AGLK512)
    {
        result = AGLK1024;
    }
    else if(dimension > (GLuint)AGLK256)
    {
        result = AGLK512;
    }
    else if(dimension > (GLuint)AGLK128)
    {
        result = AGLK256;
    }
    else if(dimension > (GLuint)AGLK64)
    {
        result = AGLK128;
    }
    else if(dimension > (GLuint)AGLK32)
    {
        result = AGLK64;
    }
    else if(dimension > (GLuint)AGLK16)
    {
        result = AGLK32;
    }
    else if(dimension > (GLuint)AGLK8)
    {
        result = AGLK16;
    }
    else if(dimension > (GLuint)AGLK4)
    {
        result = AGLK8;
    }
    else if(dimension > (GLuint)AGLK2)
    {
        result = AGLK4;
    }
    else if(dimension > (GLuint)AGLK1)
    {
        result = AGLK2;
    }
    
    return result;
}
static NSData *AGLKDataWithResizedCGImageBytes(
                                               CGImageRef cgImage,
                                               size_t *widthPtr,
                                               size_t *heightPtr)
{
    NSCParameterAssert(NULL != cgImage);
    NSCParameterAssert(NULL != widthPtr);
    NSCParameterAssert(NULL != heightPtr);
    
    GLuint originalWidth = (GLuint)CGImageGetWidth(cgImage);
    GLuint originalHeight = (GLuint)CGImageGetWidth(cgImage);
    
    NSCAssert(0 < originalWidth, @"Invalid image width");
    NSCAssert(0 < originalHeight, @"Invalid image width");
    
    // Calculate the width and height of the new texture buffer
    // The new texture buffer will have power of 2 dimensions.
    GLuint width = AGLKCalculatePowerOf2ForDimension(
                                                     originalWidth);
    GLuint height = AGLKCalculatePowerOf2ForDimension(
                                                      originalHeight);
    
    // Allocate sufficient storage for RGBA pixel color data with
    // the power of 2 sizes specified
    NSMutableData    *imageData = [NSMutableData dataWithLength:
                                   height * width * 4];  // 4 bytes per RGBA pixel
    
    NSCAssert(nil != imageData,
              @"Unable to allocate image storage");
    
    // Create a Core Graphics context that draws into the
    // allocated bytes
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef cgContext = CGBitmapContextCreate(
                                                   [imageData mutableBytes], width, height, 8,
                                                   4 * width, colorSpace,
                                                   kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    // Flip the Core Graphics Y-axis for future drawing
    CGContextTranslateCTM (cgContext, 0, height);
    CGContextScaleCTM (cgContext, 1.0, -1.0);
    
    // Draw the loaded image into the Core Graphics context 
    // resizing as necessary
    CGContextDrawImage(cgContext, CGRectMake(0, 0, width, height),
                       cgImage);
    
    CGContextRelease(cgContext);
    
    *widthPtr = width;
    *heightPtr = height;
    
    return imageData;
}
