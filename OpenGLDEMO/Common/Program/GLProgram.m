//
//  GLProgram.m
//  OpenGLDEMO
//
//  Created by DPP on 2020/4/24.
//  Copyright © 2020 DPP. All rights reserved.
//

#import "GLProgram.h"

@interface GLProgram () {
    GLuint _vShader;
    GLuint _fShader;
    GLuint _program;
}

@end

@implementation GLProgram

- (GLProgram *)initWithVertexShaderFileName:(NSString *)vShaderFileName
                     fragmentShaderFileName:(NSString *)fShaderFileName {
    NSString *vShaderFilePath = [[NSBundle mainBundle] pathForResource:vShaderFileName ofType:@"vsh"];
    NSString *fShaderFilePath = [[NSBundle mainBundle] pathForResource:fShaderFileName ofType:@"fsh"];
    
    NSString *vShaderString = [NSString stringWithContentsOfFile:vShaderFilePath encoding:NSUTF8StringEncoding error:nil];
    NSString *fShaderString = [NSString stringWithContentsOfFile:fShaderFilePath encoding:NSUTF8StringEncoding error:nil];
    
    return [self initWithVertexShaderString:vShaderString fragmentShaderString:fShaderString];
}

- (GLProgram *)initWithVertexShaderString:(NSString *)vShaderString
                     fragmentShaderString:(NSString *)fShaderString {
    self = [super init];
    if (self) {
        
        _program = glCreateProgram();
        
        if (![self compileShader:&_vShader type:GL_VERTEX_SHADER string:vShaderString]) {
            NSLog(@"顶点着色器创建失败");
        }
        
        if (![self compileShader:&_fShader type:GL_FRAGMENT_SHADER string:fShaderString]) {
            NSLog(@"片元着色器创建失败");
        }
        
        glAttachShader(_program, _vShader);
        glAttachShader(_program, _fShader);
    }
    
    return self;
}

#pragma mark - Public Method

- (BOOL)link {
    GLint status;
    
    glLinkProgram(_program);
    glGetProgramiv(_program, GL_LINK_STATUS, &status);
    
    if (status == GL_FALSE) {
        return NO;
    }
    
    if (_vShader) {
        glDeleteShader(_vShader);
        _vShader = 0;
    }
    
    if (_fShader) {
        glDeleteShader(_fShader);
        _fShader = 0;
    }
    
    return YES;
}

- (void)use {
    glUseProgram(_program);
}

- (void)validate {
    GLint logLength;
    glValidateProgram(_program);
    glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(_program, logLength, &logLength, log);
        NSAssert(NO, @"程序不可用");
        free(log);
    }
}

- (GLuint)attributeIndex:(NSString *)attributeName {
    return glGetAttribLocation(_program, [attributeName UTF8String]);
}

- (GLuint)uniformIndex:(NSString *)uniformName {
    return glGetUniformLocation(_program, [uniformName UTF8String]);
}

#pragma mark - Private Method

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type string:(NSString *)shaderString {
    GLint status;
    const GLchar *source = [shaderString UTF8String];
    if (!source) {
        NSLog(@"着色器文本不存在");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status != GL_TRUE) {
        GLint logLength;
        glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0) {
            GLchar *log = (GLchar *)malloc(logLength);
            glGetShaderInfoLog(*shader, logLength, &logLength, log);
            NSLog(@"着色器编译失败");
            free(log);
            return NO;
        }
    }
    
    return status == GL_TRUE;
}

@end
