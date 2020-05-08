//
//  BodyViewController.m
//  OpenGLDEMO
//
//  Created by DPP on 2020/5/7.
//  Copyright © 2020 DPP. All rights reserved.
//

#import "BodyViewController.h"
#import "GLDisplayView.h"
#import "UIImage+Categories.h"
#import "Utils.h"

@interface BodyViewController ()

@property (nonatomic, weak) IBOutlet UISlider *slider;
@property (nonatomic, weak) IBOutlet GLDisplayView *displayView;
@property (nonatomic, weak) IBOutlet UIView *topCursor;
@property (nonatomic, weak) IBOutlet UIView *bottomCursor;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topCursorConstantY;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomCursorConstantY;

@property (nonatomic, assign) CGFloat startY;
@property (nonatomic, assign) CGFloat endY;
@property (nonatomic, assign) CGFloat newHeight;

@property (nonatomic, assign) CGSize currentImageSize;
@property (nonatomic, assign) CGFloat currentTextureWidth;

@property (nonatomic, assign) SenceVertex *vertices;

@property (nonatomic, assign) BOOL updateTexture;

@end

@implementation BodyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.vertices = malloc(sizeof(SenceVertex) * 8);
    
    [self setupDisplayView];
    [self setupGesture];
    
    self.startY = 0.4;
    self.endY = 0.6;
    self.newHeight = self.endY - self.startY;
//    self.updateTexture = YES;
    [self caculateVerticesWithTextureSize:self.currentImageSize startY:self.startY endY:self.endY newHeight:self.newHeight];
}

- (void)setupDisplayView {
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.displayView.context = context;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"body2" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    [self.displayView updateTexture:[image texture]];
    
    self.currentImageSize = image.size;
    CGFloat defaultTextureHeight = 0.7;
    self.currentTextureWidth = self.currentImageSize.width / self.currentImageSize.height * defaultTextureHeight;
}

- (void)caculateVerticesWithTextureSize:(CGSize)textureSize
                                 startY:(CGFloat)startY
                                   endY:(CGFloat)endY
                              newHeight:(CGFloat)newHeight {
    CGFloat ratio = (textureSize.height / textureSize.width);
    
    CGFloat textureWidth = self.currentTextureWidth;
    CGFloat textureHeight = textureWidth * ratio;
    
    CGFloat delta = (newHeight - (endY - startY)) * textureHeight;
    
    // 左上角
    self.vertices[0] = (SenceVertex){{-textureWidth, textureHeight + delta, 0}, {0, 1}};
    // 右上角
    self.vertices[1] = (SenceVertex){{ textureWidth, textureHeight + delta, 0}, {1, 1}};
    // 左下角
    self.vertices[6] = (SenceVertex){{-textureWidth,-textureHeight - delta, 0}, {0, 0}};
    // 右下角
    self.vertices[7] = (SenceVertex){{ textureWidth,-textureHeight - delta, 0}, {1, 0}};
    
    // 拉伸区域
    // 左上角
    CGFloat startYPosition = (textureHeight - 2 * startY * textureHeight);
    CGFloat endYPosition = textureHeight - 2 * endY * textureHeight;
    
    self.vertices[2] = (SenceVertex){{-textureWidth, startYPosition + delta, 0}, {0, 1 - startY}};
    // 右上角
    self.vertices[3] = (SenceVertex){{ textureWidth, startYPosition + delta, 0}, {1, 1 - startY}};
    // 左下角
    self.vertices[4] = (SenceVertex){{-textureWidth, endYPosition - delta, 0}, {0, 1 - endY}};
    // 右下角
    self.vertices[5] = (SenceVertex){{ textureWidth, endYPosition - delta, 0}, {1, 1 - endY}};
    
    [self.displayView updateVertices:self.vertices count:8];
    [self.displayView drawWithMode:GL_TRIANGLE_STRIP first:0 count:8];
    
    [self updateCursor];
}

- (void)updateCursor {
    CGFloat topCursorY = [self stretchAreaTopY] * CGRectGetHeight(self.displayView.frame);
    CGFloat bottomCursorY = [self stretchAreaBottomY] * CGRectGetHeight(self.displayView.frame);
    
    self.topCursorConstantY.constant = topCursorY;
    self.bottomCursorConstantY.constant = bottomCursorY;
}

- (void)setupGesture {
    UIPanGestureRecognizer *topPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(topPanGesture:)];
    UIPanGestureRecognizer *bottomPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(bottomPanGesture:)];
    
    [self.topCursor addGestureRecognizer:topPanGesture];
    [self.bottomCursor addGestureRecognizer:bottomPanGesture];
}

- (void)topPanGesture:(UIPanGestureRecognizer *)gesture {
    if (self.updateTexture) {
        self.updateTexture = NO;
        [self updateCurrentTexture];
    }
    
    CGFloat translationY = [gesture translationInView:self.topCursor].y;
    
    self.topCursorConstantY.constant += translationY;
    self.startY = [self percentWithConstant:self.topCursorConstantY.constant];
    [gesture setTranslation:CGPointZero inView:self.topCursor];
}

- (void)bottomPanGesture:(UIPanGestureRecognizer *)gesture {
    if (self.updateTexture) {
        self.updateTexture = NO;
        [self updateCurrentTexture];
    }
    
    CGFloat translationY = [gesture translationInView:self.bottomCursor].y;
    
    self.bottomCursorConstantY.constant += translationY;
    self.endY = [self percentWithConstant:self.bottomCursorConstantY.constant];
    [gesture setTranslation:CGPointZero inView:self.bottomCursor];
}

- (void)updateCurrentTexture {
    self.slider.value = 0.5;
    
    CGFloat scale = (self.newHeight - (self.endY - self.startY)) + 1;
    
    CGFloat textureWidth = self.currentImageSize.width;
    CGFloat textureHeight = scale * self.currentImageSize.height;
    
    CGFloat newTopY = self.startY / scale;
    CGFloat newBottomY = (self.startY + self.newHeight) / scale;
    
    SenceVertex *tmpVertices = malloc(sizeof(SenceVertex) * 8);
    tmpVertices[0] = (SenceVertex){{-1, 1, 0}, {0, 1}};
    tmpVertices[1] = (SenceVertex){{1, 1, 0}, {1, 1}};
    tmpVertices[2] = (SenceVertex){{-1, -2 * newTopY + 1, 0}, {0, 1 - self.startY}};
    tmpVertices[3] = (SenceVertex){{1, -2 * newTopY + 1, 0}, {1, 1 - self.startY}};
    tmpVertices[4] = (SenceVertex){{-1, -2 * newBottomY + 1, 0}, {0, 1 - self.endY}};
    tmpVertices[5] = (SenceVertex){{1, -2 * newBottomY + 1, 0}, {1, 1 - self.endY}};
    tmpVertices[6] = (SenceVertex){{-1, -1, 0}, {0, 0}};
    tmpVertices[7] = (SenceVertex){{1, -1, 0}, {1, 0}};
    
    GLuint texture = [self.displayView texureFromCurrentFrameBuffer:tmpVertices size:CGSizeMake(textureWidth, textureHeight) count:8];
    
    self.currentImageSize = CGSizeMake(textureWidth, textureHeight);
    self.startY = newTopY;
    self.endY = newBottomY;
    self.newHeight = self.endY - self.startY;
    [self.displayView updateTexture:texture];
    [self caculateVerticesWithTextureSize:self.currentImageSize startY:self.startY endY:self.endY newHeight:self.newHeight];
}

- (IBAction)sliderValueDidChnage:(UISlider *)sender {
    
    self.updateTexture = YES;
    self.newHeight = (self.endY - self.startY) * (sender.value + 0.5);
    
    [self caculateVerticesWithTextureSize:self.currentImageSize startY:self.startY endY:self.endY newHeight:self.newHeight];
}

- (CGFloat)percentWithConstant:(CGFloat)constant {
    CGFloat percent = (constant / CGRectGetHeight(self.displayView.frame) - [self textureTopY]) / [self textureHeight];
    
    return percent;
}

#pragma mark - Texture

- (CGFloat)stretchAreaTopY {
    return (1 - self.vertices[2].positionCoord.y) / 2.0;
}

- (CGFloat)stretchAreaBottomY {
    return (1 - self.vertices[4].positionCoord.y) / 2.0;
}

- (CGFloat)textureTopY {
    return (1 - self.vertices[0].positionCoord.y) / 2.0;
}

- (CGFloat)textureBottomY {
    return (1 - self.vertices[6].positionCoord.y) / 2.0;
}

- (CGFloat)textureHeight {
    return ([self textureBottomY] - [self textureTopY]);
}


@end
