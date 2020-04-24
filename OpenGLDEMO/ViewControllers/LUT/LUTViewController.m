//
//  LUTViewController.m
//  OpenGLDEMO
//
//  Created by DPP on 2020/4/20.
//  Copyright © 2020 DPP. All rights reserved.
//

#import "LUTViewController.h"

typedef struct {
    char r, g, b, a;
} RGBA;

@interface LUTViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation LUTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
 
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    
    self.imageView.image = [self generateLookupImage];
}

- (UIImage *)generateLookupImage {
    RGBA rgba[8 * 64][8 * 64];
    
    for (int by = 0; by < 8; by++) {
        for (int bx = 0; bx < 8; bx++) {
            for (int g = 0; g < 64; g++) {
                for (int r = 0; r < 64; r++) {
                    // 将RGB[0, 255]分成64份，每份相差4个单位， +0.5做四舍五入运算
                    int rr = (int)(r * 255.0 / 63.0 + 0.5);
                    int gg = (int)(g * 255.0 / 63.0 + 0.5);
                    int bb = (int)((bx + by * 8) * 255.0 / 63.0 + 0.5);
                    int aa = 255.0;
                    int x = r + bx * 64;
                    int y = g + by * 64;
                    
                    rgba[y][x] = (RGBA){rr, gg, bb, aa};
                }
            }
        }
    }
    
    int width = 8 * 64;
    int height = 8 * 64;
    
    size_t bufferLength = width * height * 4;
    CGDataProviderRef dataProviderRef = CGDataProviderCreateWithData(NULL, &rgba, bufferLength, NULL);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    CGImageRef imageRef = CGImageCreate(width, height, 8, 32, width * 4, colorSpaceRef, bitmapInfo, dataProviderRef, NULL, YES, renderingIntent);
    
    uint32_t *pixels = (uint32_t *)malloc(bufferLength);
    if (pixels == NULL) {
        NSLog(@"Error: Memory not allocted for bitmap");
        CGDataProviderRelease(dataProviderRef);
        CGColorSpaceRelease(colorSpaceRef);
        CGImageRelease(imageRef);
        
        return nil;
    }
    
    CGContextRef contextRef = CGBitmapContextCreate(pixels, width, height, 8, 32, colorSpaceRef, kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    UIImage *image = nil;
    if ([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
        float scale = [UIScreen mainScreen].scale;
        image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    } else {
        image = [UIImage imageWithCGImage:imageRef];
    }
    
    CGImageRelease(imageRef);
    CGContextRelease(contextRef);
    CGDataProviderRelease(dataProviderRef);
    CGColorSpaceRelease(colorSpaceRef);
    free(pixels);
    
//    [UIImagePNGRepresentation(image) writeToFile:@"Users/meitu/Desktop/loopup.png" atomically:YES];
    
    return image;
}

@end
