//
//  SimpleVaultFormViewController.h
//  MercadoPagoSDKExamplesObjectiveC
//
//  Created by Maria cristina rodriguez on 4/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MercadoPagoSDK;

@interface SimpleVaultFormViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic) PaymentMethod *paymentMethod;

@end
