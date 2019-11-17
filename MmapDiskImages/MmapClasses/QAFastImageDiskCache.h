//
//  QAFastImageDiskCache.h
//  TestProject
//
//  Created by Avery An on 2019/11/11.
//  Copyright © 2019 Avery An. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QAFastImageDiskCacheConfig.h"

typedef void (^QAImageCacheCompletionBlock)(void);
typedef void (^QAImageRequestCompletionBlock)(UIImage * _Nullable image);

NS_ASSUME_NONNULL_BEGIN

@interface QAFastImageDiskCache : NSObject

+ (instancetype)sharedImageCache;

- (void)cacheImage:(UIImage * _Nonnull)image
               url:(NSURL * _Nonnull)url
       formatStyle:(QAImageFormatStyle)formatStyle;

- (void)cacheImage:(UIImage * _Nonnull)image
               url:(NSURL * _Nonnull)url
       formatStyle:(QAImageFormatStyle)formatStyle
        completion:(QAImageCacheCompletionBlock _Nullable)completion;

- (void)cacheFixedSizeImage:(UIImage * _Nonnull)image
                        url:(NSURL * _Nonnull)url
                formatStyle:(QAImageFormatStyle)formatStyle;

- (void)cacheFixedSizeImage:(UIImage * _Nonnull)image
                        url:(NSURL * _Nonnull)url
                formatStyle:(QAImageFormatStyle)formatStyle
                 completion:(QAImageCacheCompletionBlock _Nullable)completion;

- (void)requestDiskCachedImage:(NSURL * _Nonnull)url
                    completion:(QAImageRequestCompletionBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
