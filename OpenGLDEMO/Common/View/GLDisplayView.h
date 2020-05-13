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

typedef struct {
    GLKVector3 positionCoord;
    GLKVector3 normalCoord;
} VertexNormal;

@interface GLDisplayView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                 vertexShader:(NSString *)vertexShader
               fragmentShader:(NSString *)fragmentShader;

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLProgram *program;

- (void)updateTexture:(GLuint)texture;
- (void)updateVertices:(SenceVertex *)vertices count:(GLint)count;
- (void)updateVerticesNormal:(VertexNormal *)vertices count:(GLint)count;
- (void)updateIndexes:(GLbyte *)indexes size:(GLsizei)size;

- (void)drawWithMode:(GLenum)mode first:(GLint)first count:(GLsizei)count;
- (void)drawElementWithMode:(GLenum)mode count:(GLsizei)count;

- (GLuint)texureFromCurrentFrameBuffer:(SenceVertex *)vertices size:(CGSize)size count:(GLint)count;

@end


NS_ASSUME_NONNULL_END
