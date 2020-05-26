package com.openunion.flutter_vpn;

import android.app.Activity;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.sangfor.sdk.SFMobileSecuritySDK;
import com.sangfor.sdk.base.SFAuthResultListener;
import com.sangfor.sdk.base.SFAuthType;
import com.sangfor.sdk.base.SFBaseMessage;
import com.sangfor.sdk.base.SFSDKFlags;
import com.sangfor.sdk.base.SFSDKMode;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterVpnPlugin */
public class FlutterVpnPlugin implements FlutterPlugin, MethodCallHandler, PluginRegistry.RequestPermissionsResultListener {
  private MethodChannel channel;
  private static final String TAG = "FlutterVpnPlugin";
  private static final String NAMESPACE = "plugins.openunion/vpn_plugin";
  private  PluginRegistry.Registrar registrar;
  private  Activity activity;
  private MethodChannel.Result mResult;
  private SFSDKMode mSDKMode;
  private Handler mHandler;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_vpn");
    channel.setMethodCallHandler(this);
    FlutterEngine flutterEngine = flutterPluginBinding.getFlutterEngine();
    io.flutter.embedding.engine.plugins.PluginRegistry registry = flutterEngine.getPlugins();
    this.registrar = registrar;
    this.activity = registrar.activity();
  }
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_vpn");
//    FlutterVpnPlugin instance = new FlutterVpnPlugin();
    channel.setMethodCallHandler(new FlutterVpnPlugin());
  }
  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    mResult = result;
    switch (call.method) {
      case "initSDK": {
        mHandler = new Handler(){
          @Override
          public void handleMessage(Message msg) {
            Log.e("handleMessage ===>",msg.what+"");
            if (msg.what == 1000){
              mResult.success(true);
            }else {
              mResult.success(false);
            }
          }
        };

        boolean isInitSucc = false;
        result.success(isInitSucc);
        break;
      }

      case "startPrimaryAuth": {
        String vpnPath = call.argument(Constants.PARAM_KEY_VPN);
        String token = call.argument(Constants.PARAM_KEY_TOKEN);
        Log.e("vpnPath ==>", vpnPath);
        Log.e("token ==>", token);
        SFMobileSecuritySDK.getInstance().startPasswordAuth(vpnPath, token,"");
        /**
         * 设置认证回调,认证结果在SFAuthResultListener的onAuthSuccess、onAuthFailed、onAuthProgress中返回
         * 如果不设置，将接收不到认证结果
         */
        Message msg = mHandler.obtainMessage();
        SFMobileSecuritySDK.getInstance().setAuthResultListener(new SFAuthResultListener() {
          @Override
          public void onAuthSuccess(SFBaseMessage sfBaseMessage) {
            Log.e("onAuthSuccess ===>",""+sfBaseMessage.mErrStr+" code :"+sfBaseMessage.mErrCode);
//            mResult.success(true);
            msg.what = 1000;
            mHandler.sendMessage(msg);
          }

          @Override
          public void onAuthFailed(SFAuthType sfAuthType, SFBaseMessage sfBaseMessage) {
            Log.e("onAuthFailed ===>",""+sfBaseMessage.mErrStr+" code :"+sfBaseMessage.mErrCode);
//            mResult.success(false);
            msg.what = 2000;
            mHandler.sendMessage(msg);
          }

          @Override
          public void onAuthProgress(SFAuthType sfAuthType, SFBaseMessage sfBaseMessage) {

          }
        });
        break;
      }

      case "vpnLogout": {
        SFMobileSecuritySDK.getInstance().logout();
        result.success(null);
        break;
      }
      case "getPlatformVersion": {
        result.success("Android " + android.os.Build.VERSION.RELEASE);
      }

      default: {
        result.notImplemented();
        break;
      }
    }
  }

  private void initSDK(){
    //只使用VPN功能场景
    SFSDKMode sdkMode = SFSDKMode.MODE_VPN;                 //表明启用VPN安全接入功能,详情参考集成指导文档
//        只使用安全沙箱功能场景
//        SFSDKMode sdkMode = SFSDKMode.MODE_SANDBOX;             //表明启用安全沙箱功能,详情参考集成指导文档
//        同时使用VPN功能+安全沙箱功能场景
//        SFSDKMode sdkMode = SFSDKMode.MODE_VPN_SANDBOX;         //表明同时启用VPN功能+安全沙箱功能,详情参考集成指导文档
    int sdkFlags =  SFSDKFlags.FLAGS_HOST_APPLICATION;      //表明是单应用或者是主应用
    sdkFlags |= SFSDKFlags.FLAGS_VPN_MODE_TCP;              //表明使用VPN功能中的TCP模式
    SFMobileSecuritySDK.getInstance().initSDK(this.activity, sdkMode, sdkFlags, null);//初始化SDK
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    return false;
  }
}
