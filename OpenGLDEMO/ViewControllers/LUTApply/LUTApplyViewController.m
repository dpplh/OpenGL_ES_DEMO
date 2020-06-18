//
//  LUTApplyViewController.m
//  OpenGLDEMO
//
//  Created by DPP on 2020/6/3.
//  Copyright © 2020 DPP. All rights reserved.
//

#import "LUTApplyViewController.h"
#import "GLDisplayView.h"
#import "UIImage+Categories.h"

@interface LUTApplyViewController ()

@property (nonatomic, strong) GLDisplayView *displayView;
@property (nonatomic, assign) SenceVertex *vertices;

@end

@implementation LUTApplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupSubviews];
    [self setupVertices];
    [self drawImage];
}

- (void)setupSubviews {
    self.view.backgroundColor = [UIColor whiteColor];
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    CGRect frame = {{0, 0}, {CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds)}};
    self.displayView = [[GLDisplayView alloc] initWithFrame:frame vertexShader:@"LUTApply" fragmentShader:@"LUTApply"];
    self.displayView.center = self.view.center;
    self.displayView.context = context;
    [self.view addSubview:self.displayView];
}

- (void)setupVertices {
    self.vertices = malloc(sizeof(SenceVertex) * 4);
    self.vertices[0] = (SenceVertex){{-1.0,  1.0, 0.0}, {0.0, 1.0}};
    self.vertices[1] = (SenceVertex){{-1.0, -1.0, 0.0}, {0.0, 0.0}};
    self.vertices[2] = (SenceVertex){{ 1.0,  1.0, 0.0}, {1.0, 1.0}};
    self.vertices[3] = (SenceVertex){{ 1.0, -1.0, 0.0}, {1.0, 0.0}};
    
    [self.displayView updateVertices:self.vertices count:4];
}

- (void)drawImage {
    // 图片
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"kobe" ofType:@"jpg"]];
    [self.displayView updateTexture:[image texture:NO]];

    // LUT
    UIImage *image2 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"lookup" ofType:@"png"]];
    GLuint inputTexture2 = [self.displayView.program uniformIndex:@"InputImageTexture2"];

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, [image2 texture:NO]);
    glUniform1i(inputTexture2, 1);
    
    [self.displayView drawWithMode:GL_TRIANGLE_STRIP first:0 count:4];
}

@end
