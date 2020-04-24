//
//  ImageGLSLViewController.m
//  OpenGLDEMO
//
//  Created by DPP on 2020/4/18.
//  Copyright © 2020 DPP. All rights reserved.
//

#import "ImageGLSLViewController.h"
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 positionCoord;   // 顶点坐标(x, y, z)
    GLKVector2 textureCoord;    // 纹理坐标(U, V)
} SenceVertex;

@interface ImageGLSLViewController () {
    GLuint _frameBuffer;
    GLuint _renderBuffer;
    GLuint _vertextBuffer;
}

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) SenceVertex *vertices;

@end

@implementation ImageGLSLViewController

- (void)dealloc {
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
        self.context = nil;
    }
    
    if (_renderBuffer != 0) {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
    
    if (_frameBuffer != 0) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    
    if (_vertextBuffer != 0) {
        glDeleteBuffers(1, &_vertextBuffer);
        _vertextBuffer = 0;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self commonInit];
}

- (void)commonInit {
    // 初始化顶点数据
    self.vertices = malloc(sizeof(SenceVertex) * 4);
    self.vertices[0] = (SenceVertex){{-0.5, -0.5, 0.0}, {0.0, 0.0}};  // 左下角
    self.vertices[1] = (SenceVertex){{ 0.5, -0.5, 0.0}, {1.0, 0.0}};  // 右下角
    self.vertices[2] = (SenceVertex){{-0.5,  0.5, 0.0}, {0.0, 1.0}};  // 左上角
    self.vertices[3] = (SenceVertex){{ 0.5,  0.5, 0.0}, {1.0, 1.0}};  // 右上角
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.context];
    
    CAEAGLLayer *layer = [[CAEAGLLayer alloc] init];
    layer.frame = self.view.bounds;
    layer.contentsScale = [[UIScreen mainScreen] scale];
    layer.drawableProperties = @{
        kEAGLDrawablePropertyRetainedBacking: [NSNumber numberWithBool:NO],
        kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
    [self.view.layer addSublayer:layer];
    
    // 创建、链接着色器程序
    GLuint program = [self programWithShaderName:@"glsl"];
    glUseProgram(program);
    
    // 获取参数
    GLint positionAttribute = glGetAttribLocation(program, "Position");
    GLint textureCoordinateAttribute = glGetAttribLocation(program, "InputTextureCoordinate");
    GLint textureUniform = glGetUniformLocation(program, "InputImageTexture");
    
    // 创建frameBuffer、renderBuffer
    [self setupFrameBuffer];
    [self setupRenderBuffer];
     
    if (![self bindAndCheckRenderStatus:layer]) {
        NSAssert(NO, @"render buferr 绑定失败");
    }
    
    // 设置视窗宽高
    glViewport(0, 0, [self drawableWidth], [self drawableHeight]);
    glClearColor(0.0, 0.0, 0.0, 1.0);
    
    // 加载图片
    NSString *imageFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"leaves.png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
    GLuint texure = [self textureForImage:image];
    
    // 将纹理ID传给着色器程序
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texure);
    glUniform1i(textureUniform, 0);
    
    // 顶点buffer
    glGenBuffers(1, &_vertextBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertextBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(SenceVertex) * 4, self.vertices, GL_STATIC_DRAW);
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 顶点
    glEnableVertexAttribArray(positionAttribute);
    glVertexAttribPointer(positionAttribute, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    // 纹理
    glEnableVertexAttribArray(textureCoordinateAttribute);
    glVertexAttribPointer(textureCoordinateAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    
    [self.context presentRenderbuffer:_renderBuffer];
}

- (GLuint)textureForImage:(UIImage *)image {
    CGImageRef imageRef = image.CGImage;
    GLint width = (GLint)CGImageGetWidth(imageRef);
    GLint height = (GLint)CGImageGetHeight(imageRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc(width * height * 4);
    CGContextRef contextRef = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpaceRef, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGColorSpaceRelease(colorSpaceRef);
    //  因为Core Graphics是以原点在左上角同时Y轴向下增大的形式来实现iOS图片保存的
    //  OpenGL ES的纹理坐标 原点在左下角，同时Y轴向下增大
    CGContextTranslateCTM(contextRef, 0, height);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    CGContextDrawImage(contextRef, rect, imageRef);
    
    GLuint textureID;
    glGenBuffers(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    // level: 指定MIP贴图的初始细节级别
    // internalFormat: 指定纹理缓存内每个纹素需要保存的信息数量，对于iOS设备来说，纹素信息要么是GL_RGB，要么是GL_RGBA
    // format: 指定初始化缓存所使用的图像数据的每个像素所要保存的信息，这个参数总是internalFormat参数相同
    /* type: 指定缓存中的纹素所使用的编码类型,
     * GL_UNSIGNED_BYTE、GL_UNSIGNED_SHORT_5_6_5、GL_UNSIGNED_SHORT_4_4_4_4、GL_UNSIGNED_SHORT_5_5_5_1
     * 使用GL_UNSIGNED_BYTE会提供最佳色彩
    */
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    /* GL_TEXTURE_MIN_FILTER: 在多个纹素对应一个片元的星矿下，使用怎么样的形式取样颜色
     * GL_LINEAR: 混色纹素颜色，例如：黑白交替，取样的混合纹素为灰色
     * GL_NEAREST: 取样其中一个，因此最终片元颜色可能为白色或者黑色
    */
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    /*
     * 当U、V坐标小于0、或者大于1时，有两种选择
     * 1. GL_CLAMP_TO_EDGE: 取纹理边缘的纹素
     * 2. GL_REPEAT: 循环
     */
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    CGContextRelease(contextRef);
    free(imageData);
    
    return textureID;
}

- (GLint)programWithShaderName:(NSString *)shaderName {
    // 编译顶点着色器
    GLint vertextShader = [self compileWithType:GL_VERTEX_SHADER shaderName:shaderName];
    // 编译片元着色器
    GLint fragmentShader = [self compileWithType:GL_FRAGMENT_SHADER shaderName:shaderName];
    
    // 创建程序
    GLint program = glCreateProgram();
    // 链接两个着色器
    glAttachShader(program, vertextShader);
    glAttachShader(program, fragmentShader);
    
    // 链接程序
    glLinkProgram(program);
    
    GLint linkRes;
    glGetProgramiv(program, GL_LINK_STATUS, &linkRes);
    if (linkRes == GL_FALSE) {
        GLchar message[256];
        glGetProgramInfoLog(program, sizeof(message), 0, &message[0]);
        NSAssert(NO, @"程序编译错误");
    }
    
    return program;
}

- (GLint)compileWithType:(GLenum)type shaderName:(NSString *)shaderName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:shaderName
                                                         ofType:(type == GL_VERTEX_SHADER ? @"vsh" : @"fsh")];
    
    NSError *error = nil;
    NSString *shaderString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSAssert(NO, @"文件读取失败");
    }
    
    GLuint shader = glCreateShader(type);
    
    const char *shaderStringUTF8 = [shaderString UTF8String];
    GLint shaderStringLength = (GLint)[shaderString length];
    glShaderSource(shader, 1, &shaderStringUTF8, &shaderStringLength);
    
    glCompileShader(shader);
    
    GLint compileRes;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileRes);
    if (compileRes == GL_FALSE) {
        GLchar message[256];
        glGetShaderInfoLog(shader, sizeof(message), 0, &message[0]);
        NSAssert(NO, @"着色器编译错误");
    }
    
    return shader;
}

- (void)setupFrameBuffer {
    if (_frameBuffer != 0) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
}

- (void)setupRenderBuffer {
    if (_renderBuffer != 0) {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
    
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
}

- (BOOL)bindAndCheckRenderStatus:(CALayer<EAGLDrawable> *)layer {
     // 绑定RenderBuffer
     glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
     [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
     GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
     
     if (status != GL_FRAMEBUFFER_COMPLETE) {
         return NO;
     }
    
    return YES;
}


- (GLint)drawableWidth {
    GLint width;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    
    return width;
}

- (GLint)drawableHeight {
    GLint height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    return height;
}

@end
    
