//
//  LTVMediaPicker.m
//
//  Created by Lotheve on 18/7/29.
//  Copyright (c) 2015年 Lotheve. All rights reserved.
//

#import "LTVMediaPicker.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/PHPhotoLibrary.h>

static NSString *const kAlbumNotAllowedMessage = @"请在iPhone的“设置-隐私”选项中，允许应用程序访问你的相册";
static NSString *const kCameraNotAllowedMessage = @"请在iPhone的“设置-隐私”选项中，允许应用程序访问你的相机";
static NSString *const kmMicroNotAllowedMessage = @"请在iPhone的“设置-隐私”选项中，允许应用程序访问你的麦克风";

@interface LTVMediaPicker ()

@property (nonatomic, strong) UIImagePickerController *picker;

@property (copy, nonatomic) LTVImagePickerDidFinishPickingImageBlock imagePickerDidFinishPickingBlock;
@property (copy, nonatomic) LTVImagePickerDidFinishPickingVideoBlock videoPickerDidFinishSuccessBlock;
@property (copy, nonatomic) LTVImagePickerDidFinishPickingVideoBlock videoPickerDidFinishFailBlock;

@property (nonatomic) NSString *savePath;

@property (nonatomic) LTVMeidaPickerType pickerType;

@property (nonatomic, weak) UIViewController *presentedViewController;

@end


@implementation LTVMediaPicker

+ (LTVMediaPicker*)shareInstance{
    static LTVMediaPicker *imgPickerController = nil;
    static dispatch_once_t onceTokenPickerController;
    dispatch_once(&onceTokenPickerController, ^{
        imgPickerController = [[LTVMediaPicker alloc] init];
    });
    return imgPickerController;
}

- (UIImagePickerController *)picker
{
    if (!_picker) {
        _picker = [[UIImagePickerController alloc] init];
        _picker.delegate = self;
        _picker.allowsEditing = NO;
    }
    return _picker;
}

- (void)imagePickerWithType:(LTVMeidaPickerType)type presentViewController:(UIViewController*)viewController finishBlock:(LTVImagePickerDidFinishPickingImageBlock)block{
    
    self.pickerType = type;
    self.imagePickerDidFinishPickingBlock = block;
    self.presentedViewController = viewController;
    
    if (type==LTVMediaPickerTypePhotoAlbum) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            [self alertWithMsg:@"对不起，您的设备不支持该功能"];
        }else{
            self.picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            self.picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            NSArray *availabelMedia = [UIImagePickerController availableMediaTypesForSourceType:_picker.sourceType];
            self.picker.mediaTypes = [NSArray arrayWithObject:availabelMedia[0]];
            [self showPikcer];
        }
    }else if(type==LTVMediaPickerTypePhotoCamera){
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [self alertWithMsg:@"对不起，您的设备不支持该功能"];
        }else{
            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            NSArray *availabelMedia = [UIImagePickerController availableMediaTypesForSourceType:_picker.sourceType];
            self.picker.mediaTypes = [NSArray arrayWithObject:availabelMedia[0]];
            [self showPikcer];
        }
    }
}

- (void)videoPickerWithType:(LTVMeidaPickerType)type savePath:(NSString*)path presentViewController:(UIViewController*)viewController successBlock:(LTVImagePickerDidFinishPickingVideoBlock)successBlock failedBlock:(LTVImagePickerDidFinishPickingVideoBlock)failBlock{
    
    self.pickerType = type;
    self.videoPickerDidFinishSuccessBlock = successBlock;
    self.videoPickerDidFinishFailBlock = failBlock;
    self.savePath = path;
    self.presentedViewController = viewController;
    
    if (type == LTVMediaPickerTypeVideoAlbum) {
        if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary]) {
            [self alertWithMsg:@"对不起，您的设备不支持该功能"];
        }else{
            self.picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            self.picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            NSArray *availabelMedia = [UIImagePickerController availableMediaTypesForSourceType:_picker.sourceType];
            self.picker.mediaTypes = [NSArray arrayWithObject:availabelMedia[1]];
            [self showPikcer];
        }
    }else if(type == LTVMediaPickerTypeVideoCamera) {
        if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            [self alertWithMsg:@"对不起，您的设备不支持该功能"];
        }else{
            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            self.picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
            NSArray *availabelMedia = [UIImagePickerController availableMediaTypesForSourceType:_picker.sourceType];
            self.picker.mediaTypes = [NSArray arrayWithObject:availabelMedia[1]];
            [self showPikcer];
        }
    }
}

#pragma mark- Private method

- (void)showPikcer
{
    if (self.pickerType == LTVMediaPickerTypePhotoAlbum || self.pickerType == LTVMediaPickerTypeVideoAlbum) {
        
        [self checkAlbumAuthStatusWithHandler:^(bool granted) {
            if (granted) {
                [self.presentedViewController presentViewController:self.picker animated:YES completion:nil];
            } else {
                [self alertWithMsg:kAlbumNotAllowedMessage];
            }
        }];
    }
    if (self.pickerType == LTVMediaPickerTypePhotoCamera || self.pickerType == LTVMediaPickerTypeVideoCamera) {
        [self checkCameraAuthStatusWithHandler:^(bool granted) {
            if (granted) {
                [self.presentedViewController presentViewController:self.picker animated:YES completion:nil];
            } else {
                [self alertWithMsg:kCameraNotAllowedMessage];
            }
        }];
     }
    if (self.pickerType == LTVMediaPickerTypeVideoCamera) {
        [self checkCameraAuthStatusWithHandler:^(bool granted) {
            if (granted) {
                [self checkAudioAuthStatusWithHandler:^(bool granted) {
                    if (granted) {
                        [self.presentedViewController presentViewController:self.picker animated:YES completion:nil];
                    } else {
                        [self alertWithMsg:kmMicroNotAllowedMessage];
                    }
                }];
            } else {
                [self alertWithMsg:kCameraNotAllowedMessage];
            }
        }];
    }
}

- (void)checkAlbumAuthStatusWithHandler:(void(^)(bool granted))handler
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        PHAuthorizationStatus auth = [PHPhotoLibrary authorizationStatus];
        if (auth == PHAuthorizationStatusAuthorized)
        {
            handler(YES);
        }
        else if (auth == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (status == PHAuthorizationStatusAuthorized) {
                         handler(YES);
                     } else {
                         handler(NO);
                     }
                 });
             }];
        }
        else
        {
            handler(NO);
        }
    }
}

- (void)checkCameraAuthStatusWithHandler:(void(^)(bool granted))handler
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(authStatus == AVAuthorizationStatusAuthorized)
        {
            handler(YES);
        }
        else if(authStatus == AVAuthorizationStatusNotDetermined)
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     handler(granted);
                 });
             }];
        }
        else
        {
            handler(NO);
        }
    }
}

- (void)checkAudioAuthStatusWithHandler:(void(^)(bool granted))handler
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(authStatus == AVAuthorizationStatusAuthorized)
    {
        handler(YES);
    }
    else if(authStatus == AVAuthorizationStatusNotDetermined)
    {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 handler(granted);
             });
         }];
    }
    else
    {
        handler(NO);
    }
}

- (void)URLToMp4:(NSURL*)mediaUrl savePath:(NSString*)savePath{
    
    if (!savePath) {
        if (self.videoPickerDidFinishSuccessBlock) {
            self.videoPickerDidFinishSuccessBlock(mediaUrl, nil);
        }
        [self dismissPicker];
        return;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:savePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:savePath error:nil];
    }
    NSURL *pathUrl = [NSURL fileURLWithPath:savePath];
    AVURLAsset * urlAsset = [[AVURLAsset alloc] initWithURL:mediaUrl options:nil];
    AVAssetExportSession *audioSession = [AVAssetExportSession exportSessionWithAsset:urlAsset presetName:AVAssetExportPreset640x480];
    audioSession.outputURL = pathUrl;
    audioSession.outputFileType = AVFileTypeQuickTimeMovie;
    [audioSession exportAsynchronouslyWithCompletionHandler:^{
        switch (audioSession.status) {
            case AVAssetExportSessionStatusUnknown:
                break;
            case AVAssetExportSessionStatusWaiting:
                break;
            case AVAssetExportSessionStatusExporting:
                break;
            case AVAssetExportSessionStatusCompleted: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.videoPickerDidFinishSuccessBlock) {
                        self.videoPickerDidFinishSuccessBlock(mediaUrl, savePath);
                    }
                    [self dismissPicker];
                });
            }
                break;
            case AVAssetExportSessionStatusFailed:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.videoPickerDidFinishFailBlock) {
                        self.videoPickerDidFinishFailBlock(mediaUrl, savePath);
                    }
                    [self dismissPicker];
                });
            }
                break;
            case AVAssetExportSessionStatusCancelled: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.picker dismissViewControllerAnimated:YES completion:nil];
                    if (self.videoPickerDidFinishFailBlock) {
                        self.videoPickerDidFinishFailBlock(mediaUrl, savePath);
                    }
                    [self dismissPicker];
                });
            }
                break;
            default:
                break;
        }
    }];
}

- (void)dismissPicker{
    [_picker dismissViewControllerAnimated:YES completion:nil];
    self.imagePickerDidFinishPickingBlock = nil;
    self.videoPickerDidFinishSuccessBlock = nil;
    self.videoPickerDidFinishFailBlock = nil;
    
    _picker = nil;
    _pickerType = 0;
    _presentedViewController = nil;
    _savePath = nil;
}

- (void)alertWithMsg:(NSString *)msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancelAction];
    [self.presentedViewController presentViewController:alert animated:YES completion:nil];
}

#pragma mark- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    if (self.pickerType==LTVMediaPickerTypePhotoAlbum) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *thumbnail = [info objectForKey:UIImagePickerControllerEditedImage];
        if (self.imagePickerDidFinishPickingBlock) {
            self.imagePickerDidFinishPickingBlock(image, thumbnail);
        }
        [self dismissPicker];
    }else if(self.pickerType == LTVMediaPickerTypePhotoCamera){
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *thumbnail = [info objectForKey:UIImagePickerControllerEditedImage];
        if (self.imagePickerDidFinishPickingBlock) {
            self.imagePickerDidFinishPickingBlock(image, thumbnail);
        }
        [self dismissPicker];
    }else if(self.pickerType == LTVMediaPickerTypeVideoAlbum){
        NSURL *pathUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        [self URLToMp4:pathUrl savePath:self.savePath];
    }else if(self.pickerType == LTVMediaPickerTypeVideoCamera){
        NSURL *pathUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        [self URLToMp4:pathUrl savePath:self.savePath];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    if (self.imagePickerDidFinishPickingBlock) {
        self.imagePickerDidFinishPickingBlock(nil, nil);
    }
    if (self.videoPickerDidFinishSuccessBlock) {
        self.videoPickerDidFinishSuccessBlock(nil, nil);
    }
    [self dismissPicker];
}

@end
