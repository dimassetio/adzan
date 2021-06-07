import 'dart:async';
import 'dart:math';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import './models/prayer_time.dart';
import './models/constant.dart';
import 'LocalNotifyManager.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:audioplayers/audioplayers.dart';
// import 'package:audioplayers/src/audio_cache.dart';
// import 'package:audio_service/audio_service.dart';
// import 'package:date_time_picker/date_time_picker.dart';
// import 'package:assets_audio_player/assets_audio_player.dart';

void main() {
  runApp(MaterialApp(
    title: "Adzan Reminder",
    debugShowCheckedModeBanner: false,
    home:
        // AudioServiceWidget(
        //   child:
        HomeScreen(),
    // )
  ));
}

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

// AudioCache audioCache = new AudioCache();
// AudioPlayer audioPlayer = AudioPlayer();

class HomeScreenState extends State<HomeScreen> {
  double seconds;
  var lat;
  var long;
  String address;
  bool isOn = false;
  // AudioPlayer audioPlayer;
  // String durasi = "00:00:00";

  // AudioPlayerState audioPlayerState = AudioPlayerState.PAUSED;
  // AudioCache audioCache;
  String path = 'adzan.mp3';

  // final assetsAudioPlayer = AssetsAudioPlayer();

  // AudioPlayer adzann = audioCache;

  _currentTime() {
    return "${DateTime.now().hour} : ${DateTime.now().minute} : ${DateTime.now().second}  ";
  }

  _currentDate() {
    return "${DateTime.now().day} - ${DateTime.now().month} - ${DateTime.now().year}  ";
  }

  @override
  void initState() {
    super.initState();
    getPrayerTimes();
    Timer.periodic(Duration(seconds: 1), (Timer timer) => setState(() {}));
    AndroidAlarmManager.initialize();
    localNotifyManager.setOnNotificationReceive(onNotificationReceive);
    localNotifyManager.setOnNotificationClick(onNotificationClick);
  }

  onNotificationReceive(ReceiveNotification notification) {
    print('Notification Received: ${notification.id}');
  }

  onNotificationClick(String payload) {
    print('Payload $payload');
  }

  List<String> _prayerTimes = [];
  List<String> _prayerNames = [];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25))),
                child: Column(
                  children: [
                    Text(
                      _currentTime(),
                      style: TextStyle(color: Colors.white, fontSize: 32),
                    ),
                    Text(
                      _currentDate(),
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ],
                )),
            Container(
                margin: EdgeInsets.only(top: 20),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _prayerNames.length,
                    itemBuilder: (context, index) {
                      return Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                  width: 100,
                                  child: Text(_prayerNames[index],
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.green[900],
                                      ))),
                              Container(
                                width: 100,
                                child: Text(
                                  _prayerTimes[index],
                                  style: TextStyle(
                                      color: Colors.green[900],
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ));
                    })),
            FlatButton.icon(
                onPressed: () {
                  getLocation().then((value) {
                    setState(() {
                      getPrayerTimes();
                    });
                  });
                },
                icon: Icon(
                  Icons.location_on,
                  color: Colors.green,
                ),
                label: Text(address ?? "Cari Lokasi")),
            FlatButton(
                onPressed: () {
                  setState(() {
                    notif();
                  });
                },
                child: Text("Notif")),
            Switch(
                value: isOn,
                onChanged: (value) async {
                  setState(() {
                    isOn = value;
                  });
                  var now = DateTime.now();
                  var alarmId = Random().nextInt(pow(2, 20).toInt());
                  if (isOn == true) {
                    await AndroidAlarmManager.oneShotAt(
                      // await AndroidAlarmManager.oneShot(
                      //   Duration(seconds: 10),
                      DateTime(now.year, now.month, now.day, 08, 34, 00),
                      alarmId,
                      // _playsound,
                      // localNotifyManager.showAlarm(),
                      notif,
                      exact: true,
                      alarmClock: true,
                      wakeup: true,
                    );
                    // AudioService.connect();
                    // AudioService.play();
                  } else {
                    AndroidAlarmManager.cancel(alarmId);
                    _stopsound();
                    // localNotifyManager.player.stop();
                  }
                }),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    icon: Icon(Icons.play_arrow),
                    onPressed: () {
                      _playsound();
                    }),
                IconButton(
                    icon: Icon(Icons.stop),
                    onPressed: () {
                      _stopsound();
                    }),
              ],
            )
          ],
        ),
      ),
    );
  }

  AudioPlayer player = AudioPlayer();
  AudioCache cache = AudioCache();

  static Future<void> notif() async {
    localNotifyManager.showAlarm();
    // cache.play('adzan.mp3');
    // player = await cache.play('adzan.mp3');
  }

  void _playsound() async {
    player = await cache.play('adzan.mp3');
  }

  void _stopsound() {
    player?.stop();
  }

  getLocation() async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    lat = position.latitude;
    long = position.longitude;
    final coordinates = Coordinates(position.latitude, position.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    setState(() {
      address = addresses.first.subAdminArea;
    });
  }

  getPrayerTimes() {
    PrayerTime prayers = new PrayerTime();
    prayers.setTimeFormat(prayers.getTime24());
    prayers.setCalcMethod(prayers.getMWL());
    prayers.setAsrJuristic(prayers.getShafii());
    prayers.setAdjustHighLats(prayers.getAdjustHighLats());

    List<int> offsets = [-9, 0, 0, 0, 0, 0, 4];
    prayers.tune(offsets);

    var currentTime = DateTime.now();

    setState(() {
      _prayerTimes = prayers.getPrayerTimes(currentTime, lat ?? Constants.lat,
          long ?? Constants.long, Constants.timeZone);
      _prayerNames = prayers.getTimeNames();
    });
  }
}

Color hexToColor(String code) {
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}
