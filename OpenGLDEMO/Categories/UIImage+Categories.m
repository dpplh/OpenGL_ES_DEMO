
//
//  UIImage+Categories.m
//  OpenGLDEMO
//
//  Created by DPP on 2020/4/24.
//  Copyright © 2020 DPP. All rights reserved.
//

#import "UIImage+Categories.h"
#import <GLKit/GLKit.h>

@implementation UIImage (Categories)

- (GLuint)texture:(BOOL)needTransform {
    CGImageRef imageRef = self.CGImage;
    
    GLint width = (GLint)CGImageGetWidth(imageRef);
    GLint height = (GLint)CGImageGetHeight(imageRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    void * imageData = malloc(width * height * 4);
    CGContextRef contextRef = CGBitmapContextCreate(imageData, width, height, 8, 4 * width, colorSpaceRef, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGColorSpaceRelease(colorSpaceRef);
    
    if (needTransform) {
        CGContextTranslateCTM(contextRef, 0, height);
        CGContextScaleCTM(contextRef, 1.0, -1.0);
    }
    CGContextDrawImage(contextRef, rect, imageRef);
    
    GLuint textureID;
    glGenBuffers(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    CGContextRelease(contextRef);
    free(imageData);
    
    return textureID;
}

- (GLuint)texture {
    return [self texture:YES];
}

@end
