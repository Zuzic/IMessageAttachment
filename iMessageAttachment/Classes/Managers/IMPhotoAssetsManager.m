//
//  IMPhotoAssetsManager.m
//  iMessageAttachment
//
//  Created by Mark Prutskiy on 4/6/17.
//  Copyright © 2017 HealthJoy. All rights reserved.
//

#import "IMPhotoAssetsManager.h"
#import <Photos/Photos.h>

@interface IMPhotoAssetsManager ()

@property(nonatomic, strong) PHFetchResult *assetsFetchResults;
@property(nonatomic, strong) PHCachingImageManager *imageManager;
@property(nonatomic, weak) UICollectionView *collectionView;

@end

@implementation IMPhotoAssetsManager

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView {
    self = [super init];
    
    if(self == nil)
        return nil;
    
    self.collectionView = collectionView;
    
    return self;
}

- (void)fetchAssets {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if(status == PHAuthorizationStatusAuthorized) {
            dispatch_async(dispatch_get_main_queue(), ^void()
                           {
                               PHFetchOptions *options = [PHFetchOptions new];
                               options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                               options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
                               self.assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
                               self.imageManager = [PHCachingImageManager new];
                               
                               [self.collectionView reloadData];
                           });
        }
    }];
}

- (NSUInteger)photoCount {
    return self.assetsFetchResults.count;
}

- (void)photoAtIndexPath:(NSIndexPath *)indexPath
              targetSize:(CGSize)targetSize
              completion:(void(^)(UIImage *image))completion {
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    
    PHImageRequestOptions* options = [PHImageRequestOptions new];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    if(targetSize.width == 0 && targetSize.height == 0) {
        targetSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    }
    
    [self.imageManager requestImageForAsset:asset
                                 targetSize:targetSize
                                contentMode:PHImageContentModeAspectFill
                                    options:options
                              resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                  completion(result);
                              }];
}

@end

