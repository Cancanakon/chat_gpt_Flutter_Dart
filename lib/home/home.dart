import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String text;
  final bool isMe;

  ChatMessage({required this.text, required this.isMe});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];

  Future<void> _handleSubmitted(String text) async {
    _textController.clear();

    final message = ChatMessage(
      text: text,
      isMe: true,
    );

    setState(() {
      _messages.insert(0, message);
    });

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/engines/davinci-codex/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':'Bearer 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',
      },
      body: json.encode({
        'prompt': '$text\nAI:',
        'max_tokens': 50,
        'temperature': 0.5,
        'n': 1,
        'stop': ['\n'],
      }),
    );

    if (response.statusCode == 200) {
      print("Başarılı!");
      final responseData =
      json.decode(response.body)['choices'][0]['text'].toString();
      print(responseData);
      final botMessage = ChatMessage(
        text: responseData,
        isMe: false,
      );
      setState(() {
        _messages.insert(0, botMessage);
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration.collapsed(
                hintText: 'Send a message',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Chat-GPT API Example'),
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.separated(
              padding: EdgeInsets.all(8.0),
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  height: 1.0,
                  color: Colors.grey[400],
                );
              },
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_messages[index].text),
                  trailing: Icon(
                    _messages[index].isMe ? Icons.person : Icons.chat,
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }
}
