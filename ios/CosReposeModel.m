//
//  CosReposeModel.m
//  GeekUpload
//
//  Created by hl on 2021/1/28.
//

#import "CosReposeModel.h"

@implementation ReposeModel

@end

@implementation CosReponseModel

@end

@implementation CosReponseDataModel

@end

@implementation GeekUploadConfig

+ (instancetype) initWidthConfig:(NSDictionary *)dic {
  GeekUploadConfig *config = [[GeekUploadConfig alloc] init];
  if (config) {
    config.secretId = [dic valueForKey:@"tmpSecretId"];
    config.secretKey = [dic valueForKey:@"tmpSecretKey"];
    config.bucketName = [dic valueForKey:@"bucketName"];
    config.bucketKey = [dic valueForKey:@"dir"];
    config.bucketToken = [dic valueForKey:@"sessionToken"];
    config.region = [dic valueForKey:@"regionName"];
    config.startDate = [dic valueForKey:@"startTime"];
    config.experationDate = [dic valueForKey:@"expiredTime"];
  }
  return config;
}

@end


