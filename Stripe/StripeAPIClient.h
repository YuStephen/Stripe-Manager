//
//  StripeAPIClient.h

//  Created by yuyang on 2019/3/6.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Stripe/Stripe.h>


@interface StripeAPIClient : NSObject<STPEphemeralKeyProvider>

/**
 初始化Stripe用户信息

 @param member 用户ID
 @param token 发起请求附带的Header信息里的userToken
 @return
 */
+ (instancetype)sharedAPIClientWithMemberId:(NSString *)member token:(NSString *)token;


/**
 STPEphemeralKeyProvider 代理方法，初始化后会自动调用

 @param apiVersion 当前API的版本
 @param completion 成功回调
 */
- (void)createCustomerKeyWithAPIVersion:(NSString *)apiVersion completion:(STPJSONResponseCompletionBlock)completion;

@end
