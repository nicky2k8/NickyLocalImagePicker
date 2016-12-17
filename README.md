# NickyLocalImagePicker
本地相册选择器
<br>

<img src="http://images2015.cnblogs.com/blog/746201/201512/746201-20151230175347432-1548318696.gif" />
<br>

调用方法

    NickyImagePickerViewController *pickerController = [[NickyImagePickerViewController alloc]init];
    pickerController.pickerDelegate = self;  //设置代理
    [self.navigationController presentViewController:pickerController animated:YES completion:nil];
回调

- (void)nickyImagePicker:(NickyImagePickerViewController *)picker didSelectedImages:(NSArray<UIImage *> *)imageArray{
    NSLog(@"%@",imageArray);    // imageArray子元素为UIImage对象
}
