//
//  GLDisplayView.m
//  OpenGLDEMO
//
//  Created by DPP on 2020/4/24.
//  Copyright © 2020 DPP. All rights reserved.
//

#import "GLDisplayView.h"
#import "UIImage+Categories.h"

@interface GLDisplayView () {
    GLuint _frameBuffer;
    GLuint _renderBuffer;
    GLuint _depthRenderBuffer;
    GLuint _texture;
    
    GLuint _positionAttribute;
    GLuint _textureCoordinateAttribute;
    GLuint _normalAttribute;
    GLuint _textureUniform;
}

@property (nonatomic, copy) NSString *vertexShader;
@property (nonatomic, copy) NSString *fragmentShader;

@end

@implementation GLDisplayView

#pragma mark - Public Method

- (void)drawWithMode:(GLenum)mode first:(GLint)first count:(GLsizei)count {
    [self useAsCurrentContext];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    // 开启深度测试
    glEnable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glViewport(0, 0, [self drawableWidth], [self drawableHeight]);
    
    glDrawArrays(mode, first, count);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)drawElementWithMode:(GLenum)mode count:(GLsizei)count {
    [self useAsCurrentContext];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    // 开启深度测试
    glEnable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glViewport(0, 0, [self drawableWidth], [self drawableHeight]);
    
    glDrawElements(mode, count, GL_UNSIGNED_BYTE, 0);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)updateTexture:(GLuint)texture {
    _texture = texture;
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(_textureUniform, 0);
}

- (void)updateVertices:(SenceVertex *)vertices count:(GLint)count {
    GLuint vertex;
    glGenBuffers(1, &vertex);
    glBindBuffer(GL_ARRAY_BUFFER, vertex);
    glBufferData(GL_ARRAY_BUFFER, sizeof(SenceVertex) * count, vertices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(_positionAttribute, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    glVertexAttribPointer(_textureCoordinateAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
}

- (void)updateVerticesNormal:(VertexNormal *)vertices count:(GLint)count {
    GLuint vertex;
    glGenBuffers(1, &vertex);
    glBindBuffer(GL_ARRAY_BUFFER, vertex);
    glBufferData(GL_ARRAY_BUFFER, sizeof(VertexNormal) * count, vertices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(_positionAttribute, 3, GL_FLOAT, GL_FALSE, sizeof(VertexNormal), NULL + offsetof(VertexNormal, positionCoord));
    glVertexAttribPointer(_normalAttribute, 3, GL_FLOAT, GL_FALSE, sizeof(VertexNormal), NULL + offsetof(VertexNormal, normalCoord));
}


- (void)updateIndexes:(GLbyte *)indexes size:(GLsizei)size {
    GLuint bufferIndex;
    glGenBuffers(1, &bufferIndex);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, bufferIndex);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, size, indexes, GL_STATIC_DRAW);
}

- (GLuint)texureFromCurrentFrameBuffer:(SenceVertex *)vertices size:(CGSize)size count:(GLint)count {
    [self useAsCurrentContext];
    
    GLsizei width = size.width;
    GLsizei height = size.height;
    
    GLuint frameBuffer;
    GLuint texture;
    
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);
    GLuint status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"failure with create display frame buffer");
    
    glViewport(0, 0, width, height);
    
    [self updateVertices:vertices count:count];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glUniform1i(_textureUniform, 0);
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, count);
    
    return texture;
}

#pragma mark - Override Method

- (void)layoutSubviews {
    [super  layoutSubviews];
}

#pragma mark - Initialize

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame vertexShader:nil fragmentShader:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                 vertexShader:(NSString *)vertexShader
               fragmentShader:(NSString *)fragmentShader {
    self = [super initWithFrame:frame];
    if (self) {
        self.vertexShader = vertexShader;
        self.fragmentShader = fragmentShader;
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    [self setupLayer];
}

#pragma mark - Private

- (void)useAsCurrentContext {
    [EAGLContext setCurrentContext:self.context];
}

- (void)setupProgram {
    [self useAsCurrentContext];
    
    NSString *vertexShaderName = self.vertexShader ?: @"glsl";
    NSString *fragmentShaderName = self.fragmentShader ?: @"glsl";
    
    self.program = [[GLProgram alloc] initWithVertexShaderFileName:vertexShaderName fragmentShaderFileName:fragmentShaderName];
    if (![self.program link]) {
        NSLog(@"程序连接错误");
    }
    [self.program use];
    [self.program validate];
    
    _positionAttribute = [self.program attributeIndex:@"Position"];
    _textureCoordinateAttribute = [self.program attributeIndex:@"InputTextureCoordinate"];
    _textureUniform = [self.program uniformIndex:@"InputImageTexture"];
    _normalAttribute = [self.program attributeIndex:@"Normal"];
    
    glEnableVertexAttribArray(_positionAttribute);
    glEnableVertexAttribArray(_textureCoordinateAttribute);
    glEnableVertexAttribArray(_normalAttribute);
}

- (void)setupLayer {
    CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
    layer.opaque = YES;
    layer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: [NSNumber numberWithBool:NO],
                                 kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
}


- (void)createDisplayFrameBuffer {
    [self useAsCurrentContext];

    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CALayer<EAGLDrawable> *)self.layer];
    // 取renderBuffer 宽高必须在-renderbufferStorage 之后
    // 否则为0
    GLint width = [self drawableWidth];
    GLint height = [self drawableHeight];
    if (width == 0 || height == 0) {
        [self destoryDisplayFrameBuffer];
        return;
    }
    
    // 申请深度缓存
    glGenRenderbuffers(1, &_depthRenderBuffer);
    // 绑定到渲染缓存
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    // 设置深度测试的存储信息
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    // 将渲染缓存挂载到 GL_COLOR_ATTACHMENT0
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    
    // 将深度渲染缓存挂载到 GL_DEPTH_ATTACHMENT
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
    
    GLuint status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"failure with create display frame buffer");
    
    // 当前 GL_RENDERBUFFER绑定的是深度测试渲染缓存，所以要绑定回色彩渲染缓存，否则无法显示
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
}

- (void)destoryDisplayFrameBuffer {
    if (_frameBuffer != 0) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    
    if (_renderBuffer != 0) {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
    
    if (_depthRenderBuffer != 0) {
        glDeleteRenderbuffers(1, &_depthRenderBuffer);
        _depthRenderBuffer = 0;
    }
}

#pragma mark - Accessor

- (void)setContext:(EAGLContext *)context {
    if (_context != context) {
        _context = context;
        [self destoryDisplayFrameBuffer];
        [self createDisplayFrameBuffer];
    
        [self setupProgram];
    }
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
