import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_vpn/flutter_vpn.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final urlController = TextEditingController();
  final tokenController = TextEditingController();
  final vpnController = TextEditingController();
  String authState = "";

  @override
  void initState() {
    super.initState();
    initPlatformState();
    FlutterVpn.instance.initSDK();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterVpn.platformVersion;
      Fluttertoast.showToast(msg: platformVersion);
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin vpn Demo'),
        ),
        body: Center(
          child: new Column(
            children: <Widget>[
              RaisedButton(child: Text('vpn初始化'),onPressed: (){
//                FlutterVpn.instance.initSDK();
              },),
              Text('token验证登录'),
//              TextField(decoration: new InputDecoration(
//                  labelText: "请输入服务器url",
//                  contentPadding: const EdgeInsets.only(bottom:15.0)),keyboardType: TextInputType.text,controller: urlController,),
              TextField(decoration: new InputDecoration(
                  labelText: "请输入vpn地址",
                  contentPadding: const EdgeInsets.only(bottom:15.0)),keyboardType: TextInputType.text,controller: vpnController,),


              TextField(decoration: new InputDecoration(
                  labelText: "请输入token",
                  contentPadding: const EdgeInsets.only(bottom:15.0)),keyboardType: TextInputType.text,controller: tokenController,),
              RaisedButton(child: Text('登录'),onPressed: (){
//                String url = urlController.text;
                String token = tokenController.text;
                String vpn = vpnController.text;
                if(authState != ""){
                  setState(() {
                    authState:"";
                  });
                }
                FlutterVpn.instance.startPrimaryAuth(vpn, token).then((isAuth) {
                  print("vpn验证 ===>$isAuth");
                  String authStr;
                  if(isAuth){
                    Fluttertoast.showToast(msg: "vpn验证成功");
                    authStr = "vpn验证成功";
                  }else{
                    Fluttertoast.showToast(msg: "vpn验证失败！");
                    authStr = "vpn验证失败";
                  }
                  setState(() {
                    authState = authStr;
                  });

                });
              },),
              Text('token验证状态'),
              Text(authState),
            ],
          ),
        ),
      ),
    );
  }
}
