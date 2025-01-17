import 'dart:io';
import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pulsestrength/utils/global_variables.dart';
import 'package:pulsestrength/utils/reusable_text.dart';

class ChatBotScreen extends StatefulWidget {
  final String gender;
  final int age;
  final double height;
  final double weight;
  final bool isDisabled;

  const ChatBotScreen({
    super.key,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.isDisabled,
  });

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final Gemini gemini = Gemini.instance;
  final ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  final ChatUser geminiBot = ChatUser(
    id: "1",
    firstName: "FitBot",
    profileImage:
    "https://firebasestorage.googleapis.com/v0/b/fit-streaks-0133.appspot.com/o/image-Photoroom.png?alt=media&token=2440f111-41dc-41d1-91f6-68845b85ecd3",
  );
  List<ChatMessage> messages = [
    ChatMessage(
      user: ChatUser(
        id: "1",
        firstName: "FitBot",
        profileImage:
        "https://firebasestorage.googleapis.com/v0/b/fit-streaks-0133.appspot.com/o/image-Photoroom.png?alt=media&token=2440f111-41dc-41d1-91f6-68845b85ecd3",
      ),
      createdAt: DateTime.now(),
      text:
      "Hello there! I am FitBot\n\nHere to help you with your diet and exercise questions.\n\nYou can share an image of a food item as well to get suggestions about it.",
    ),
  ];

  void _sendMessageWithMedia(ChatMessage chatMessage) {
    setState(() {
      messages.insert(0, chatMessage);
    });

    try {
      final String question =
          "${chatMessage.text} identify the food item and give suggestions if my Physical details are - height: ${widget.height} cm, weight: ${widget.weight} kg, gender: ${widget.gender}, age: ${widget.age}.";

      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [File(chatMessage.medias!.first.url).readAsBytesSync()];
      }

      gemini.streamGenerateContent(question, images: images).listen((event) {
        final String response = event.content?.parts
            ?.map((part) => part.text)
            .join(" ") ??
            "";

        setState(() {
          messages.insert(
            0,
            ChatMessage(
              user: geminiBot,
              createdAt: DateTime.now(),
              text: response,
            ),
          );
        });
      });
    } catch (e, stackTrace) {
      debugPrint("Error in _sendMessageWithMedia: $e\n$stackTrace");
    }
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages.insert(0, chatMessage);
    });

    try {
      final String question =
          "-Question: ${chatMessage.text} Physical details - height: ${widget.height} cm, weight: ${widget.weight} kg, gender: ${widget.gender}, age: ${widget.age}. Use the provided templates strictly without alteration for responses. If the question is unrelated to diet/food/calories/exercise/stretching but contains user physical details, respond with: 'I'm here to assist you with diet and exercise-related queries. Please ask a question related to those topics.'";

      gemini.streamGenerateContent(question).listen((event) {
        final String response = event.content?.parts
            ?.map((part) => part.text)
            .join(" ") ??
            "";

        setState(() {
          messages.insert(
            0,
            ChatMessage(
              user: geminiBot,
              createdAt: DateTime.now(),
              text: response,
            ),
          );
        });
      });
    } catch (e, stackTrace) {
      debugPrint("Error in _sendMessage: $e\n$stackTrace");
    }
  }

  void _sendMediaMessage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      final ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "Is this food good for me?",
        medias: [
          ChatMedia(
            url: file.path,
            fileName: "",
            type: MediaType.image,
          ),
        ],
      );
      _sendMessageWithMedia(chatMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double autoScale = Get.width / 400;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: ReusableText(
          text: "FitBot",
          size: 20 * autoScale,
          fontWeight: FontWeight.w500,
        ),
      ),
      body: DashChat(
        messageOptions: const MessageOptions(
          currentUserContainerColor: AppColors.pLightGreenColor,
        ),
        inputOptions: InputOptions(
          trailing: [
            IconButton(
              onPressed: _sendMediaMessage,
              icon: const Icon(Icons.image),
            ),
          ],
        ),
        currentUser: currentUser,
        onSend: _sendMessage,
        messages: messages,
      ),
    );
  }
}
