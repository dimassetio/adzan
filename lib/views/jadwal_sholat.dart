import 'package:iling_adzan/models/constant.dart';
import 'package:iling_adzan/models/prayer_time.dart';
import 'package:flutter/material.dart';

class Jadwal extends StatefulWidget {
  @override
  _JadwalState createState() => _JadwalState();
}

class _JadwalState extends State<Jadwal> {
  void initState() {
    super.initState();
    getPrayerTimes();
  }

  List<String> _prayerTimes = [];
  List<String> _waktuSholat = [];
  List<String> _namaSholat = [];

  getPrayerTimes() {
    PrayerTime prayers = new PrayerTime();
    prayers.setTimeFormat(prayers.getTime24());
    prayers.setCalcMethod(prayers.getMWL());
    prayers.setAsrJuristic(prayers.getShafii());
    prayers.setAdjustHighLats(prayers.getAdjustHighLats());

    List<int> offsets = [-9, 0, 0, 0, 0, 0, 4];
    prayers.tune(offsets);

    String tz = "${DateTime.now().timeZoneOffset}";
    var timezone = double.parse(tz[0]);
    var currentTime = DateTime.now();

    setState(() {
      _prayerTimes = prayers.getPrayerTimes(
          currentTime, Constants.lat, Constants.long, timezone);
      _waktuSholat = [
        _prayerTimes[0],
        _prayerTimes[2],
        _prayerTimes[3],
        _prayerTimes[5],
        _prayerTimes[6],
      ];
      _namaSholat = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];
    });
  }

  var ikon = Icon(Icons.alarm_add_outlined);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: _waktuSholat.length,
            itemBuilder: (context, index) {
              return Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        width: 100,
                        child: Text(_namaSholat[index],
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.green[900],
                            )),
                      ),
                      Container(
                        width: 100,
                        child: Text(
                          _waktuSholat[index],
                          style: TextStyle(
                              color: Colors.green[900],
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(onPressed: () {}, icon: Icon(Icons.alarm_add))
                    ],
                  ));
            }));
  }
}
