import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  ChatBotPageState createState() => ChatBotPageState();
}

class ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    loadEnv();
  }

  // Load environment variables from .env file
  Future<void> loadEnv() async {
    await dotenv.load();
    if (dotenv.env['API_KEY'] == null) {
      showError("Error: API key is missing.");
    }
  }

  // Show error message method
  void showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Send user message and call API
  Future<void> sendMessage(String message) async {
    if (message.trim().isNotEmpty) {
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
  }

  // Send request to Gemini API and retrieve response
  Future<String> sendToGeminiAPI(String message) async {
    final String apiKey = dotenv.env['API_KEY']!; // Get the API key from environment variable
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey'); // Updated Gemini API endpoint

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': message},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['contents'][0]['parts'][0]['text'] ?? "No response text available";
    } else {
      showError('Error: ${response.statusCode} ${response.body}');
      return "Error: Something went wrong.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
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
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: message['sender'] == 'user'
                          ? Colors.orange
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['text']!,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
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
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
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