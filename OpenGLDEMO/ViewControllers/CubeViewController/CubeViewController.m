//
//  CubeViewController.m
//  OpenGLDEMO
//
//  Created by DPP on 2020/5/11.
//  Copyright © 2020 DPP. All rights reserved.
//

#import "CubeViewController.h"
#import "GLDisplayView.h"
#import "UIImage+Categories.h"

const SenceVertex vertexts[] = {
    {{-0.5f, 0.5f, 0.5f},   {0.0f, 0.0f}}, // 前左上 0
    {{-0.5f, -0.5f, 0.5f},  {0.0f, 1.0f}}, // 前左下 1
    {{0.5f, -0.5f, 0.5f},   {1.0f, 1.0f}}, // 前右下 2
    {{0.5f, 0.5f, 0.5f},    {1.0f, 0.0f}}, // 前右上 3
    // 后面
    {{-0.5f, 0.5f, -0.5f},   {0.0f, 0.0f}}, // 后左上 4
    {{-0.5f, -0.5f, -0.5f},  {0.0f, 1.0f}}, // 后左下 5
    {{0.5f, -0.5f, -0.5f},   {1.0f, 1.0f}}, // 后右下 6
    {{0.5f, 0.5f, -0.5f},    {1.0f, 0.0f}}, // 后右上 7
    // 左面
    {{-0.5f, 0.5f, -0.5f},   {0.0f, 0.0f}}, // 后左上 8
    {{-0.5f, -0.5f, -0.5f},  {0.0f, 1.0f}}, // 后左下 9
    {{-0.5f, 0.5f, 0.5f},   {1.0f, 0.0f}}, // 前左上 10
    {{-0.5f, -0.5f, 0.5f},  {1.0f, 1.0f}}, // 前左下 11
    // 右面
    {{0.5f, 0.5f, 0.5f},    {0.0f, 0.0f}}, // 前右上 12
    {{0.5f, -0.5f, 0.5f},   {0.0f, 1.0f}}, // 前右下 13
    {{0.5f, -0.5f, -0.5f},   {1.0f, 1.0f}}, // 后右下 14
    {{0.5f, 0.5f, -0.5f},    {1.0f, 0.0f}}, // 后右上 15
    // 上面
    {{-0.5f, 0.5f, -0.5f},   {0.0f, 0.0f}}, // 后左上 16
    {{-0.5f, 0.5f, 0.5f},   {0.0f, 1.0f}}, // 前左上 17
    {{0.5f, 0.5f, 0.5f},    {1.0f, 1.0f}}, // 前右上 18
    {{0.5f, 0.5f, -0.5f},    {1.0f, 0.0f}}, // 后右上 19
    // 下面
    {{-0.5f, -0.5f, 0.5f},  {0.0f, 0.0f}}, // 前左下 20
    {{0.5f, -0.5f, 0.5f},   {1.0f, 0.0f}}, // 前右下 21
    {{-0.5f, -0.5f, -0.5f},  {0.0f, 1.0f}}, // 后左下 22
    {{0.5f, -0.5f, -0.5f},   {1.0f, 1.0f}}, // 后右下 23
};

const GLbyte indexes[] = {
    // 前面
    0, 1, 2,
    0, 2, 3,
    // 后面
    4, 5, 6,
    4, 6, 7,
    // 左面
    8, 9, 11,
    8, 11, 10,
    // 右面
    12, 13, 14,
    12, 14, 15,
    // 上面
    16, 17, 18,
    16, 18, 19,
    // 下面
    20, 22, 23,
    20, 23, 21
};

@interface CubeViewController ()

@property (nonatomic, strong) GLDisplayView *displayView;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSInteger count;

@end

@implementation CubeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    CGRect frame = {{0, 0}, {CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds)}};
    self.displayView = [[GLDisplayView alloc] initWithFrame:frame vertexShader:@"Cube" fragmentShader:@"Cube"];
    self.displayView.center = self.view.center;
    self.displayView.context = context;
    [self.view addSubview:self.displayView];

    NSString *imageFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"leaves.png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
    [self.displayView updateTexture:[image texture]];
    
    [self.displayView updateVertices:(SenceVertex *)&vertexts count:(sizeof(vertexts) / sizeof(vertexts[0]))];
    [self.displayView updateIndexes:(GLbyte *)&indexes size:sizeof(indexes)];
    
    GLuint model = [self.displayView.program uniformIndex:@"model"];
    GLuint view = [self.displayView.program uniformIndex:@"view"];
    GLuint projection = [self.displayView.program uniformIndex:@"projection"];

    GLKMatrix4 rotationMatrix4 = GLKMatrix4Identity;
//    rotationMatrix4 = GLKMatrix4Rotate(rotationMatrix4, GLKMathDegreesToRadians(30.0), 1.0, 0.0, 0.0);
//    rotationMatrix4 = GLKMatrix4Rotate(rotationMatrix4, GLKMathDegreesToRadians(-45.0), 0.0, 1.0, 0.0);
    
    GLKMatrix4 modelMatrix = rotationMatrix4;
    GLKMatrix4 viewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -3.0);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0), 1.0, 0.1, 10.0);

    glUniformMatrix4fv(model, 1, GL_FALSE, (GLfloat *)&modelMatrix);
    glUniformMatrix4fv(view, 1, GL_FALSE, (GLfloat *)&viewMatrix);
    glUniformMatrix4fv(projection, 1, GL_FALSE, (GLfloat *)&projectionMatrix);
    
//    glEnable(GL_CULL_FACE);
//    glCullFace(GL_FRONT);
    
    [self.displayView drawElementWithMode:GL_TRIANGLES count:(sizeof(indexes) / sizeof(indexes[0]))];
}
@end
