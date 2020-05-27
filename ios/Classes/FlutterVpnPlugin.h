#import <Flutter/Flutter.h>

@interface FlutterVpnPlugin : NSObject<FlutterPlugin,SFAuthResultDelegate>

@property (readwrite,copy,nonatomic) FlutterResult __result;

@end
