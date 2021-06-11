import 'package:flutter/material.dart';
import 'dart:async';

class Jam extends StatefulWidget {
  @override
  _JamState createState() => _JamState();
}

class _JamState extends State<Jam> {
  currentTime() {
    return "${DateTime.now().hour} : ${DateTime.now().minute} : ${DateTime.now().second}  ";
  }

  currentDate() {
    return "${DateTime.now().day} - ${DateTime.now().month} - ${DateTime.now().year}  ";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(22, 40, 22, 5),
          alignment: Alignment.center,
          child: Text(
            currentTime(),
            style: TextStyle(color: Colors.white, fontSize: 48),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(22, 5, 22, 22),
          alignment: Alignment.center,
          child: Text(
            currentDate(),
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
