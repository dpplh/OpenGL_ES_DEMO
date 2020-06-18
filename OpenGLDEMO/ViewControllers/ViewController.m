//
//  ViewController.m
//  OpenGLDEMO
//
//  Created by DPP on 2020/4/17.
//  Copyright © 2020 DPP. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray<NSDictionary *> *items;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    
    NSDictionary *item = self.items[indexPath.item];
    cell.textLabel.text = item[@"title"];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = self.items[indexPath.item];
    NSString *vcName = item[@"viewController"];
    NSString *title = item[@"title"];
    UIViewController *vc = [[NSClassFromString(vcName) alloc] init];
    vc.title = title;
    
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Accessor

- (NSArray<NSDictionary *> *)items {
    if (!_items) {
        _items = @[
            @{@"title": @"三角形绘制", @"viewController": @"TriangleViewController"},
            @{@"title": @"图片绘制GLKit-GLKView", @"viewController": @"GLKViewImageViewController"},
            @{@"title": @"图片绘制GLKit", @"viewController": @"ImageViewController"},
            @{@"title": @"图片绘制GLSL", @"viewController": @"ImageGLSLViewController"},
            @{@"title": @"LUT", @"viewController": @"LUTViewController"},
            @{@"title": @"长腿瘦身", @"viewController": @"BodyViewController"},
            @{@"title": @"坐标系统", @"viewController": @"CoordSystemViewController"},
            @{@"title": @"Camera", @"viewController": @"CameraViewController"},
            @{@"title": @"立方体", @"viewController": @"CubeViewController"},
            @{@"title": @"光照", @"viewController": @"LightingViewController"},
            @{@"title": @"镜面反射", @"viewController": @"SpecularViewController"},
            @{@"title": @"LUT滤镜", @"viewController": @"LUTApplyViewController"},
            @{@"title": @"阿凡达3D", @"viewController": @"AvatarViewController"},
        ];
    }
    
    return _items;
}


@end
