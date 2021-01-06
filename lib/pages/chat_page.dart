import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_chat_app/models/messages_response.dart';
import 'package:realtime_chat_app/services/auth_service.dart';
import 'package:realtime_chat_app/services/chat_service.dart';
import 'package:realtime_chat_app/services/socket_service.dart';
import 'package:realtime_chat_app/widgets/chat_message.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  ChatService chatService;
  SocketService socketService;
  AuthService authService;
  List<ChatMessage> _messagesList = [];
  bool _isWritting = false;

  @override
  void initState() {
    this.chatService = Provider.of<ChatService>(context, listen: false);
    this.socketService = Provider.of<SocketService>(context, listen: false);
    this.authService = Provider.of<AuthService>(context, listen: false);
    this.socketService.socket.on('private-message', _listenToMessages);

    _loadMessages(this.chatService.userTo.uid);
    super.initState();
  }

  void _loadMessages(String uid) async{
    List<Message> chat = await this.chatService.getChat(uid);
    final history = chat.map((m) => ChatMessage(
      text: m.message,
      uid: m.from,
      animationController: AnimationController(vsync: this, duration: Duration(milliseconds: 0))..forward(),
    ));
    setState(() {
      _messagesList.insertAll(0, history);
    });
  }

  void _listenToMessages(dynamic payload){
    final newMessage = ChatMessage(
      text: payload['message'],
      uid: payload['from'],
      animationController: AnimationController(vsync: this, duration: Duration(milliseconds: 400)),
    );

    setState(() {
      _messagesList.insert(0, newMessage);
    });
    newMessage.animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final userTo = chatService.userTo;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        title: Column(
          children: [
            CircleAvatar(
              child: Text(userTo.name.substring(0,2), style: TextStyle(fontSize: 12)),
              backgroundColor: Colors.blue[100],
              maxRadius: 14,
            ),
            SizedBox(height: 4),
            Text(userTo.name,
                style: TextStyle(color: Colors.black87, fontSize: 12)),
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Flexible(
                child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemBuilder: (_, i) => _messagesList[i],
              itemCount: _messagesList.length,
              reverse: true,
            )),
            Divider(height: 1),
            Container(
              color: Colors.white,
              child: _inputChat(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputChat() {
    return SafeArea(
        child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Flexible(
              child: TextField(
            controller: _textController,
            onSubmitted: _handleSubmit,
            onChanged: (String text) {
              setState(() {
                _isWritting = text.trim().length > 0;
              });
            },
            decoration: InputDecoration.collapsed(
              hintText: 'Enviar mensaje',
            ),
            focusNode: _focusNode,
          )),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Platform.isIOS
                ? CupertinoButton(
                    child: Text('Enviar'),
                    onPressed: _isWritting
                        ? () => _handleSubmit(_textController.text.trim())
                        : null,
                  )
                : Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: IconButton(
                      color: Colors.blue[400],
                      icon: Icon(Icons.send),
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onPressed: _isWritting
                          ? () => _handleSubmit(_textController.text.trim())
                          : null,
                    ),
                  ),
          ),
        ],
      ),
    ));
  }

  void _handleSubmit(String text) {
    if (text.length == 0 ) return;

    _textController.clear();
    _focusNode.requestFocus();

    final newMessage = ChatMessage(
      uid: this.authService.user.uid, 
      text: text,
      animationController: AnimationController(vsync: this, duration: Duration(milliseconds: 400)),
    );
    _messagesList.insert(0, newMessage);
    newMessage.animationController.forward();

    setState(() {
      _isWritting = false;
    });
    socketService.emit('private-message', {
      'from': authService.user.uid,
      'to': chatService.userTo.uid,
      'message': text
    });
  }

  @override
  void dispose() {
    for(ChatMessage message in _messagesList){
      message.animationController.dispose();
    }
    this.socketService.socket.off('private-message');
    super.dispose();
  }
}
