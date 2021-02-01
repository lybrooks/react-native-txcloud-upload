//
//  CosReposeModel.h
//  GeekUpload
//
//  Created by hl on 2021/1/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface CosReponseDataModel : NSObject

@property (nonatomic, copy) NSString *tmpSecretId;

@property (nonatomic, copy) NSString *tmpSecretKey;

@property (nonatomic, copy) NSString *sessionToken;

@end


@interface CosReponseModel : NSObject

@property (nonatomic, strong) CosReponseDataModel *credentials;

@property (nonatomic, copy) NSString *requestId;

@property (nonatomic, copy) NSString *expiration;

@property (nonatomic, copy) NSString *startTime;

@property (nonatomic, copy) NSString *expiredTime;

@property (nonatomic, copy) NSString *dir;

@end

@interface ReposeModel : NSObject

@property (nonatomic, assign) NSInteger code;

@property (nonatomic, strong) CosReponseModel *data;

@property (nonatomic, copy) NSString *msg;

@end

@interface GeekUploadConfig : NSObject
@property (nonatomic, copy) NSString *secretId;
@property (nonatomic, copy) NSString *secretKey;
@property (nonatomic, copy) NSString *bucketName;
@property (nonatomic, copy) NSString *bucketKey;
@property (nonatomic, copy) NSString *bucketToken;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSString *startDate;
@property (nonatomic, copy) NSString *experationDate;

+ (instancetype) initWidthConfig:(NSDictionary *)dic;


@end

NS_ASSUME_NONNULL_END
