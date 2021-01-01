import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:realtime_chat_app/widgets/chat_message.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  List<ChatMessage> _messagesList = [];
  bool _isWritting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        title: Column(
          children: [
            CircleAvatar(
              child: Text('Te', style: TextStyle(fontSize: 12)),
              backgroundColor: Colors.blue[100],
              maxRadius: 14,
            ),
            SizedBox(height: 4),
            Text('Melisa Flores',
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
      uid: '123', 
      text: text,
      animationController: AnimationController(vsync: this, duration: Duration(milliseconds: 400)),
    );
    _messagesList.insert(0, newMessage);
    newMessage.animationController.forward();

    setState(() {
      _isWritting = false;
    });
  }

  @override
  void dispose() {
    //TODO: close socket

    for(ChatMessage message in _messagesList){
      message.animationController.dispose();
    }
    super.dispose();
  }
}
