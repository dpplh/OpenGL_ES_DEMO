//
//  GLDisplayView.h
//  OpenGLDEMO
//
//  Created by DPP on 2020/4/24.
//  Copyright © 2020 DPP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "GLProgram.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    GLKVector3 positionCoord;
    GLKVector2 textureCoord;
} SenceVertex;

@interface GLDisplayView : UIView

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLProgram *program;

- (void)updateTexture:(GLuint)texture;
- (void)updateVertices:(SenceVertex *)vertices count:(GLint)count;

- (void)drawWithMode:(GLenum)mode first:(GLint)first count:(GLsizei)count;

- (GLuint)texureFromCurrentFrameBuffer:(SenceVertex *)vertices size:(CGSize)size count:(GLint)count;

@end


NS_ASSUME_NONNULL_END
