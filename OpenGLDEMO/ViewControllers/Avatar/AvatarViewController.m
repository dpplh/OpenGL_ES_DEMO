//
//  AvatarViewController.m
//  OpenGLDEMO
//
//  Created by DPP on 2020/6/5.
//  Copyright © 2020 DPP. All rights reserved.
//

#import "AvatarViewController.h"
#import "GLDisplayView.h"
#import "UIImage+Categories.h"

@interface AvatarViewController ()

@property (nonatomic, strong) GLDisplayView *displayView;
@property (nonatomic, assign) SenceVertex *vertices;

@end

@implementation AvatarViewController

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
    self.displayView = [[GLDisplayView alloc] initWithFrame:frame vertexShader:@"avatar" fragmentShader:@"avatar"];
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
    UIImage *backgroundImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"background" ofType:@"jpg"]];
    [self.displayView updateTexture:[backgroundImage texture]];
    
    [self.displayView drawWithMode:GL_TRIANGLE_STRIP first:0 count:4];
    
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"avatar" ofType:@"jpg"]];
    [self.displayView updateTexture:[image texture]];
//
    [self.displayView drawWithMode:GL_TRIANGLE_STRIP first:0 count:4];
    
}

@end
