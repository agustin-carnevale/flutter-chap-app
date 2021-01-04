import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:realtime_chat_app/models/user.dart';
import 'package:realtime_chat_app/services/auth_service.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
      
  final users = [
    User(uid:'1', name: 'Maria', email: 'test1@test.com', online: true),
    User(uid:'2', name: 'Melissa', email: 'test2@test.com', online: false),
    User(uid:'3', name: 'Fernando', email: 'test3@test.com', online: true),
    User(uid:'4', name: 'Nicolas', email: 'test4@test.com', online: false),
    User(uid:'5', name: 'Martin', email: 'test5@test.com', online: true),
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          authService.user.name,
          style: TextStyle(color: Colors.black54),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.exit_to_app),
          color: Colors.black87,
          onPressed: () {
            //TODO Disconnect from socket server
            authService.logout();
            Navigator.pushReplacementNamed(context, 'login');
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10.0),
            child: Icon(Icons.check_circle, color: Colors.blue,),
            // child: Icon(Icons.offline_bolt, color: Colors.red,),
          )
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        onRefresh: _loadUsers,
        header: WaterDropHeader(
          complete: Icon(Icons.check, color: Colors.blue[300]),
          waterDropColor: Colors.blue[300],
        ),
        child: _listViewUsers(),
      )
    );
  }

  ListView _listViewUsers() {
    return ListView.separated(
      physics: BouncingScrollPhysics(),
      itemBuilder: (_,i) => _userListTile(users[i]), 
      separatorBuilder: (_,i) => Divider(), 
      itemCount: users.length,
    );
  }

  ListTile _userListTile(User user) {
    return ListTile(
        title: Text(user.name),
        subtitle: Text(user.email),
        leading: CircleAvatar(
          child: Text(user.name.substring(0,2)),
        ),
        trailing: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: user.online ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      );
  }

  void _loadUsers() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }
}
