import 'dart:math';

import 'package:flutter/material.dart';
import 'chat_page.dart'; 

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  String id = '';
  String nickname = '';

  @override
  void initState() {
    super.initState();
    generateRandomId();
  }

  void generateRandomId() {
    final random = Random();
    final randomNumber = random.nextInt(900000) + 100000; // Gera um número aleatório de 6 dígitos
    setState(() {
      id = randomNumber.toString();
    });
  }

  void openChatPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(name: nickname, id: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ID: $id',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                setState(() {
                  nickname = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Nickname',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                openChatPage(context);
              },
              child: const Text('Open Chat'),
            ),
          ],
        ),
      ),
    );
  }
}