import 'dart:convert';
import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../models/hash_videos_model.dart';
import '../models/videos_model.dart';
import '../repositories/hash_repository.dart' as hashRepo;
import '../repositories/video_repository.dart' as videoRepo;
import 'dashboard_controller.dart';

class HashVideosController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;
  GlobalKey<ScaffoldState> hashScaffoldKey;
  GlobalKey<FormState> formKey;
  PanelController pc = new PanelController();
  ScrollController scrollController;
  ScrollController hashScrollController;
  ScrollController videoScrollController;
  ScrollController userScrollController;
  bool showLoader = false;
  bool showLoadMore = true;
  bool showLoadMoreHashTags = true;
  bool showLoadMoreUsers = true;
  bool showLoadMoreVideos = true;
  String searchKeyword = '';
  DashboardController homeCon;
  var searchController = TextEditingController();
  BannerAd bannerAd;
  InterstitialAd _interstitialAd;
  String appId = '';
  String bannerUnitId = '';
  String screenUnitId = '';
  String videoUnitId = '';
  String bannerShowOn = '';
  String interstitialShowOn = '';
  String videoShowOn = '';
  int hashesPage = 2;
  int videosPage = 2;
  int usersPage = 2;
  HashVideosController() {
    getAds();
  }

  @override
  void initState() {
    scaffoldKey = new GlobalKey<ScaffoldState>();
    hashScaffoldKey = new GlobalKey<ScaffoldState>();
    formKey = new GlobalKey<FormState>();
    super.initState();
  }

  BannerAd createBannerAd(bannerUnitId) {
    return BannerAd(
      adUnitId: bannerUnitId,
      size: AdSize.banner,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }

  InterstitialAd createInterstitialAd(screenUnitId) {
    return InterstitialAd(
      adUnitId: screenUnitId,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event $event");
      },
    );
  }

  rewardedVideoAd(videoUnitId) {
    RewardedVideoAd.instance.listener = (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      if (event == RewardedVideoAdEvent.rewarded) {}
    };
    RewardedVideoAd.instance.load(adUnitId: videoUnitId);
  }

  Future<HashVideosModel> getData(page) {
    homeCon = videoRepo.homeCon.value;
    homeCon.userVideoObj.value['userId'] = 0;
    homeCon.userVideoObj.value['videoId'] = 0;
    homeCon.userVideoObj.notifyListeners();
    homeCon.notifyListeners();
    setState(() {
      showLoadMoreHashTags = true;
      showLoadMoreUsers = true;
      showLoadMoreVideos = true;
      hashesPage = 2;
      usersPage = 2;
      videosPage = 2;
    });
    showLoader = true;
    scrollController = new ScrollController();
    hashRepo.getData(page, searchKeyword).then((value) {
      showLoader = false;
      if (value.videos.length == value.totalRecords) {
        showLoadMore = false;
      }
      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          if (value.videos.length != value.totalRecords && showLoadMore) {
            page = page + 1;
            getData(page);
          }
        }
      });
    });
  }

  Future<HashVideosModel> getHashData(page, hash) {
    homeCon = videoRepo.homeCon.value;
    homeCon.userVideoObj.value['userId'] = 0;
    homeCon.userVideoObj.value['videoId'] = 0;
    homeCon.userVideoObj.notifyListeners();
    homeCon.notifyListeners();
    setState(() {});
    showLoader = true;
    scrollController = new ScrollController();
    hashRepo.getHashData(page, hash).then((value) {
      if (value != null) {
        showLoader = false;
        if (value.videos.length == value.totalRecords) {
          showLoadMore = false;
        }
        scrollController.addListener(() {
          if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
            if (value.videos.length != value.totalRecords && showLoadMore) {
              page = page + 1;
              getHashData(page, hash);
            }
          }
        });
      }
    });
  }

  Future<HashVideosModel> getHashesData(searchKeyword) {
    print("getHashesData $hashesPage $showLoadMoreHashTags");
    if (showLoadMoreHashTags) {
      homeCon = videoRepo.homeCon.value;
      homeCon.userVideoObj.value['userId'] = 0;
      homeCon.userVideoObj.value['videoId'] = 0;
      homeCon.userVideoObj.notifyListeners();
      homeCon.notifyListeners();
      setState(() {});
      showLoader = true;
      hashScrollController = new ScrollController();
      hashRepo.getHashesData(hashesPage, searchKeyword).then((value) {
        if (value != null) {
          showLoader = false;
          print("value.length");
          print(value.length);
          if (value.length == 0) {
            showLoadMoreHashTags = false;
          }
          /*hashScrollController.addListener(() {
            if (hashScrollController.position.pixels == hashScrollController.position.maxScrollExtent - 100) {
              print("Scrolls Hash 1");
              print(hashScrollController.position.pixels + hashScrollController.position.maxScrollExtent);
              if (showLoadMoreHashTags) {
                getHashesData(searchKeyword);
                setState(() {
                  hashesPage++;
                });
              }
            }
          });*/
        }
      });
    }
  }

  Future<List<Video>> getUsersData(searchKeyword) {
    print("getUsersData $usersPage $showLoadMoreUsers");
    if (showLoadMoreHashTags) {
      homeCon = videoRepo.homeCon.value;
      homeCon.userVideoObj.value['userId'] = 0;
      homeCon.userVideoObj.value['videoId'] = 0;
      homeCon.userVideoObj.notifyListeners();
      homeCon.notifyListeners();
      setState(() {});
      showLoader = true;
      userScrollController = new ScrollController();
      hashRepo.getUsersData(usersPage, searchKeyword).then((value) {
        if (value != null) {
          showLoader = false;
          if (value.length == 0) {
            showLoadMoreUsers = false;
          }
          /*userScrollController.addListener(() {
            if (userScrollController.position.pixels == userScrollController.position.maxScrollExtent - 100) {
              if (showLoadMoreUsers) {
                usersPage++;
                getHashData(usersPage, searchKeyword);
              }
            }
          });*/
        }
      });
    }
  }

  Future<List<Videos>> getVideosData(searchKeyword) {
    print("getVideosData $videosPage $showLoadMoreVideos");
    if (showLoadMoreVideos) {
      homeCon = videoRepo.homeCon.value;
      homeCon.userVideoObj.value['userId'] = 0;
      homeCon.userVideoObj.value['videoId'] = 0;
      homeCon.userVideoObj.notifyListeners();
      homeCon.notifyListeners();
      setState(() {});
      showLoader = true;
      videoScrollController = new ScrollController();
      hashRepo.getVideosData(videosPage, searchKeyword).then((value) {
        if (value != null) {
          showLoader = false;
          if (value.length > 0) {
            showLoadMoreVideos = false;
          }
          /*videoScrollController.addListener(() {
            if (videoScrollController.position.pixels == videoScrollController.position.maxScrollExtent - 100) {
              if (showLoadMoreVideos) {
                videosPage++;
                getHashData(videosPage, searchKeyword);
              }
            }
          });*/
        }
      });
    }
  }

  Future<HashVideosModel> getSearchData(page) {
    print("getSearchData");
    homeCon = videoRepo.homeCon.value;
    homeCon.userVideoObj.value['userId'] = 0;
    homeCon.userVideoObj.value['videoId'] = 0;
    homeCon.userVideoObj.notifyListeners();
    homeCon.notifyListeners();

    showLoader = true;
    scrollController = new ScrollController();
    hashRepo.getSearchData(page, searchKeyword).then((value) {
      if (value != null) {
        showLoader = false;
        if (value.hashTags.length < 10) {
          print("Hash 10");
          print(value.hashTags.length);
          setState(() {
            showLoadMoreHashTags = false;
          });
        } else {
          print("Hash 11");
          print(value.hashTags.length);
          hashScrollController = new ScrollController();
          hashScrollController.addListener(() {
            print("Scrolls Hash  1");
            print("${hashScrollController.position.pixels} + ${hashScrollController.position.maxScrollExtent}");
            if (hashScrollController.position.pixels >= hashScrollController.position.maxScrollExtent - 100) {
              print("Scrolls Hash 2");
              print("${hashScrollController.position.pixels} + ${hashScrollController.position.maxScrollExtent - 100}");
              print("showLoadMoreHashTags");
              print(showLoadMoreHashTags);
              if (showLoadMoreHashTags) {
                getHashesData(searchKeyword);
                setState(() {
                  hashesPage++;
                });
              }
            }
          });
        }
        if (value.users.length < 10) {
          setState(() {
            showLoadMoreUsers = false;
          });
        } else {
          userScrollController = new ScrollController();
          userScrollController.addListener(() {
            if (userScrollController.position.pixels >= userScrollController.position.maxScrollExtent - 100) {
              if (showLoadMoreUsers) {
                getUsersData(searchKeyword);
                setState(() {

                usersPage++;
                });
              }
            }
          });
        }
        if (value.videos.length < 10) {
          setState(() {
            showLoadMoreVideos = false;
          });
        } else {
          videoScrollController = new ScrollController();
          videoScrollController.addListener(() {
            if (videoScrollController.position.pixels >= videoScrollController.position.maxScrollExtent - 100) {
              if (showLoadMoreVideos) {
                getVideosData(searchKeyword);
                setState(() {

                videosPage++;
                });
              }
            }
          });
        }
      }
    });
  }

  Future<void> getAds() {
    hashRepo.getAds().then((value) {
      if (value != null) {
        var response = json.decode(value);
        appId = Platform.isAndroid ? response['android_app_id'] : response['ios_app_id'];
        bannerUnitId = Platform.isAndroid ? response['android_banner_app_id'] : response['ios_banner_app_id'];
        screenUnitId = Platform.isAndroid ? response['android_interstitial_app_id'] : response['ios_interstitial_app_id'];
        videoUnitId = Platform.isAndroid ? response['android_video_app_id'] : response['ios_video_app_id'];
        bannerShowOn = response['banner_show_on'];
        interstitialShowOn = response['interstitial_show_on'];
        videoShowOn = response['video_show_on'];

        if (appId != "") {
          FirebaseAdMob.instance.initialize(appId: appId);

          if (bannerShowOn.indexOf("3") > -1) {
            bannerAd ??= createBannerAd(bannerUnitId);
            bannerAd
              ..load()
              ..show();
          }

          if (interstitialShowOn.indexOf("3") > -1) {
            _interstitialAd?.dispose();
            _interstitialAd = createInterstitialAd(screenUnitId)
              ..load()
              ..show();
          }

          if (videoShowOn.indexOf("3") > -1) {
            rewardedVideoAd(videoUnitId);
            RewardedVideoAd.instance?.show();
          }
        }
      }
    });
  }
}
