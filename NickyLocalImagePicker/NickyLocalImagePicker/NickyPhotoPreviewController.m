//
//  NickyPhotoPreviewController.m
//  NickyLocalImagePicker
//
//  Created by NickyTsui on 15/12/30.
//  Copyright © 2015年 com.nickyTsui. All rights reserved.
//

#import "NickyPhotoPreviewController.h"
#import "NickyCategoryTools.h"
static NSString *const NickyPreviewCellIdentifier = @"NickyPreviewCellIdentifier";

@interface NickyPhotoPreviewCell : UICollectionViewCell
@property (strong,nonatomic)UIImageView         *previewImageView;

@end

@implementation NickyPhotoPreviewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self.contentView addSubview:self.previewImageView];
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    _previewImageView.frame = self.contentView.frame;
}
- (UIImageView *)previewImageView
{
    if (!_previewImageView){
        _previewImageView = [[UIImageView alloc]init];
        _previewImageView.contentMode = UIViewContentModeScaleAspectFit;
        _previewImageView.layer.masksToBounds = YES;
    }
    return _previewImageView;
}

@end

@interface NickyPhotoPreviewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (strong,nonatomic) UICollectionView                            *collectionView;

@property (strong,nonatomic) UICollectionViewFlowLayout                  *collectionViewLayout;

@property (strong,nonatomic) UIView                                      *bottomView;

@property (strong,nonatomic) UIButton                                    *originalButton;

@property (strong,nonatomic) UIButton                                    *finishButton;

@property (strong,nonatomic) UIButton                                    *selectButton;

@property (assign,nonatomic) BOOL                                        originalPhoto;

@property (strong,nonatomic) NSMutableArray                             *selectedArray;
@end

@implementation NickyPhotoPreviewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateSelectionStatus];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self didRotateFromInterfaceOrientation:self.interfaceOrientation];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.bottomView];
    
    if (self.currentPage){
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
    
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc]initWithCustomView:self.selectButton];
    self.navigationItem.rightBarButtonItem = rightbutton;
    // Do any additional setup after loading the view.
}
- (void)finish:(NSArray *)callBackArray{
    if (self.naviController.pickerDelegate && [self.naviController.pickerDelegate respondsToSelector:@selector(nickyImagePicker:didSelectedImages:)]){
        [self.naviController.pickerDelegate nickyImagePicker:self.naviController didSelectedImages:callBackArray];
    }
    [self.naviController dismissViewControllerAnimated:YES completion:nil];
}
- (void)finishAction:(UIButton *)button{
    __block int i = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
        NSMutableArray *callbackArray = [[NSMutableArray alloc]init];
        for (NickyPhotoAlAssetModel *assetModel in self.selectedArray) {
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
            [library assetForURL:assetModel.photoURL resultBlock:^(ALAsset *asset) {
                i++;
                if (self.originalPhoto){
                    [callbackArray addObject:[UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage]];
                }
                else{
                    [callbackArray addObject:[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage]];
                }
                if (i==(self.selectedArray.count)){
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [self finish:callbackArray];
                    });
                }
            } failureBlock:^(NSError *error) {
                i++;
                if (i==(self.selectedArray.count)){
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [self finish:callbackArray];
                    });
                }
            }];
        }
        
    });

}
- (void)updateSelectionStatus{
    self.selectedArray = [[NSMutableArray alloc]init];
    BOOL isSelected = NO;
    NSInteger selectedNumber = 0;
    for (NickyPhotoAlAssetModel *assetModel in self.photoArray) {
        if (assetModel.selected){
            selectedNumber++;
            [self.selectedArray addObject:assetModel];
        }
    }
    isSelected = selectedNumber;
    self.finishButton.enabled = isSelected;
    [self.finishButton setTitle:[NSString stringWithFormat:@"完成( %zd )",selectedNumber] forState:UIControlStateNormal];
}
- (void)useOriginalAction:(UIButton *)button{
    self.originalPhoto = !self.originalPhoto;
}
- (void)setOriginalPhoto:(BOOL)originalPhoto{
    _originalPhoto = originalPhoto;
    [self.collectionView reloadData];
    if (!self.originalPhoto){
        [self.originalButton setTitle:@"原图" forState:UIControlStateNormal];
        [self.originalButton setTitleColor:[UIColor colorWithHexString:@"#121212"] forState:UIControlStateNormal];
        self.originalButton.frame = ({
            CGRect frame = self.originalButton.frame;
            frame.size.width = 40;
            frame;
        });
    }
    else{
        [self.originalButton setTitleColor:[UIColor colorWithHexString:@"#09BB07"] forState:UIControlStateNormal];
    }
}
- (void)selectAction:(UIButton *)button{
    NSIndexPath *index = [self.collectionView indexPathForItemAtPoint:self.collectionView.contentOffset];
    NickyPhotoAlAssetModel *model = self.photoArray[index.item];
    model.selected = !model.selected;
    [self.collectionView reloadData];
    [self updateSelectionStatus];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    NSIndexPath *index = [self.collectionView indexPathForItemAtPoint:self.collectionView.contentOffset];
    NickyPhotoAlAssetModel *model = self.photoArray[index.item];
    self.currentPage = index.item;
    self.selectButton.selected = model.isSelected;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NickyPhotoPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NickyPreviewCellIdentifier forIndexPath:indexPath];
    NickyPhotoAlAssetModel *assetModel = self.photoArray[indexPath.item];
    [cell.previewImageView loadLibraryBigImage:assetModel.photoURL placeImage:assetModel.thumbsImage finishBlock:^(UIImage *image, NSInteger imageSize) {
        if (self.originalPhoto){
            NSString *titleString = [NSString stringWithFormat:@"原图(%.2lfMB)",imageSize/1024.0/1024.0];
            [self.originalButton setTitle:titleString forState:UIControlStateNormal];
            CGFloat width = [titleString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.originalButton.titleLabel.font} context:NULL].size.width;
            self.originalButton.frame = ({
                CGRect frame = self.originalButton.frame;
                frame.size.width = width+12;
                frame;
            });
        }
    }];
    self.selectButton.selected = assetModel.isSelected;

    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (!self.navigationController.navigationBarHidden){
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [UIView animateWithDuration:.2 animations:^{
            self.bottomView.frame = ({
                CGRect frame = self.bottomView.frame;
                frame.origin.y =self.view.bounds.size.height;
                frame;
            });
        }];
    }
    else{
        [UIView animateWithDuration:.2 animations:^{
            self.bottomView.frame = ({
                CGRect frame = self.bottomView.frame;
                frame.origin.y = self.view.bounds.size.height-44;
                frame;
            });
        }];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photoArray.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.bounds.size;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (UICollectionView *)collectionView{
    if (!_collectionView){
        _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:self.collectionViewLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[NickyPhotoPreviewCell class] forCellWithReuseIdentifier:NickyPreviewCellIdentifier];
        _collectionView.pagingEnabled = YES;
    }
    return _collectionView;
}
- (UICollectionViewFlowLayout *)collectionViewLayout{
    if (!_collectionViewLayout){
        _collectionViewLayout = [[UICollectionViewFlowLayout alloc]init];
        _collectionViewLayout.scrollDirection = 1;
    }
    return _collectionViewLayout;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIView *)bottomView{
    if (!_bottomView){
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
        _bottomView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA" alpha:.9];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _bottomView.bounds.size.width, .5)];
        line.backgroundColor = [UIColor colorWithHexString:@"#C0C0C0"];
        [_bottomView addSubview:line];
        [_bottomView addSubview:self.originalButton];
        [_bottomView addSubview:self.finishButton];
    }
    return _bottomView;
}
- (UIButton *)finishButton{
    if (!_finishButton){
        _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishButton.frame = CGRectMake(_bottomView.bounds.size.width-60-10, 0, 60, 44);
        _finishButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_finishButton setTitle:@"完成" forState:UIControlStateNormal];
        [_finishButton setTitleColor:[UIColor colorWithHexString:@"#09BB07"] forState:UIControlStateNormal];
        [_finishButton setTitleColor:[UIColor colorWithHexString:@"#cfcfcf"] forState:UIControlStateHighlighted];
        [_finishButton setTitleColor:[UIColor colorWithHexString:@"#cfcfcf"] forState:UIControlStateDisabled];
        [_finishButton addTarget:self action:@selector(finishAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishButton;
}
- (UIButton *)originalButton{
    if (!_originalButton){
        _originalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalButton.frame = CGRectMake(10, 0, 40, 44);
        _originalButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_originalButton setTitle:@"原图" forState:UIControlStateNormal];
        [_originalButton setTitleColor:[UIColor colorWithHexString:@"#121212"] forState:UIControlStateNormal];
        [_originalButton addTarget:self action:@selector(useOriginalAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _originalButton;
}
- (UIButton *)selectButton{
    if (!_selectButton){
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectButton.frame = CGRectMake(0, 0, 20,20);
        [_selectButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithWhite:1 alpha:1]] forState:UIControlStateNormal];
        [_selectButton setBackgroundImage:[UIImage createImageWithColor:[UIColor redColor]] forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [UIView animateWithDuration:.2 animations:^{
        
        self.collectionView.frame = self.view.bounds;
        
        self.bottomView.frame = CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44);
        self.finishButton.frame = CGRectMake(_bottomView.bounds.size.width-60-10, 0, 60, 44);
        self.originalButton.frame = CGRectMake(10, 0, 40, 44);
        
    }];
    [self.collectionView reloadData];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}
@end


