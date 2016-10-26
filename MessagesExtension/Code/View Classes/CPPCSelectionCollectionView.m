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

static NSString *const kPCChoiceSelectionCell = @"CPPCChoiceSeletionCell";

@interface CPPCSelectionCollectionView () <CPPCImageRatingDelegate>
@end

@implementation CPPCSelectionCollectionView

- (instancetype)init {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    
    if (self = [super initWithFrame:CGRectZero collectionViewLayout:flowLayout]) {
        _choiceImageKeys = [NSMutableArray array];
        
        self.delegate = self;
        self.dataSource = self;
        self.pagingEnabled = YES;
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
    NSLog(@"Do something I guess");
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
    NSLog(@"Collection View Count: %lu", (unsigned long)_choiceImageKeys.count);
    return _choiceImageKeys.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.frame.size.width, self.frame.size.width + 50);
}

@end
