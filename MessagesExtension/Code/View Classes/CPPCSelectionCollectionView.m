//
//  CPPCSelectionCollectionView.m
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/24/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCImageRatingView.h"
#import "CPPCSelectionCollectionView.h"
#import "CPPCSelectionCollectionViewCell.h"
#import "CPPCServerManager.h"
#import "CPPCCarouselFlowLayout.h"
#import "RXPromise.h"

static NSString *const kPCChoiceSelectionCell = @"CPPCChoiceSeletionCell";

@interface CPPCSelectionCollectionView () <CPPCImageRatingDelegate> {
    CGSize cellSize;
    CPPCCarouselFlowLayout *_flowLayout;
}

@property (strong, nonatomic) NSArray *fileURLs;

@end

@implementation CPPCSelectionCollectionView

- (instancetype)init {
    
    
    _flowLayout = [[CPPCCarouselFlowLayout alloc] init];
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _flowLayout.sideItemAlpha = 0.6;
    _flowLayout.sideItemScale = 0.8;
    _flowLayout.spacing = -10;
    _flowLayout.spacingMode = OverlapMode;
    _flowLayout.visibleOffset = 20;
    
    if (self = [super initWithFrame:CGRectZero collectionViewLayout:_flowLayout]) {
        
        _choiceImageKeys = [NSMutableArray array];
        
        self.delegate = self;
        self.dataSource = self;
        self.scrollEnabled = YES;
        self.pagingEnabled = NO;
        [self registerClass:[CPPCSelectionCollectionViewCell class] forCellWithReuseIdentifier:kPCChoiceSelectionCell];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setChoiceImageKeys:(NSArray *)choiceImageKeys {
    
    _choiceImageKeys = choiceImageKeys;
    
    for(NSString *imageKey in choiceImageKeys) {
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.jpg", [NSTemporaryDirectory() stringByAppendingPathComponent:@"download"], imageKey]]) {
            
            [[CPPCServerManager sharedInstance] downloadImageWithKey:imageKey withSuccessBlock:^(AWSTask *responseTask) {
                
            } failureBlock:^(NSError *error) {
                NSLog(@"Failure: %@", error);
            }];
            
        }
    }
}


#pragma mark - CPPCRatingDelegate

- (void)rateView:(CPPCImageRatingView *)rateView changedToNewRate:(NSNumber *)rate {
    
}

#pragma mark - scrollview delegate
/*        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
 let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
 let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
 currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)*/

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{ // for custom paging
    CGFloat movingX = velocity.x * scrollView.frame.size.width;
    CGFloat newOffsetX = scrollView.contentOffset.x + movingX;
    
    int page = floor((newOffsetX - cellSize.width / 2) / cellSize.width) + 1;
    
    if(page <= 0){
        newOffsetX = 0;
    } else if(page == 1) {
        newOffsetX = cellSize.width-30;
    } else if(page == 2) {
        newOffsetX = cellSize.width*2;
    } else if(page == 3) {
        newOffsetX = cellSize.width*3+30;
    }
    
    targetContentOffset->x = newOffsetX;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    if(self.frame.size.width > 0){
        cellSize = CGSizeMake(self.frame.size.width-60, self.frame.size.width-60);
        _flowLayout.itemSize = cellSize;
    }
    
    [super layoutSubviews];
}
#pragma mark - UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPPCSelectionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPCChoiceSelectionCell forIndexPath:indexPath];
    
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@.jpg", [NSTemporaryDirectory() stringByAppendingPathComponent:@"download"], _choiceImageKeys[indexPath.row]];
    cell.choiceImageView.image = [UIImage imageWithContentsOfFile:imagePath];
    cell.choiceImageView.backgroundColor = [UIColor greenColor];
    cell.ratingView.delegate = self;
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"%@ the thing is ", _fileURLs);
    return _choiceImageKeys.count;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat gap = (self.frame.size.width - cellSize.width)/2.0f;
    return UIEdgeInsetsMake(0, gap, 0, gap);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return cellSize;
}

@end
