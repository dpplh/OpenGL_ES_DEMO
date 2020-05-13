//
//  CoordSystemViewController.m
//  OpenGLDEMO
//
//  Created by DPP on 2020/5/9.
//  Copyright © 2020 DPP. All rights reserved.
//

#import "CoordSystemViewController.h"
#import "GLDisplayView.h"
#import "UIImage+Categories.h"

@interface CoordSystemViewController () {
    GLuint _projection;
}

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) GLDisplayView *displayView;

@property (nonatomic, assign) SenceVertex *vertices;

@end

@implementation CoordSystemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSlider];
    
    self.view.backgroundColor = [UIColor whiteColor];
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    CGRect frame = {{0, 0}, {CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds)}};
    self.displayView = [[GLDisplayView alloc] initWithFrame:frame
                                               vertexShader:@"CoordSystem"
                                             fragmentShader:@"CoordSystem"];
    self.displayView.center = self.view.center;
    self.displayView.context = context;
    [self.view addSubview:self.displayView];
    
    self.vertices = malloc(sizeof(SenceVertex) * 4);
    self.vertices[0] = (SenceVertex){{-0.5, 0.5, 0}, {0, 1}};
    self.vertices[1] = (SenceVertex){{ 0.5, 0.5, 0}, {1, 1}};
    self.vertices[2] = (SenceVertex){{-0.5,-0.5, 0}, {0, 0}};
    self.vertices[3] = (SenceVertex){{ 0.5,-0.5, 0}, {1, 0}};
    
    NSString *imageFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"leaves.png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
    [self.displayView updateTexture:[image texture]];
    
    [self.displayView updateVertices:self.vertices count:4];
    
    // 模型矩阵 * 观察矩阵 * 正射投影矩阵 * 透视投影矩阵
    GLuint model = [self.displayView.program uniformIndex:@"model"];
    GLuint view = [self.displayView.program uniformIndex:@"view"];
    _projection = [self.displayView.program uniformIndex:@"projection"];

    GLKMatrix4 modelMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-45.0), 1.0, 0.0, 0.0);
    GLKMatrix4 viewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -3.0);
    GLKMatrix4 ortho = GLKMatrix4MakeOrtho(-1.0, 1.0, -1.0, 1.0, 0.1, 100.0);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), 1.0, 0.1, 10.0);
//    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
//    GLKMatrix4 viewMatrix = GLKMatrix4Identity;
//    GLKMatrix4 projectionMatrix = GLKMatrix4Identity;
    
    glUniformMatrix4fv(model, 1, GL_FALSE, (GLfloat *)&modelMatrix);
    glUniformMatrix4fv(view, 1, GL_FALSE, (GLfloat *)&viewMatrix);
    glUniformMatrix4fv(_projection, 1, GL_FALSE, (GLfloat *)&projectionMatrix);
    
    [self.displayView drawWithMode:GL_TRIANGLE_STRIP first:0 count:4];
}

- (void)setupSlider {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    self.slider = [[UISlider alloc] init];
    self.slider.frame = CGRectMake(0, 0, width - 40, 30);
    self.slider.value = 0.5;
    self.slider.maximumValue = 1.0;
    self.slider.minimumValue = 0.0;
    [self.slider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    
    self.slider.center = CGPointMake(width / 2.0, height - 100.0);
    
    [self.view addSubview:self.slider];
}

- (void)sliderValueDidChange:(UISlider *)slider {
    CGFloat angle = 180 * slider.value;
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(angle), 1.0, 0.1, 10.0);
    glUniformMatrix4fv(_projection, 1, GL_FALSE, (GLfloat *)&projectionMatrix);
    [self.displayView drawWithMode:GL_TRIANGLE_STRIP first:0 count:4];
}

@end
