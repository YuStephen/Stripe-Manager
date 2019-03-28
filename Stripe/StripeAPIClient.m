//
//  StripeAPIClient.m

//  Stripe
//  用于获取用户密令
//
//  Created by yuyang on 2019/3/6.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "StripeAPIClient.h"
#import <Stripe/Stripe.h>

static StripeAPIClient *_manager = nil;

@interface StripeAPIClient()

@property (nonatomic, copy) NSString *memberId;
@property (nonatomic, copy) NSString *token;

@end

@implementation StripeAPIClient


+ (instancetype)sharedAPIClientWithMemberId:(NSString *)member token:(NSString *)token {
  if (!_manager) {
    _manager = [[StripeAPIClient alloc] init];
    _manager.memberId = member;
    _manager.token = token;
  }
  return _manager;
}

- (void)createCustomerKeyWithAPIVersion:(NSString *)apiVersion completion:(STPJSONResponseCompletionBlock)completion{
  
  NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
  
  //后台创建密令BaseURL
  NSString *urlString = @"";

  
  NSURL *url = [NSURL URLWithString:urlString];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
  request.HTTPMethod = @"POST";
  [request addValue:self.token forHTTPHeaderField:@"userToken"];
  [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"memberId":self.memberId}
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:nil];
  request.HTTPBody = jsonData;
  
  NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                             fromData:jsonData
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                      NSError *jsonError = nil;
                                                      id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                                      
                                                      if (httpResponse.statusCode == 200) {
                                                        
                                                        if ([json[@"status"] integerValue] == 200) {
                                                          completion(json[@"data"],nil);
                                                        }else{
                                                          NSString *message;
                                                          if (!json[@"message"] || [json[@"message"] isEqualToString:@""]) {
                                                            message = @"操作失败";
                                                          }else{
                                                            message = json[@"message"];
                                                          }
                                                          
                                                          UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                                                                         message:message
                                                                                                        delegate:self
                                                                                               cancelButtonTitle:@"OK"
                                                                                               otherButtonTitles:nil, nil];
                                                          [alert show];
                                                        }
                                                      }else{
                                                        
                                                        
                                                      }
                                                    }];
  [uploadTask resume];
  
}

@end
