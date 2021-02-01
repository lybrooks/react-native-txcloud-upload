//
//  GeekUploadUtil.h
//  GeekUpload
//
//  Created by hl on 2021/1/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^UploadResult)(id result, NSError *error);
typedef void(^UploadProgress)(id progress);

@interface GeekUploadUtil : NSObject

+ (instancetype) shard;

- (void) cosConfigWith:(NSString *)secretId
             secretKey:(NSString *)key
            bucketName:(NSString *)bucketName
             bucketKey:(NSString *)bucketKey
                region:(NSString *)region
                sToken:(NSString *)token
              tartDate:(NSString *)sDate
        experationDate:(NSString *)experationDate;

- (void) uploadFile:(NSString *)filePath
           fileName:(NSString *)fileName
           progress:(UploadProgress)progress
             result:(UploadResult)result;
@end

NS_ASSUME_NONNULL_END
