//
//  ViewController.m
//  NickyLocalImagePicker
//
//  Created by NickyTsui on 15/12/30.
//  Copyright © 2015年 com.nickyTsui. All rights reserved.
//

#import "ViewController.h"
#import "NickyImagePickerViewController.h"
@interface ViewController ()<NickyImagePickerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc]initWithTitle:@"picker" style:UIBarButtonItemStyleBordered target:self action:@selector(pickerAction:)];
    self.navigationItem.rightBarButtonItem = barItem;
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)pickerAction:(id)sender{
    NickyImagePickerViewController *pickerController = [[NickyImagePickerViewController alloc]init];
    pickerController.pickerDelegate = self;
    [self.navigationController presentViewController:pickerController animated:YES completion:nil];
}
- (void)nickyImagePicker:(NickyImagePickerViewController *)picker didSelectedImages:(NSArray<UIImage *> *)imageArray{
    NSLog(@"%@",imageArray);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
