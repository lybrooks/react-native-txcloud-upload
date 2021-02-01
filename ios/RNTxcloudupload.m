//
//  GeekUpload.m
//  GeekMathApp
//
//  Created by hl on 2021/1/28.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import "RNTxcloudupload.h"
#import "CosReposeModel.h"
#import "GeekUploadUtil.h"

@implementation RNTxcloudupload


RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}


RCT_EXPORT_METHOD(config:(NSDictionary *)cfg) {
  GeekUploadConfig *config = [GeekUploadConfig initWidthConfig:cfg];
  [[GeekUploadUtil shard] cosConfigWith:config.secretId
                              secretKey:config.secretKey
                             bucketName:config.bucketName
                              bucketKey:config.bucketKey
                                 region:config.region
                                 sToken:config.bucketToken
                               tartDate:config.startDate
                         experationDate:config.experationDate];
}

RCT_EXPORT_METHOD(uploadFile:(NSString *)file
                  fileName:(NSString *)fileName
                  cb:(RCTResponseSenderBlock)block) {
  [[GeekUploadUtil shard] uploadFile:file
                            fileName:fileName
                            progress:^(id progress) {
    [[NSNotificationCenter defaultCenter]
      postNotificationName:@"uploadProgress"
      object:nil
     userInfo: progress];
  } result:^(id  _Nonnull result, NSError * _Nonnull error) {
    if (block) {
      block(@[result ?: [NSNull null], error ?: [NSNull null] ]);
    }
  }];
}



@end
