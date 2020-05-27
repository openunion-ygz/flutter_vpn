#import "FlutterVpnPlugin.h"
#import <SangforSDK/SFMobileSecuritySDK.h>
//@interface FlutterVpnPlugin()<SFAuthResultDelegate>
//@property (readwrite,copy,nonatomic) FlutterResult __result;

//@end

@implementation FlutterVpnPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_vpn"
            binaryMessenger:[registrar messenger]];
  FlutterVpnPlugin* instance = [[FlutterVpnPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
   /**
      一般场景SDK的模式为SFSDKModeSupporVpnSandbox，即同时支持VPN和沙箱功能。
      需要设置主应用flags，如果需要外部设置沙箱策略需要设置SFSDKFlagsSupportManagePolicy。
      多应用场景，即一个主应用，多个子应用，所有应用需要开启AppGroup功能且保证groupid一致，同时设置groupid包括sfshare后缀，例如group.com.***.sfshare
        */
   [[SFMobileSecuritySDK sharedInstance] initSDK:SFSDKModeSupportVpn
                                                  flags:SFSDKFlagsHostApplication|SFSDKFlagsSupportManagePolicy
                                                  extra:nil];
   [[SFMobileSecuritySDK sharedInstance] setAuthResultDelegate:self];

}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if(!self.__result){
        self.__result = result;
                           }
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if([@"initSDK" isEqualToString:call.method]){
  result(YES);
  }else if([@"startPrimaryAuth" isEqualToString:call.method]){
    NSString * vpn_server_url = call.arguments[@"vpn_path_key"];
    NSString * token_str = call.arguments[@"token_key"];
    NSLog(@"startPrimaryAuth ===",vpn_server_url);
      NSLog(@"startPrimaryAuth ===",token_str);
    [[SFMobileSecuritySDK sharedInstance] startPasswordAuth:vpn_server_url userName:token_str password:@""];
   }else if([@"vpnLogout" isEqualToString:call.method]){
    [[SFMobileSecuritySDK sharedInstance] cancelAuth];
    result(YES);
     }else {
    result(FlutterMethodNotImplemented);
  }
}

/**
         认证成功
         */
        - (void)onAuthSuccess:(BaseMessage *)msg
        {
            self.__result(YES);
            NSLog(@"AuthViewController onLoginSuccess");
        }

        #pragma mark - SFAuthResultDelegate
        /**
         认证失败

         @param msg 错误信息
         */
        - (void)onAuthFailed:(BaseMessage *)msg
        {
            self.__result(NO);
            NSLog(@"AuthViewController onLoginFailed:%@", msg);
        }

@end
