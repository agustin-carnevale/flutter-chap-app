import 'package:flutter/material.dart';
import 'package:realtime_chat_app/routes/routes.dart';
 
void main() => runApp(MyApp());
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      initialRoute: 'chat',
      routes: appRoutes,
    );
  }
}