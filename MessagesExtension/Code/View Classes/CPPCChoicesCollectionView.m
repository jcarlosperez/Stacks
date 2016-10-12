//
//  CPPCChoicesCollectionView.m
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/9/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCChoicesCollectionView.h"
#import "CPPCChoicesCollectionViewCell.h"
#import "KTCenterFlowLayout.h"

static NSString *const kPCImageSelectionCell = @"CPSSFeaturedPlaylistCell";

@implementation CPPCChoicesCollectionView

- (instancetype)init {
    
    KTCenterFlowLayout *flowLayout = [[KTCenterFlowLayout alloc] init];
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
#pragma mark - Collection View Delegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CPPCChoicesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPCImageSelectionCell forIndexPath:indexPath];
    
    // If we're on the cell to be the "New Image" cell
    if(_imageAssets.count == 0) {
        cell.selectedImageView.image = [UIImage imageNamed:@"add"];
    } else {
        if(indexPath.row > _imageAssets.count - 1) {
            cell.selectedImageView.image = [UIImage imageNamed:@"add"];
        } else {
            
            NSLog(@"Shoud show user image");
            
            UIImage *userImage = _imageAssets[indexPath.row];
            
            NSLog(@"User image: %@", userImage);
            cell.selectedImageView.image = userImage;
        }
    }
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    // Count the image assets and add 1 for the "New Image" cell
    return _imageAssets.count + 1;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == _imageAssets.count) {
        NSLog(@"Tapped Add Cell");
        [_choicesDelegate addImageCellTapped];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //CGFloat pageWidth = scrollView.frame.size.width;
    //int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

@end
