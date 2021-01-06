import 'package:realtime_chat_app/global/environment.dart';
import 'package:realtime_chat_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:realtime_chat_app/models/users_response.dart';
import 'package:realtime_chat_app/services/auth_service.dart';

class UsersService {
  Future<List<User>> getUsers() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get('${Environment.apiUrl}/users',
        headers: {
        'Content-Type': 'application/json',
        'x-token': token
        }
      );

      final usersResponse = usersResponseFromJson(response.body);
      return usersResponse.users;
    } catch (e) {
      return [];
    }
  }
}