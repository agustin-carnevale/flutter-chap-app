import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_chat_app/routes/routes.dart';
import 'package:realtime_chat_app/services/auth_service.dart';
 
void main() => runApp(MyApp());
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) => AuthService(),
        ),
      ],
      child: MaterialApp(
        title: 'Chat App',
        debugShowCheckedModeBanner: false,
        initialRoute: 'loading',
        routes: appRoutes,
      ),
    );
  }
}