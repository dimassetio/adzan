import 'package:audio_service/audio_service.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'audio_player.dart';

_backgroundTaskEntrypoint() {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class Alarm extends StatefulWidget {
  @override
  _AlarmState createState() => _AlarmState();
}

void tes() {
  print('asdasd');
}

class _AlarmState extends State<Alarm> {
  static Future<void> start() async {
    await AudioService.connect();
    AudioService.play();
  }

  void alarm(isOn) async {
    var now = DateTime.now();
    var alarmId = Random().nextInt(pow(2, 20).toInt());
    if (isOn == true) {
      // await AndroidAlarmManager.oneShotAt(
      // DateTime(now.year, now.month, now.day, 08, 34, 00),
      await AndroidAlarmManager.oneShot(
        Duration(seconds: 10),
        alarmId,
        start,
        exact: true,
        alarmClock: true,
        wakeup: true,
      );
    } else {
      AndroidAlarmManager.cancel(alarmId);
    }
  }

  bool isOn = false;
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Switch(
            value: isOn,
            onChanged: (value) async {
              setState(() {
                isOn = value;
              });
              alarm(isOn);
            }));
  }
}
