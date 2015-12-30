//
//  NickyImagePickerViewController.h
//  NickyLocalImagePicker
//
//  Created by NickyTsui on 15/12/30.
//  Copyright © 2015年 com.nickyTsui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NickyImagePickerDelegate;
@interface NickyImagePickerViewController : UINavigationController
@property (weak,nonatomic) id <NickyImagePickerDelegate>        pickerDelegate;
@end

@protocol NickyImagePickerDelegate <NSObject>

- (void)nickyImagePicker:(NickyImagePickerViewController *)picker didSelectedImages:(NSArray<UIImage*> *)imageArray;

@end