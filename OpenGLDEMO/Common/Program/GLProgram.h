//
//  GLProgram.h
//  OpenGLDEMO
//
//  Created by DPP on 2020/4/24.
//  Copyright © 2020 DPP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLProgram : NSObject

- (GLProgram *)initWithVertexShaderString:(NSString *)vShaderString
                     fragmentShaderString:(NSString *)fShaderString;

- (GLProgram *)initWithVertexShaderFileName:(NSString *)vShaderFileName
                     fragmentShaderFileName:(NSString *)fShaderFileName;

- (BOOL)link;
- (void)use;
- (void)validate;

- (GLuint)attributeIndex:(NSString *)attributeName;
- (GLuint)uniformIndex:(NSString *)uniformName;

@end

NS_ASSUME_NONNULL_END
