import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_chat_app/services/auth_service.dart';
import 'package:realtime_chat_app/services/socket_service.dart';


class LoadingPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: checkLoginState(context),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) { 
          return Center(
            child: Text('Espere....'),
          );
        }
      ),
   );
  }

  Future checkLoginState(BuildContext context) async{
    final authService = Provider.of<AuthService>(context, listen: false);
    final socketService = Provider.of<SocketService>(context, listen: false);
    final isAuthenticated = await authService.isLoggedIn();

    if(isAuthenticated){
      socketService.connect();
      Navigator.pushReplacementNamed(context, 'users');
    }else{
      Navigator.pushReplacementNamed(context, 'login');
    }
  }
}