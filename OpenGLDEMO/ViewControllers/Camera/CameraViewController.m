//
//  CameraViewController.m
//  OpenGLDEMO
//
//  Created by DPP on 2020/5/9.
//  Copyright © 2020 DPP. All rights reserved.
//

#import "CameraViewController.h"
#import "GLDisplayView.h"
#import "UIImage+Categories.h"

@interface CameraViewController () {
    GLuint _viewMat4;
}

@property (nonatomic, strong) GLDisplayView *displayView;

@property (nonatomic, assign) SenceVertex *vertices;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSInteger count;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTimer];
    
    self.view.backgroundColor = [UIColor whiteColor];
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    CGRect frame = {{0, 0}, {CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds)}};
    self.displayView = [[GLDisplayView alloc] initWithFrame:frame
                                               vertexShader:@"Camera"
                                             fragmentShader:@"Camera"];
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
    
    GLuint model = [self.displayView.program uniformIndex:@"model"];
    _viewMat4 = [self.displayView.program uniformIndex:@"view"];
    GLuint projection = [self.displayView.program uniformIndex:@"projection"];

    GLKMatrix4 modelMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-45.0), 1.0, 0.0, 0.0);
//    GLKMatrix4 viewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -3.0);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0), 1.0, 0.1, 10.0);

    glUniformMatrix4fv(model, 1, GL_FALSE, (GLfloat *)&modelMatrix);
//    glUniformMatrix4fv(view, 1, GL_FALSE, (GLfloat *)&viewMatrix);
    glUniformMatrix4fv(projection, 1, GL_FALSE, (GLfloat *)&projectionMatrix);
}

- (void)setupTimer {
    self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)tick:(NSTimer *)timer {
    self.count++;
    
    float radius = 10.0;
    float cameraX = sin(self.count) * radius;
    float cameraZ = cos(self.count) * radius;
    
    GLKMatrix4 viewMat4 = GLKMatrix4MakeLookAt(cameraX, 0, cameraZ, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
    
    glUniformMatrix4fv(_viewMat4, 1, GL_FALSE, (GLfloat*)&viewMat4);
    
    [self.displayView drawWithMode:GL_TRIANGLE_STRIP first:0 count:4];
}

@end
