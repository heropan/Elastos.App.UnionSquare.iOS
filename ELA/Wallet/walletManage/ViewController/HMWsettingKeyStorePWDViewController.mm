//
//  HMWsettingKeyStorePWDViewController.m
//  ELA
//
//  Created by 韩铭文 on 2019/1/3.
//  Copyright © 2019 HMW. All rights reserved.
//

#import "HMWsettingKeyStorePWDViewController.h"
#import "HMWCopyKeyStoreViewController.h"
#import <Cordova/CDV.h>
#import "ELWalletManager.h"

@interface HMWsettingKeyStorePWDViewController ()
    @property (weak, nonatomic) IBOutlet UITextField *keySPWDTextField;

    @property (weak, nonatomic) IBOutlet UIButton *confirmTheExportButton;
    @property (weak, nonatomic) IBOutlet UITextField *againKeySPWDTextField;
    @property (weak, nonatomic) IBOutlet UIView *walletNameBGView;
@property (weak, nonatomic) IBOutlet UITextField *theWalletPasswordTextField;
@property (weak, nonatomic) IBOutlet UILabel *walletNameLabel;

@end

@implementation HMWsettingKeyStorePWDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self defultWhite];
    [self setBackgroundImg:@"asset_bg"];
    
    self.title=NSLocalizedString(@"导出Keystroe", nil);
    self.walletNameLabel.text=self.wallet.walletName;
    self.theWalletPasswordTextField.placeholder=NSLocalizedString(@"请输入钱包密码", nil);
    self.keySPWDTextField.placeholder=NSLocalizedString(@"请设置Keystore密码", nil);
     self.againKeySPWDTextField.placeholder=NSLocalizedString(@"请再次输入确认Keystore密码", nil);
    [self.confirmTheExportButton setTitle:NSLocalizedString(@"确认导出", nil) forState:UIControlStateNormal];
    self.theWalletPasswordTextField.secureTextEntry=YES;
    self.keySPWDTextField.secureTextEntry=YES;
    self.againKeySPWDTextField.secureTextEntry=YES;
    [[HMWCommView share]makeBordersWithView:self.confirmTheExportButton];
    [[HMWCommView share]makeTextFieldPlaceHoTextColorWithTextField:self.keySPWDTextField];
        [[HMWCommView share]makeTextFieldPlaceHoTextColorWithTextField:self.theWalletPasswordTextField];
     [[HMWCommView share]makeTextFieldPlaceHoTextColorWithTextField:self.againKeySPWDTextField];
    [[HMWCommView share]makeBordersWithView:self.walletNameBGView];
    [self.confirmTheExportButton addTarget:self action:@selector(confirmTheExportEvent) forControlEvents:UIControlEventTouchUpInside];
    self.keySPWDTextField.secureTextEntry=YES;
    self.againKeySPWDTextField.secureTextEntry=YES;
    self.theWalletPasswordTextField.secureTextEntry=YES;
    
}
-(void)confirmTheExportEvent{
    
    
    if ([[FLTools share]checkWhetherThePassword:self.theWalletPasswordTextField.text]) {
        return;
    }
    if ([[FLTools share]checkWhetherThePassword:self.keySPWDTextField.text]) {
        return;
    }
    if ([[FLTools share]checkWhetherThePassword:self.againKeySPWDTextField.text]) {
        return;
    }
    if (![self.keySPWDTextField.text isEqualToString:self.againKeySPWDTextField.text]) {
        [[FLTools share]showErrorInfo:NSLocalizedString(@"两次密码输入不一致", nil)];
        return;
    }
    
    
    CDVInvokedUrlCommand *mommand=[[CDVInvokedUrlCommand alloc]initWithArguments:@[self.wallet.masterWalletID,self.theWalletPasswordTextField.text,self.againKeySPWDTextField.text] callbackId:self.wallet.walletID className:@"Wallet" methodName:@"exportWalletWithKeystore"];
    
    
    
    
    CDVPluginResult *result= [[ELWalletManager share]exportWalletWithKeystore:mommand];
    NSString *staus=[NSString stringWithFormat:@"%@",result.status];
    if ([staus isEqualToString:@"1"]) {
        NSString *keyStoreString=result.message[@"success"];
        HMWCopyKeyStoreViewController *copyKeyStoreVC=[[HMWCopyKeyStoreViewController alloc]init];
        copyKeyStoreVC.keyStoreString=keyStoreString;
        copyKeyStoreVC.walletName=self.wallet.walletName;
        [self.navigationController pushViewController:copyKeyStoreVC animated:YES];
    }
   
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}

@end