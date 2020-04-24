//
//  GLKViewImageViewController.m
//  OpenGLDEMO
//
//  Created by DPP on 2020/4/22.
//  Copyright © 2020 DPP. All rights reserved.
//

#import "GLKViewImageViewController.h"
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 positionCoord;   // 顶点坐标(x, y, z)
    GLKVector2 textureCoord;    // 纹理坐标(U, V)
} SenceVertex;

const SenceVertex vertices[] = {
    {{-0.5, -0.5, 0.0}, {0.0, 0.0}},  // 左下角
    {{ 0.5, -0.5, 0.0}, {1.0, 0.0}},  // 右下角
    {{-0.5,  0.5, 0.0}, {0.0, 1.0}},  // 左上角
    {{ 0.5,  0.5, 0.0}, {1.0, 1.0}}   // 右上角
};

@interface GLKViewImageViewController () <GLKViewDelegate> {
    GLuint _vertextBuffer;
}

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) GLKView *glkView;

@end

@implementation GLKViewImageViewController

- (void)dealloc {
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
        self.context = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self commonInit];
}

- (void)commonInit {
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.context];
    
    self.glkView = [[GLKView alloc] initWithFrame:self.view.bounds context:self.context];
    self.glkView.delegate = self;
    [self.view addSubview:self.glkView];
    
    // 加载图片
    NSString *imageFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"leaves.png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
    
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:nil error:NULL];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    // RGBA
    self.baseEffect.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
    
    
    // 顶点buffer
    glGenBuffers(1, &_vertextBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertextBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(SenceVertex) * 4, vertices, GL_STATIC_DRAW);
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.baseEffect prepareToDraw];
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 顶点
    glEnableVertexAttribArray(GLKVertexAttribPosition); // 启用顶点缓存数据
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));    // 设置顶点数据指针
    // 纹理
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);    // 启用纹理缓存数据
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));    // 设置纹理数据指针
    // 绘制
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
    
