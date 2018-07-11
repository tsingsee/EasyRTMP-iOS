//
//  VideoViewController.m
//  EasyRTMP
//
//  Created by mac on 2018/7/10.
//  Copyright © 2018年 phylony. All rights reserved.
//

#import "VideoViewController.h"
#import "PromptView.h"
#import "VideoCell.h"

@interface VideoViewController ()<UICollectionViewDelegate, UICollectionViewDataSource> {
    PromptView *promptView;
    int countPerPage;// 每页的个数
}

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];// 设置collectionView的滚动方向
    
    CGRect frame = CGRectMake(5, 0, HRGScreenWidth - 10, HRGScreenHeight - HRGBarHeight - HRGNavHeight - 47);
    self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    // 注册collectionViewcell:WWCollectionViewCell是我自定义的cell的类型
    [self.collectionView registerClass:[VideoCell class] forCellWithReuseIdentifier:@"VideoCell"];
    // 注册collectionView头部的view，需要注意的是这里的view需要继承自UICollectionReusableView
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    // // 注册collectionView尾部的view
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
    [self.view addSubview:self.collectionView];
}

#pragma mark - UICollectionViewDataSource

// 每组cell的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

// cell的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoCell" forIndexPath:indexPath];
    
    // TODO
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // TODO
    
}

#pragma mark - UICollectionViewDelegateFlowLayout

// 每个cell的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat w = self.collectionView.bounds.size.width / 3;
    return CGSizeMake(w, w);
}

// 头部的尺寸
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(HRGScreenWidth, 0);
}

// 尾部的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(HRGScreenWidth, 0);
}

// section的margin
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - setter

// 读取本地录像
- (void) gainVideoData {
    
    // TODO
    
//    [self addNilDataView];
}

- (void) addNilDataView {
    if (!promptView) {
        promptView = [[PromptView alloc] initWithFrame:self.view.bounds];
    }
    
    [self.view addSubview:promptView];
}

@end
