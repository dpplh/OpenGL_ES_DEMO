//
//  UIImage+Categories.h
//  OpenGLDEMO
//
//  Created by DPP on 2020/4/24.
//  Copyright © 2020 DPP. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Categories)

- (GLuint)texture;

- (GLuint)texture:(BOOL)needTransform;

@end

NS_ASSUME_NONNULL_END
