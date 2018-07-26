//
//  PaymentPluginViewController.m
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Juan sebastian Sanzone on 18/12/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

#import "PaymentPluginViewController.h"
#import "MercadoPagoSDKExamplesObjectiveC-Swift.h"

@interface PaymentPluginViewController ()

@property (strong, nonatomic) PXPaymentPluginNavigationHandler * paymentNavigationHandler;

@end

@implementation PaymentPluginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Plugin implementation.
- (UIView * _Nullable)renderWithStore:(PXCheckoutStore * _Nonnull)store theme:(id<PXTheme> _Nonnull)theme {
    return nil;
    //return self.view;
}

- (void)renderDidFinish {

    //[self.paymentNavigationHandler showLoading];
    
    double delay = 4.0;
    dispatch_time_t tm = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(tm, dispatch_get_main_queue(), ^(void) {
        
        //[self.paymentNavigationHandler hideLoading];
        
        CustomComponentText* component = [[CustomComponentText alloc] init];
        PXComponentAction* popeame = [[PXComponentAction alloc] initWithLabel:@"Continuar" action:^{
            //[self.paymentNavigationHandler cancel];
       }];
        PXComponentAction* printeaEnConsola = [[PXComponentAction alloc] initWithLabel:@"Intentar nuevamente" action:^{
            NSLog(@"print !!! action!!");
        }];
        
        PXBusinessResult* businessResult = [[PXBusinessResult alloc] initWithReceiptId:@"1879867544" status:PXBusinessResultStatusAPPROVED title:@"¡Listo! Ya pagaste en YPF" subtitle:nil icon:[UIImage imageNamed:@"ypf"] mainAction:nil secondaryAction:nil helpMessage:nil showPaymentMethod:YES statementDescription:nil imageUrl:@"https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/YPF.svg/2000px-YPF.svg.png" topCustomView:[component render] bottomCustomView: nil paymentStatus:@"" paymentStatusDetail:@""];
        [self.paymentNavigationHandler didFinishPaymentWithBusinessResult:businessResult];

       // [self.pluginNavigationHandler didFinishPaymentWithPaymentStatus:RemotePaymentStatusAPPROVED statusDetails:@"" receiptId:nil];
    });
}

- (void)navigationHandlerForPaymentPluginWithNavigationHandler:(PXPaymentPluginNavigationHandler *)navigationHandler {
    self.paymentNavigationHandler = navigationHandler;
}


-(void)createPaymentWithPluginStore:(PXCheckoutStore * _Nonnull)store handler:(id <PXPaymentFlowHandlerProtocol>)handler successWithBusinessResult:(void (^)(PXBusinessResult *))successWithBusinessResult successWithPaymentResult:(void (^)(PXPaymentPluginResult *))successWithPaymentResult {

    // Result with error
//        [handler showError];

    // Result with payment result
    PXPaymentPluginResult* result = [[PXPaymentPluginResult alloc] initWithStatus:@"approved" statusDetail:@"" receiptId: @""];
    successWithPaymentResult(result);


    // Result with business result
//    CustomComponentText* component = [[CustomComponentText alloc] init];
//    PXComponentAction* printeaEnConsola = [[PXComponentAction alloc] initWithLabel:@"Intentar nuevamente" action:^{
//        NSLog(@"print !!! action!!");
//    }];
//
//    PXBusinessResult* businessResult = [[PXBusinessResult alloc] initWithReceiptId:@"1879867544" status:PXBusinessResultStatusAPPROVED title:@"¡Listo! Ya pagaste en YPF" subtitle:nil icon:[UIImage imageNamed:@"ypf"] mainAction:nil secondaryAction:nil helpMessage:nil showPaymentMethod:YES statementDescription:nil imageUrl:@"https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/YPF.svg/2000px-YPF.svg.png" topCustomView:[component render] bottomCustomView: nil paymentStatus:@"" paymentStatusDetail:@""];
//    successWithBusinessResult(businessResult);
}
@end
