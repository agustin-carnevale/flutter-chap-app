import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:realtime_chat_app/global/environment.dart';
import 'package:realtime_chat_app/models/login_response.dart';
import 'package:realtime_chat_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService with ChangeNotifier {
  User user;
  bool _authenticating = false;

  final _storage = FlutterSecureStorage();

  bool get authenticating => this._authenticating;
  set authenticating(bool value){
    this._authenticating = value;
    notifyListeners();
  }

  //static methods to manipulate the token
  static Future<String> getToken() async {
    final storage = FlutterSecureStorage();
    final token  = await storage.read(key: 'token');
    return token;
  }
  static Future<void> deleteToken() async {
    final storage = FlutterSecureStorage();
    await storage.delete(key: 'token');
  }

  Future<bool> login(String email, String password) async{
    this.authenticating = true;

    final data = {
      'email': email,
      'password': password
    };

    final response = await http.post('${Environment.apiUrl}/login', 
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json'
      }
    );

    if(response.statusCode == 200){
      final loginResponse = loginResponseFromJson(response.body);
      this.user = loginResponse.user;
      await _saveToken(loginResponse.token);

      this.authenticating = false;
      return true;
    }

    this.authenticating = false;
    return false;
  }

  Future register(String name, String email, String password) async{
    this.authenticating = true;

    final data = {
      'name': name,
      'email': email,
      'password': password
    };

    final response = await http.post('${Environment.apiUrl}/login/new', 
      body: json.encode(data),
      headers: {
        'Content-Type': 'application/json'
      }
    );

    if(response.statusCode == 201){
      final loginResponse = loginResponseFromJson(response.body);
      this.user = loginResponse.user;
      await _saveToken(loginResponse.token);

      this.authenticating = false;
      return true;
    }

    this.authenticating = false;
    final respBody = json.decode(response.body);
    return respBody['msg'];
  }

  Future<bool> isLoggedIn() async{
    final token = await this._storage.read(key: 'token');
    final response = await http.get('${Environment.apiUrl}/login/renew', 
      headers: {
        'Content-Type': 'application/json',
        'x-token': token
      }
    );

    if(response.statusCode == 200){
      final loginResponse = loginResponseFromJson(response.body);
      this.user = loginResponse.user;
      await _saveToken(loginResponse.token);
      return true;
    }

    this.logout();
    return false;
  }

  Future _saveToken(String token) async{
    // Write value 
    await _storage.write(key: 'token', value: token);
  }

  Future logout() async{
    // delete token from storage 
    await _storage.delete(key: 'token');
  }
}