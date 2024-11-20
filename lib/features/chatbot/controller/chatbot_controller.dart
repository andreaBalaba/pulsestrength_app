//dito yung mga logic sa chatbot

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pulsestrength/features/chatbot/controller/chatbot_controller.dart'; // Import ChatbotScreen
import 'dart:convert'; // For jsonEncode and jsonDecode


class ChatBotScreen extends StatefulWidget {
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  Future<void> sendMessage(String message) async {
    setState(() {
      _messages.add({'sender': 'user', 'text': message});
      _isTyping = true;
    });

    // API call to Gemini API
    final response = await sendToGeminiAPI(message);

    setState(() {
      _isTyping = false;
      _messages.add({'sender': 'bot', 'text': response});
    });
  }

  Future<String> sendToGeminiAPI(String message) async {
    // Replace this with your actual Gemini API endpoint and API key
    const String apiKey = "AIzaSyALho2K2wuPwaJYvHWn90PVWO8bYNnV4BQ";
    const String apiUrl = "https://api.openai.com/v1/engines/gemini/messages";

    final response = await http.post(
      Uri.parse(apiUrl)
      ,headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'message': message,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['reply'] ?? "I couldn't understand that. Can you please rephrase?";
    } else {
      return "Something went wrong. Please try again.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages display
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message['sender'] == 'user'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: message['sender'] == 'user'
                          ? Colors.orange
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Bot is typing..."),
            ),
          // Message input bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      sendMessage(_messageController.text);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
