import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_client/web_socket_client.dart';
import 'package:web_socket_channel/io.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.name, required this.id})
      : super(key: key);

  final String name;
  final String id;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final socket =
      WebSocket(Uri.parse('ws://localhost:8765')); // If using emulator

  final List<types.Message> _messages = [];
  late types.User otherUser;
  late types.User me;

  @override
  void initState() {
    super.initState();
    me = types.User(id: widget.id, firstName: widget.id);
    // Listen to messages from the server.
    socket.messages.listen((incomingMessage) {
      // Split the response into the JSON string and the "from" string
      List<String> parts = incomingMessage.split(' from ');
      String jsonString = parts[0];

      // Parse the JSON string using the jsonDecode() function
      Map<String, dynamic> data = jsonDecode(jsonString);

      // Access the values from the parsed JSON object
      String id = data['id'];
      String msg = data['msg'];
      String timestamp = data['timestamp'];

      if (id != me.id) {
        otherUser = types.User(id: id, firstName: id);
        onMessageReceived(msg);
      }
    });
  }

  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  void onMessageReceived(String message) {
    var newMessage = types.TextMessage(
      author: otherUser,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message,
      createdAt: DateTime.now().millisecondsSinceEpoch,
         metadata: {
      'senderName': otherUser.firstName,
    },
    );
    _addMessage(newMessage);
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: me,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
      metadata: {
        'senderName': me.firstName,
      },
    );

    var payload = {
      'id': me.id,
      'msg': message.text,
      'nick': me.firstName,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    socket.send(json.encode(payload));

    _addMessage(textMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ID ${widget.id} NickName ${widget.name}'),
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: me,
        theme: DefaultChatTheme(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Close the connection.
    socket.close();
    super.dispose();
  }
}
