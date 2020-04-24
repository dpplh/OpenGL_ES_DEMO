//
//  TriangleViewController.m
//  OpenGLDEMO
//
//  Created by DPP on 2020/4/17.
//  Copyright © 2020 DPP. All rights reserved.
//

#import "TriangleViewController.h"
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 positionCoord;
} SenceVertex;

@interface TriangleViewController () {
    GLuint _frameBuffer;
    GLuint _renderBuffer;
    GLuint _vertextBuffer;
}

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) SenceVertex *vertices;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;

@end

@implementation TriangleViewController

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
    self.vertices = malloc(sizeof(SenceVertex) * 3);
    self.vertices[0] = (SenceVertex){{-0.5, -0.5, 0}};
    self.vertices[1] = (SenceVertex){{ 0.5, -0.5, 0}};
    self.vertices[2] = (SenceVertex){{-0.5,  0.5, 0}};
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.context];
    
    CAEAGLLayer *layer = [[CAEAGLLayer alloc] init];
    layer.frame = self.view.bounds;
    layer.contentsScale = [[UIScreen mainScreen] scale];
    layer.drawableProperties = @{
        kEAGLDrawablePropertyRetainedBacking: [NSNumber numberWithBool:NO],
        kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
    [self.view.layer addSublayer:layer];
    
    // 创建frameBuffer、renderBuffer
    [self setupFrameBuffer];
    [self setupRenderBuffer];
        
    // 绑定RenderBuffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"===");
    }
    
    
    // 设置视窗宽高
    glViewport(0, 0, [self drawableWidth], [self drawableHeight]);
    glClearColor(0.0, 0.0, 0.0, 1.0);
    
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    // RGBA
    self.baseEffect.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    
    // 顶点buffer
    glGenBuffers(1, &_vertextBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertextBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(SenceVertex) * 3, self.vertices, GL_STATIC_DRAW);
    
    
    [self.baseEffect prepareToDraw];
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    [self.context presentRenderbuffer:_renderBuffer];
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
