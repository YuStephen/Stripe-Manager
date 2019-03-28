//
//  StripeManager.m
//
//  调起Stripe管理类
//
//  Created by yuyang on 2019/3/6.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "StripeManager.h"
#import <Stripe/Stripe.h>
#import "StripeAPIClient.h"
#import <React/RCTEventDispatcher.h>

@interface StripeManager()<STPPaymentMethodsViewControllerDelegate>
//选中的卡
@property (nonatomic, strong) STPCard *card;

@end

@implementation StripeManager

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(jumpToStripePayMethodViewControllerWithCustomerId:(NSString*)memberId userToken:(NSString *)token){
    dispatch_async(dispatch_get_main_queue(), ^{
      
      STPPaymentConfiguration *config = [STPPaymentConfiguration sharedConfiguration];
      config.additionalPaymentMethods = STPPaymentMethodTypeNone;
      config.requiredBillingAddressFields = STPBillingAddressFieldsNone;
      
      StripeAPIClient *manager = [StripeAPIClient sharedAPIClientWithMemberId:memberId
                                                                        token:token];
      
      STPCustomerContext *customerContext = [[STPCustomerContext alloc] initWithKeyProvider:manager];
      
      STPPaymentMethodsViewController *viewController = [[STPPaymentMethodsViewController alloc] initWithConfiguration:config
                                                                                                                 theme:STPTheme.defaultTheme
                                                                                                       customerContext:customerContext
                                                                                                              delegate:self];
      UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
      UIWindow *window = [[UIApplication sharedApplication].delegate window];
      UIViewController *topViewController = [window rootViewController];
      [topViewController presentViewController:nav animated:YES completion:nil];
    });
}

- (void)paymentMethodsViewControllerDidFinish:(STPPaymentMethodsViewController *)paymentMethodsViewController{
  
  /*卡信息
   <STPCard: 0x2805a8e00;
   stripeID = card_1EChQiJG1g10PFdz4i2Y2kPY;
   brand = Visa;
   last4 = 4242;
   expMonth = 2;
   expYear = 2020;
   funding = credit;
   country = US;
   currency = (null);
   dynamicLast4 = (null);
   isApplePayCard = NO;
   metadata = <redacted>;
   name = (null);
   address = <redacted>>
   */
  
  NSString *brand;
  if (self.card.brand == STPCardBrandVisa) {
    brand = @"Visa";
  }else if (self.card.brand == STPCardBrandJCB){
    brand = @"JCB";
  }else if (self.card.brand == STPCardBrandAmex){
    brand = @"Amex";
  }else if (self.card.brand == STPCardBrandMasterCard){
    brand = @"MasterCard";
  }else if (self.card.brand == STPCardBrandDiscover){
    brand = @"Discover";
  }else if (self.card.brand == STPCardBrandDinersClub){
    brand = @"DinersClub";
  }else if (self.card.brand == STPCardBrandUnionPay){
    brand = @"UnionPay";
  }else{
    brand = @"Unknown";
  }
  
  [self.bridge.eventDispatcher sendAppEventWithName:@"StripePay" body:@{@"CardId":self.card.stripeID,@"last4":self.card.last4, @"brand":brand}];
  
  [paymentMethodsViewController dismissWithCompletion:nil];
}

- (void)paymentMethodsViewControllerDidCancel:(STPPaymentMethodsViewController *)paymentMethodsViewController{
  [paymentMethodsViewController dismissWithCompletion:nil];
}


- (void)paymentMethodsViewController:(STPPaymentMethodsViewController *)paymentMethodsViewController didFailToLoadWithError:(NSError *)error{
  [paymentMethodsViewController dismissWithCompletion:nil];
}

- (void)paymentMethodsViewController:(STPPaymentMethodsViewController *)paymentMethodsViewController didSelectPaymentMethod:(id<STPPaymentMethod>)paymentMethod{
  self.card = paymentMethod;
}


@end
