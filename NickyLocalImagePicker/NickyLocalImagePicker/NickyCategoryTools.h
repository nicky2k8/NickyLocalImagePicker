//
//  UIImage+NickyAddition.h
//  NickyLocalImagePicker
//
//  Created by NickyTsui on 15/12/30.
//  Copyright © 2015年 com.nickyTsui. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^NickyBigPhotoLoadFinish)(UIImage *image , NSInteger imageSize);


#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
@interface UIColor (NickyAddition)

+ (UIColor*) colorWithHexString:(NSString*)color;
+ (UIColor*) colorWithHexString:(NSString*)color alpha:(float)opacity;
@end


@interface UIImage (NickyAddition)
+ (UIImage*)createImageWithColor:(UIColor*)color;

@end

@interface UIImageView (NickyAddition)
- (void)loadLibraryBigImage:(NSURL *)alassetURL placeImage:(UIImage *)placeImage finishBlock:(NickyBigPhotoLoadFinish)finishBlock;
@end