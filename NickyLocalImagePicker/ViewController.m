//
//  ViewController.m
//  NickyLocalImagePicker
//
//  Created by NickyTsui on 15/12/30.
//  Copyright © 2015年 com.nickyTsui. All rights reserved.
//

#import "ViewController.h"
#import "NickyImagePickerViewController.h"
@interface ViewController ()<NickyImagePickerDelegate,UIScrollViewDelegate>
@property (strong,nonatomic)UIImageView          *img;
@property (strong,nonatomic)UIScrollView *scrollView;
@end

@implementation ViewController
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.img;
}
- (UIImageView *)img{
    if (!_img){
        _img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
        _img.backgroundColor = [UIColor redColor];
    }
    return _img;
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    if(scrollView.zoomScale <=1) scrollView.zoomScale = 1.0f;
    
    CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
    
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter;
    
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter;
    NSLog(@"\n%@",NSStringFromCGRect(self.scrollView.frame));
    [self.img setCenter:CGPointMake(xcenter, ycenter)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.minimumZoomScale = 1;
    self.scrollView.delegate =self;
    [self.scrollView addSubview:self.img];
    self.img.center = self.view.center;
    [self.view addSubview:self.scrollView];
    
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
