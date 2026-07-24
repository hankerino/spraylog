import 'package:flutter/material.dart';

void main() => runApp(const SprayLogApp());

class SprayLogApp extends StatelessWidget {
  const SprayLogApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SprayLog',
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.green),
      home: const Scaffold(body: Center(child: Text('SprayLog - Coming soon'))),
    );
  }
}
