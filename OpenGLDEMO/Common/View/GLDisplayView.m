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
    GLuint _texture;
    
    GLuint _positionAttribute;
    GLuint _textureCoordinateAttribute;
    GLuint _textureUniform;
}

@end

@implementation GLDisplayView

#pragma mark - Public Method

- (void)drawWithMode:(GLenum)mode first:(GLint)first count:(GLsizei)count {
    [self useAsCurrentContext];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glClearColor(1.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, [self drawableWidth], [self drawableHeight]);
    
    glDrawArrays(mode, first, count);
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
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
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
    
    self.program = [[GLProgram alloc] initWithVertexShaderFileName:@"glsl" fragmentShaderFileName:@"glsl"];
    if (![self.program link]) {
        NSLog(@"程序连接错误");
    }
    [self.program use];
    [self.program validate];
    
    _positionAttribute = [self.program attributeIndex:@"Position"];
    _textureCoordinateAttribute = [self.program attributeIndex:@"InputTextureCoordinate"];
    _textureUniform = [self.program uniformIndex:@"InputImageTexture"];
    
    glEnableVertexAttribArray(_positionAttribute);
    glEnableVertexAttribArray(_textureCoordinateAttribute);
}

- (void)setupLayer {
    CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
    layer.opaque = YES;
    layer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: [NSNumber numberWithBool:NO],
                                 kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
}


- (void)createDisplayFrameBuffer {
    [self useAsCurrentContext];
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);

    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);

    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CALayer<EAGLDrawable> *)self.layer];

    if ([self drawableWidth] == 0 || [self drawableHeight] == 0) {
        [self destoryDisplayFrameBuffer];
        return;
    }

    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    
    GLuint status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"failure with create display frame buffer");
}

- (void)destoryDisplayFrameBuffer {
    if (_frameBuffer != 0) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    
    if (_renderBuffer != 0) {
        glDeleteRenderbuffers(1, &_renderBuffer);
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
