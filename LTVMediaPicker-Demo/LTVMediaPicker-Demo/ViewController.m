//
//  ViewController.m
//  LTVMediaPicker-Demo
//
//  Created by Lotheve on 2018/10/19.
//  Copyright © 2018 Lotheve. All rights reserved.
//

#import "ViewController.h"
#import "LTVMediaPicker.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)actionPickImageFromAlbum:(id)sender {
    
    [[LTVMediaPicker shareInstance] imagePickerWithType:LTVMediaPickerTypePhotoAlbum presentViewController:self finishBlock:^(UIImage *image, UIImage *thumbnail) {
        //do something with image
    }];
}

- (IBAction)actionPickImageFromCamera:(id)sender {
    [[LTVMediaPicker shareInstance] imagePickerWithType:LTVMediaPickerTypePhotoCamera presentViewController:self finishBlock:^(UIImage *image, UIImage *thumbnail) {
        //do something with image
    }];
}

- (IBAction)actionPickVideoFromAlbum:(id)sender {
    NSString *targetPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"video.mp4"];
    [[LTVMediaPicker shareInstance] videoPickerWithType:LTVMediaPickerTypeVideoAlbum savePath:targetPath presentViewController:self successBlock:^(NSURL *mediaUrl, NSString *savePath) {
        //do something with video
    } failedBlock:^(NSURL *mediaUrl, NSString *savePath) {
        //do something with video
    }];
}

- (IBAction)actionPickVideoFromCamera:(id)sender {
    NSString *targetPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"video.mp4"];
    [[LTVMediaPicker shareInstance] videoPickerWithType:LTVMediaPickerTypeVideoCamera savePath:targetPath presentViewController:self successBlock:^(NSURL *mediaUrl, NSString *savePath) {
        //do something with video
    } failedBlock:^(NSURL *mediaUrl, NSString *savePath) {
        //do something with video
    }];
}

@end
