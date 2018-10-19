//
//  LTVMediaPicker.h
//
//  Created by Lotheve on 18/7/29.
//  Copyright (c) 2018年 Lotheve. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LTVMeidaPickerType) {
    LTVMediaPickerTypePhotoAlbum    = 1,   //图片从相册中获取
    LTVMediaPickerTypePhotoCamera   = 2,   //图片从摄像头中获取
    LTVMediaPickerTypeVideoAlbum    = 3,   //视频从相册中获取
    LTVMediaPickerTypeVideoCamera   = 4    //视频从摄像头中获取
};

typedef void(^LTVImagePickerDidFinishPickingImageBlock)(UIImage *image, UIImage *thumbnail);
typedef void(^LTVImagePickerDidFinishPickingVideoBlock)(NSURL *mediaUrl, NSString *savePath);

@interface LTVMediaPicker : NSObject<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

/**
 * 单例类
 */
+ (LTVMediaPicker *)shareInstance;

/**
 *  照片获取
 *
 *  @param type          单例类型
 *  @param viewController 显示页面
 *  @param block          选择图片触发句柄
 */
- (void)imagePickerWithType:(LTVMeidaPickerType)type presentViewController:(UIViewController*)viewController finishBlock:(LTVImagePickerDidFinishPickingImageBlock)block;

/**
 *  视频获取
 *
 *  @param type          单例类型
 *  @param path           获取视频存放路径
 *  @param viewController 显示页面
 *  @param successBlock   存放视频成功触发句柄
 *  @param failBlock      存放视频失败触发句柄
 */
- (void)videoPickerWithType:(LTVMeidaPickerType)type savePath:(NSString*)path presentViewController:(UIViewController*)viewController successBlock:(LTVImagePickerDidFinishPickingVideoBlock)successBlock failedBlock:(LTVImagePickerDidFinishPickingVideoBlock)failBlock;

@end
