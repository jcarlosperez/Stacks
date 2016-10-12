//
//  CPPCChoicesCollectionView.m
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCChoicesCollectionView.h"
#import "CPPCChoicesCollectionViewCell.h"

static NSString *const kPCImageSelectionCell = @"CPSSFeaturedPlaylistCell";

@implementation CPPCChoicesCollectionView

- (instancetype)init {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(75, 75);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.minimumLineSpacing = 10;
    
    if (self = [super initWithFrame:CGRectZero collectionViewLayout:flowLayout]) {
        _imageAssets = [NSMutableArray array];
        
        self.delegate = self;
        self.dataSource = self;
        [self registerClass:[CPPCChoicesCollectionViewCell class] forCellWithReuseIdentifier:kPCImageSelectionCell];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)updateViewWithImage:(UIImage *)image {
    [_imageAssets addObject:image];
    [self reloadData];
}

- (void)updateViewWithImageAtPath:(NSString *)filePath {
    
    [_imageAssets addObject:filePath];
    [self reloadData];
}

#pragma mark - UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPPCChoicesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPCImageSelectionCell forIndexPath:indexPath];
    cell.selectedImageView.image = _imageAssets[indexPath.row];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imageAssets.count;
}

@end
