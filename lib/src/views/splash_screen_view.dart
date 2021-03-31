import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pedantic/pedantic.dart';

import '../controllers/splash_screen_controller.dart';
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/video_repository.dart' as videoRepo;

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> {
  static const platform = const MethodChannel('com.flutter.epic/epic');
  String dataShared = "No Data";
  SplashScreenController _con;
  BuildContext context;
  SplashScreenState() : super(SplashScreenController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  printHashKeyOnConsoleLog() async {
    try {
      await platform.invokeMethod("printHashKeyOnConsoleLog");
    } catch (e) {
      print(e);
    }
  }

  void loadData() async {
    try {
      await _con.userUniqueId();
      userRepo.getCurrentUser().whenComplete(() {
        _con.initializeVideos().whenComplete(() {
          videoRepo.dataLoaded.addListener(() async {
            if (videoRepo.dataLoaded.value) {
              if (mounted) {
                if (userRepo.currentUser.value.token != '') {
                  _con.connectUserSocket();
                }
                unawaited(videoRepo.homeCon.value.preCacheVideos());
                printHashKeyOnConsoleLog();
                Navigator.of(context)
                    .pushReplacementNamed('/redirect-page', arguments: 0);
              }
            }
          });
        });
      });
    } catch (e) {
      print("catch");
      print(e.toString());
    }
  }

  DateTime currentBackPressTime;

  @override
  Widget build(BuildContext context) {
    setState(() => this.context = context);
    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();
        // Navigator.pop(context);
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          Fluttertoast.showToast(msg: "Tap again to exit an app.");
          return Future.value(false);
        }
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return Future.value(true);
      },
      child: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/images/Dunia_splashscreen2.png",
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
