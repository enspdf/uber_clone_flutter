import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone_flutter/screens/home.dart';
import 'package:uber_clone_flutter/states/app_state.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: AppState()),
        ],
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Uber Clone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Uber Clone'),
    );
  }
}
