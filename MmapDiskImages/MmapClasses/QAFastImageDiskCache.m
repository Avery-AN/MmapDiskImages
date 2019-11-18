//
//  QAFastImageDiskCache.m
//  TestProject
//
//  Created by Avery An on 2019/11/11.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import "QAFastImageDiskCache.h"

@interface QAFastImageDiskCache ()
@property (nonatomic) NSMutableDictionary *formatDic;
@property (nonatomic, copy) QAImageCacheCompletionBlock cacheCompletionBlock;
@property (nonatomic, copy) QAImageRequestCompletionBlock requestCompletionBlock;
@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) dispatch_semaphore_t semaphore;
@end

@implementation QAFastImageDiskCache

#pragma mark - Life Cycle -
+ (instancetype)sharedImageCache {
    static dispatch_once_t onceToken;
    static QAFastImageDiskCache *__imageCache = nil;
    dispatch_once(&onceToken, ^{
        __imageCache = [[[self class] alloc] init];
        __imageCache.formatDic = [NSMutableDictionary dictionary];
        __imageCache.queue = dispatch_queue_create("Avery.QAFastImageDiskCacheManager", DISPATCH_QUEUE_CONCURRENT);
        __imageCache.semaphore = dispatch_semaphore_create(0);
    });
    
    return __imageCache;
}


#pragma mark - Public Methods -
- (void)cacheImage:(UIImage * _Nonnull)image
               url:(NSURL * _Nonnull)url
       formatStyle:(QAImageFormatStyle)formatStyle {
    [self cacheImage:image url:url formatStyle:formatStyle completion:nil];
}
- (void)cacheFixedSizeImage:(UIImage * _Nonnull)image
                        url:(NSURL * _Nonnull)url
                formatStyle:(QAImageFormatStyle)formatStyle {
    [self cacheFixedSizeImage:image url:url formatStyle:formatStyle completion:nil];
}
- (void)cacheImage:(UIImage * _Nonnull)image
               url:(NSURL * _Nonnull)url
       formatStyle:(QAImageFormatStyle)formatStyle
        completion:(QAImageCacheCompletionBlock _Nullable)completion {
    @autoreleasepool {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.cacheCompletionBlock = completion;
            
            NSString *fileSavedPath = nil;
            QAImageFormat *format = nil;
            BOOL success = [self bsaeinfoProcess:image url:url formatStyle:formatStyle fileSavedPath:&fileSavedPath format:&format];
            if (success == NO) {
                return;
            }
            
            QAImageFileManager *fileManager = [QAImageFileManager new];
            [fileManager processCache:fileSavedPath
                         imageFormart:format
                                image:image];
            if (self.cacheCompletionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.cacheCompletionBlock();
                });
            }
        });
    }
}
- (void)cacheFixedSizeImage:(UIImage * _Nonnull)image
                        url:(NSURL * _Nonnull)url
                formatStyle:(QAImageFormatStyle)formatStyle
                 completion:(QAImageCacheCompletionBlock _Nullable)completion {
    @autoreleasepool {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.cacheCompletionBlock = completion;
            
            NSString *fileSavedPath = nil;
            QAImageFormat *format = nil;
            BOOL success = [self bsaeinfoProcess:image url:url formatStyle:formatStyle fileSavedPath:&fileSavedPath format:&format];
            if (success == NO) {
                return;
            }
            
            QAImageFileManager *fileManager = [QAImageFileManager new];
            [fileManager processFixedSizeCache:fileSavedPath
                                  imageFormart:format
                                         image:image];
            if (self.cacheCompletionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.cacheCompletionBlock();
                });
            }
        });
    }
}

- (void)requestDiskCachedImage:(NSURL * _Nonnull)url
                    completion:(QAImageRequestCompletionBlock _Nullable)completion {
    @autoreleasepool {
        self.requestCompletionBlock = completion;
        
        NSString *key = [url.absoluteString md5Hash];
        NSString *fileSavedPath = [QAImageCachePath getImageCachedFilePath:key];
        // NSLog(@"fileSavedPath: %@", fileSavedPath);
        
        [self getFormatWithKey:key
                    completion:^(QAImageFormat *format) {
                    QAImageFileManager *fileManager = [QAImageFileManager new];
                    UIImage *image = [fileManager processRequest:fileSavedPath
                                                    imageFormart:format];
                    
                    if (self.requestCompletionBlock) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [CATransaction setCompletionBlock:^{
                                [fileManager clearTheBattlefield];
                            }];
                            
                            self.requestCompletionBlock(image);
                        });
                    }
                    else {
                        [fileManager clearTheBattlefield];
                    }
            }];
    }
}


#pragma mark - Private Methods -
- (BOOL)bsaeinfoProcess:(UIImage *)image
                    url:(NSURL * _Nonnull)url
            formatStyle:(QAImageFormatStyle)formatStyle
          fileSavedPath:(NSString * __strong *)fileSavedPath
                 format:(QAImageFormat * __strong *)format {
    NSString *key = [url.absoluteString md5Hash];
    NSString *fileSavedPath_tmp = [QAImageCachePath getImageCachedFilePath:key];
    if (!fileSavedPath_tmp) {
        return NO;
    }
    *fileSavedPath = fileSavedPath_tmp;
    // NSLog(@"fileSavedPath: %@", fileSavedPath_tmp);

    QAImageFormat *format_tmp = [self.formatDic valueForKey:key];
    if (!format_tmp) {
        format_tmp = [QAImageFormat new];
        [self setFormat:format_tmp key:key];
    }
    *format = format_tmp;
    (*format).formatStyle = formatStyle;
    (*format).imageSize = image.size;
    
    return YES;
}
- (void)getFormatWithKey:(NSString * _Nonnull)key completion:(void(^)(QAImageFormat *format))completion {
    dispatch_async(self.queue, ^{
        QAImageFormat *format = [self.formatDic valueForKey:key];
        if (completion) {
            completion(format);
        }
    });
}
- (void)setFormat:(QAImageFormat * _Nonnull)format key:(NSString * _Nonnull)key {
    dispatch_barrier_async(self.queue, ^{
        [self.formatDic setObject:format forKey:key];
    });
}

@end
