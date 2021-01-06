import 'package:flutter/material.dart';
import 'package:realtime_chat_app/global/environment.dart';
import 'package:realtime_chat_app/models/messages_response.dart';
import 'package:realtime_chat_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:realtime_chat_app/services/auth_service.dart';

class ChatService with ChangeNotifier {
  User userTo;

  Future<List<Message>> getChat(String otherUserID) async {
    final token = await AuthService.getToken();
    final response = await http.get('${Environment.apiUrl}/messages/$otherUserID',
      headers: {
        'Content-Type': 'application/json',
        'x-token': token
      }
    );

    final messagesResponse = messagesResponseFromJson(response.body);
    return messagesResponse.messages;
  }
}