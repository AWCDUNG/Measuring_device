import 'package:flutter/material.dart';
import 'screens/air_quality_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Air Quality Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: AirQualityScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}