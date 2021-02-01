//
//  GeekUploadUtil.m
//  GeekUpload
//
//  Created by hl on 2021/1/28.
//

#import "GeekUploadUtil.h"
#import <AFNetworking/AFNetworking.h>
#import "CosReposeModel.h"
#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>
#import "Util.h"

static GeekUploadUtil *instance = nil;

@interface GeekUploadUtil ()<QCloudSignatureProvider, QCloudCredentailFenceQueueDelegate>

@property (nonatomic, copy) NSString *baseUrl;

@property (nonatomic, copy) NSString *token;

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic) QCloudCredentailFenceQueue* credentialFenceQueue;

@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSString *bucketName;
@property (nonatomic, copy) NSString *bucketKey;
@property (nonatomic, copy) NSString *secretID;
@property (nonatomic, copy) NSString *secretKey;
@property (nonatomic, copy) NSString *secretToken;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *experationDate;

@end

@implementation GeekUploadUtil

+ (instancetype) shard {
    static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
       if (!instance) {
           instance = [[GeekUploadUtil alloc] init];
           instance.manager = [AFHTTPSessionManager manager];
           instance.bucketName = @"test-1257124244";
           instance.region = @"ap-chengdu";
           [instance configCos];
       }
   });
   return instance;
}

- (void) cosConfigWith:(NSString *)secretId
             secretKey:(NSString *)key
            bucketName:(NSString *)bucketName
             bucketKey:(NSString *)bucketKey
                region:(NSString *)region
                sToken:(NSString *)token
              tartDate:(NSString *)sDate
        experationDate:(NSString *)experationDate {
    self.bucketName = bucketName;
    self.bucketKey = bucketKey;
    self.secretID = secretId;
    self.secretKey = key;
    self.secretToken = token;
    self.startDate = [Util convert:sDate];
    self.experationDate = [Util convert:experationDate];
}

- (void) configCos {
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = self.region; // @"ap-chengdu";
    // 使用 HTTPS
    endpoint.useHTTPS = true;
    configuration.endpoint = endpoint;
    configuration.signatureProvider = self;
    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:
      configuration];
    self.credentialFenceQueue = [QCloudCredentailFenceQueue new];
    self.credentialFenceQueue.delegate = self;
}

- (void) signatureWithFields:(QCloudSignatureFields*)fileds
                   request:(QCloudBizHTTPRequest*)request
                urlRequest:(NSMutableURLRequest*)urlRequst
                 compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock
{
    [self.credentialFenceQueue performAction:^(QCloudAuthentationCreator *creator,
          NSError *error) {
          if (error) {
              continueBlock(nil, error);
          } else {
              QCloudSignature* signature =  [creator signatureForData:urlRequst];
              continueBlock(signature, nil);
          }
      }];
}

- (void) fenceQueue:(QCloudCredentailFenceQueue * )queue requestCreatorWithContinue:(QCloudCredentailFenceQueueContinue)continueBlock
{
    QCloudCredential* credential = [QCloudCredential new];
    credential.secretID = self.secretID;
    credential.secretKey = self.secretKey;
    credential.token = self.secretToken;
    credential.startDate =  self.startDate; // 单位是秒
    credential.experationDate =  self.experationDate;
    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc]
       initWithCredential:credential];
   continueBlock(creator, nil);
}

- (void) uploadFile:(NSString *)path
           fileName:(NSString *)fileName
           progress:(UploadProgress)progress
             result:(UploadResult)result   {
    QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    NSURL* url = [NSURL URLWithString: path];
    put.bucket = self.bucketName;
    put.object = [NSString stringWithFormat:@"%@/%@", self.bucketKey, fileName];
    put.body =  url;
    [put setSendProcessBlock:^(int64_t bytesSent,
                               int64_t totalBytesSent,
                               int64_t totalBytesExpectedToSend) {
        if (progress) {
          progress(@{
              @"totalBytesSent": @(totalBytesSent),
              @"bytesSent":@(bytesSent),
              @"totalBytesExpectedToSend":@(totalBytesExpectedToSend),
            });
        }
    }];
    // 监听上传结果
    [put setFinishBlock:^(QCloudUploadObjectResult *outputObject, NSError *error) {
        if (result) {
            result(outputObject.location, error);
        }
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
}


@end
