//
//  NickyPhotoAlbumListViewController.m
//  NickyLocalImagePicker
//
//  Created by NickyTsui on 15/12/30.
//  Copyright © 2015年 com.nickyTsui. All rights reserved.
//

#import "NickyPhotoAlbumListViewController.h"
#import "NickyPhotoImageListViewController.h"
#import "NickyPhotoAlbumModel.h"
#import <AssetsLibrary/AssetsLibrary.h>


#define AlbumCellHeight 60

@interface NickyPhotoAlbumListCell : UITableViewCell

@property (strong,nonatomic) UIImageView            *albumThumbImageView;

@property (strong,nonatomic) UILabel                *albumNameLabel;

@property (copy,nonatomic)   NSString               *albumName;

@property (copy,nonatomic)   NSString               *albumCount;

@property (copy,nonatomic)   NSMutableAttributedString  *attributeString;

- (void)setAlbumName:(NSString *)albumName albumCount:(NSString *)albumCount;
@end

@implementation NickyPhotoAlbumListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        [self.contentView addSubview:self.albumThumbImageView];
        [self.contentView addSubview:self.albumNameLabel];
    }
    return self;
}
- (void)setAlbumName:(NSString *)albumName albumCount:(NSString *)albumCount{
    _albumName = [albumName copy];
    _albumCount = [albumCount copy];
    [self refreshString];
}
- (NSMutableAttributedString *)attributeString{
    if (!_attributeString){
        _attributeString = [[NSMutableAttributedString alloc]initWithString:@""];
    }
    return _attributeString;
}
- (void)refreshString{
//    self.attributeString = [[NSMutableAttributedString alloc]init];
    NSAttributedString *attributeAlbumName = [[NSAttributedString alloc]initWithString:self.albumName attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14]}];
    [self.attributeString appendAttributedString:attributeAlbumName];
    
    [self.attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    
    
    NSAttributedString *attributeAlbumCount = [[NSAttributedString alloc]initWithString:self.albumCount attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName:[UIColor colorWithWhite:.6 alpha:1]}];
    
    [self.attributeString appendAttributedString:attributeAlbumCount];
    
    self.albumNameLabel.attributedText = self.attributeString;
}
- (void)setAlbumName:(NSString *)albumName{
    _albumName = [albumName copy];
    [self refreshString];
}
- (void)setAlbumCount:(NSString *)albumCount{
    _albumCount = [albumCount copy];
    [self refreshString];
}
- (UILabel *)albumNameLabel{
    if (!_albumNameLabel){
        _albumNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.albumThumbImageView.frame)+5, 0, ScreenWidth-(CGRectGetMaxX(self.albumThumbImageView.frame)+5), AlbumCellHeight)];
    }
    return _albumNameLabel;
}


- (UIImageView *)albumThumbImageView{
    if (!_albumThumbImageView) {
        _albumThumbImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, AlbumCellHeight, AlbumCellHeight)];
        _albumThumbImageView.layer.masksToBounds = YES;
        _albumThumbImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _albumThumbImageView;
}

@end

@interface NickyPhotoAlbumListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) NSMutableArray                 *albumListArray;


@property (strong,nonatomic) UITableView                    *tableView;


@end

@implementation NickyPhotoAlbumListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"照片";
    [self.view addSubview:self.tableView];
    [self loadAlbumList];
    // Do any additional setup after loading the view.
}
- (void)loadAlbumList{
    ALAssetsLibrary *assetsLibrary;
    assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            
            NickyPhotoAlbumModel *model = [[NickyPhotoAlbumModel alloc]init];
            model.thumbImageData = UIImageJPEGRepresentation([UIImage imageWithCGImage:group.posterImage], .9);
            model.albumName = [[group valueForProperty:ALAssetsGroupPropertyName] mutableCopy];
            model.albumCount = [group numberOfAssets];
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if ([[result valueForProperty:ALAssetPropertyType]isEqualToString:ALAssetTypePhoto]){
                    NickyPhotoAlAssetModel *alasetModel = [[NickyPhotoAlAssetModel alloc]init];
                    alasetModel.photoURL = [result valueForProperty:ALAssetPropertyAssetURL];
                    [model.photoArray addObject:alasetModel];
                }
            }];
            
            if (self.albumListArray.count){
                NickyPhotoAlbumModel *firstModel = self.albumListArray[0];
                if (firstModel.albumCount<model.albumCount){
                    [self.albumListArray insertObject:model atIndex:0];
                }
                else{
                    [self.albumListArray addObject:model];
                }
            }
            else{
                
                [self.albumListArray addObject:model];
            }
            
            
            [self.tableView reloadData];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"Group not found!\n");
    }];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NickyPhotoAlbumModel *model = self.albumListArray[indexPath.row];
    NickyPhotoImageListViewController *imageListController = [[NickyPhotoImageListViewController alloc]init];
    imageListController.model = model;
    [self.navigationController pushViewController:imageListController animated:YES];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.albumListArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return AlbumCellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"albumCell";
    NickyPhotoAlbumListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[NickyPhotoAlbumListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.separatorInset = UIEdgeInsetsMake(0, AlbumCellHeight, 0, 0);
    NickyPhotoAlbumModel *model = self.albumListArray[indexPath.row];
    cell.albumThumbImageView.image = [UIImage imageWithData:model.thumbImageData];
    [cell setAlbumName:model.albumName albumCount:[NSString stringWithFormat:@"(%zd)",model.albumCount]];
    
    return cell;
}

- (UITableView *)tableView{
    if (!_tableView){
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        _tableView.scrollIndicatorInsets = _tableView.contentInset;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)albumListArray{
    if (!_albumListArray){
        _albumListArray = [[NSMutableArray alloc]init];
    }
    return _albumListArray;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [UIView animateWithDuration:.2 animations:^{
        
        self.tableView.frame = self.view.bounds;
        self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetMaxY(self.navigationController.navigationBar.frame), 0, 0, 0);
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    }];
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

