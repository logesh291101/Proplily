import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../utils/preferences.dart';

class RemoteConfigServices {

  String android_version = "";
  String androidupdate_reason = "";
  String appstore_url = "";
  String force_update = "";
  String ios_version = "";
  String iosupdate_reason = "";
  String live_url = "";
  String playstore_url = "";


  
  Future<void> setupRemoteConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: Duration(seconds:10),
        minimumFetchInterval: Duration(minutes:5),
      ),
    );
    await remoteConfig.setDefaults({
      "live_url": "",
      "playstore_url": "",
      "appstore_url": "",
      "android_version": "",
      "ios_version": "",
      "force_update": "",
      "androidupdate_reason": "",
      "iosupdate_reason": ""
    });

    await remoteConfig.fetchAndActivate();
    
    live_url= remoteConfig.getString("live_url");
    playstore_url= remoteConfig.getString("playstore_url");
    appstore_url= remoteConfig.getString("appstore_url");
    android_version= remoteConfig.getString("android_version");
    ios_version= remoteConfig.getString("ios_version");
    force_update= remoteConfig.getString("force_update");
    androidupdate_reason= remoteConfig.getString("androidupdate_reason");
    iosupdate_reason= remoteConfig.getString("iosupdate_reason");
    
    await Prefs.setString('android_version', android_version);
    await Prefs.setString('appstore_url', appstore_url);
    await Prefs.setString('force_update', force_update);
    await Prefs.setString('ios_version', ios_version);
    await Prefs.setString('live_url', live_url);
    await Prefs.setString('playstore_url', playstore_url);
    await Prefs.setString('androidupdate_reason', androidupdate_reason);
    await Prefs.setString('iosupdate_reason', iosupdate_reason);
  }
}
