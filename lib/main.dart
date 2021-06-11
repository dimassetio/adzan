import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:iling_adzan/alarm_manager.dart';

import 'views/jam.dart';
import 'views/jadwal_sholat.dart';

import 'package:iling_adzan/audio_player.dart';
// import 'package:iling_adzan/alarm_manager.dart';

import 'package:audio_service/audio_service.dart';
// import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (Timer timer) => setState(() {}));
    AndroidAlarmManager.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AudioServiceWidget(
        child: Scaffold(
          body: Stack(children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      colors: [Colors.green, Colors.lightGreen],
                      end: Alignment.bottomCenter)),
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[Jam(), Jadwal(), Audio(), Alarm()])
          ]),
        ),
      ),
    );
  }
}
