//
//  GeekUploadEmitter.m
//  GeekMathApp
//
//  Created by hl on 2021/1/28.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import "GeekUploadEmitter.h"

@implementation GeekUploadEmitter


@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"uploadProgress"];
}

-(void)startObserving {
  for (NSString *notifiName in [self supportedEvents]) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(geekUploadProgress:)
                                                 name:notifiName
                                               object:nil];
  }
}

-(void)stopObserving {
  // 在此移除通知
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"uploadProgress" object:nil];
}


-(void)geekUploadProgress:(NSNotification *)dictionary {
  NSDictionary *info = dictionary.userInfo;
  [self sendEventWithName:@"uploadProgress" body: info];
}

@end
