//
//  RootViewController.m
//  MmapDiskImages
//
//  Created by Avery An on 2019/11/17.
//  Copyright © 2019 Avery. All rights reserved.
//

#import "RootViewController.h"
#import "QAFastImageDiskCache.h"

static NSString *QAFilesPath = @"QAAllFilesPath";
static NSString *QAImageCache = @"QACachedImages";

@interface RootViewController ()
@property (nonatomic) QAFastImageDiskCache *fastImageDiskCache;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 110, 316, 100)];
    imageView.backgroundColor = [UIColor orangeColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageNamed:@"ne_zha.jpg"];
    [self.view addSubview:imageView];
    
    
    UIButton *button_0 = [UIButton buttonWithType:UIButtonTypeCustom];
    button_0.backgroundColor = [UIColor orangeColor];
    button_0.frame = CGRectMake(30, 250, 316, 40);
    [button_0 setTitle:@"CacheImage" forState:UIControlStateNormal];
    [button_0 addTarget:self action:@selector(cacheAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_0];
    
    UIButton *button_1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button_1.backgroundColor = [UIColor orangeColor];
    button_1.frame = CGRectMake(30, 300, 316, 40);
    [button_1 setTitle:@"getCacheNormal - display" forState:UIControlStateNormal];
    [button_1 addTarget:self action:@selector(getCacheAction_normal) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_1];
    
    UIButton *button_2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button_2.backgroundColor = [UIColor orangeColor];
    button_2.frame = CGRectMake(30, 350, 316, 50);
    [button_2 setTitle:@"getCacheMmap - display" forState:UIControlStateNormal];
    [button_2 addTarget:self action:@selector(getCacheAction_mmap) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_2];
}

#pragma mark - Actions -
- (void)cacheAction {
    [self cacheImage_normal];
    
    {
        /*
         NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://upload-images.jianshu.io/upload_images/2748485-8caa321e4f1aadf5"]];
         UIImage *image = [UIImage imageWithData:data];
         */
        UIImage *image = [UIImage imageNamed:@"ne_zha.jpg"];
        if (!self.fastImageDiskCache) {
            self.fastImageDiskCache = [QAFastImageDiskCache new];
        }
        [self.fastImageDiskCache cacheImage:image
                                 identifier:@"test-url"
                                formatStyle:QAImageFormatStyle_32BitBGRA];
    }
}
- (void)getCacheAction_normal {
    NSString *fileSavedPath = [self getImageCachedPath_normal];
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    UIImage *image = [UIImage imageWithContentsOfFile:fileSavedPath];
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime loadTime = endTime - startTime;
    NSLog(@"loadTime(disk-cache): %f",loadTime);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 430, 316, 100)];
    imageView.backgroundColor = [UIColor orangeColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = image;
    [self.view addSubview:imageView];
    
    /*
     NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:fileSavedPath]];
     UIImage *image = [UIImage imageWithData:data];
     */
    
    
    {
        startTime = CFAbsoluteTimeGetCurrent();
        image = [UIImage imageNamed:@"ne_zha.jpg"];
        endTime = CFAbsoluteTimeGetCurrent();
        loadTime = endTime - startTime;
        NSLog(@"loadTime(memory-cache): %f",loadTime);
    }
}
- (void)getCacheAction_mmap {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 540, 316, 100)];
    imageView.backgroundColor = [UIColor orangeColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];

    if (!self.fastImageDiskCache) {
        self.fastImageDiskCache = [QAFastImageDiskCache new];
    }
    [self.fastImageDiskCache requestDiskCachedImage:@"test-url"
                                         completion:^(UIImage * _Nullable image) {
        imageView.image = image;
    } failed:^(NSString * _Nonnull identifierString, NSError * _Nullable error) {
        
    }];
}


#pragma mark - Private Methods -
- (void)cacheImage_normal {
    NSString *fileSavedPath_normal = [self getImageCachedPath_normal];
    // UIImage *image = [UIImage imageNamed:@"ne_zha_2"];
    // [UIImagePNGRepresentation(image) writeToFile:fileSavedPath_normal atomically:YES];
    UIImage *image = [UIImage imageNamed:@"ne_zha.jpg"];
    [UIImageJPEGRepresentation(image, 1) writeToFile:fileSavedPath_normal atomically:YES];
}
- (NSString *)getImageCachedPath_normal {
    NSString *cacheImageFilePath = [self createImageCachePath:QAImageCache];  // 创建图片保存路径
    NSString *fileName = @"ne_zha.normal";
    NSString *fileSavedPath_normal = [cacheImageFilePath stringByAppendingPathComponent:fileName];
    return fileSavedPath_normal;
}
- (NSString *)createImageCachePath:(NSString *)pathName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *pathURL = [fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];

    NSString *plistPath = [NSString stringWithFormat:@"%@/%@/%@", [pathURL path], QAFilesPath, pathName];
    BOOL ui;
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath isDirectory:&ui]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:plistPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return plistPath;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
